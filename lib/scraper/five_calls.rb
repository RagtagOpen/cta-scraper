require 'scraper/scraper_base'

require 'pry'

module Scraper
  class FiveCalls < ScraperBase
    ORIGIN_SYSTEM = '5Calls'
    ORIGIN_URL = 'https://5calls.org/issues/'
    CAMPAIGN_ATTRS = [
      'browser_url', 'origin_system', 'title', 'description', 'template', 'action_type'
    ]
    ACTION_TYPE = 'action_type'

    def scrape
      campaigns = []
      issues.each do |issue|
        campaigns << parse_issue(issue) unless issue['inactive']
      end
      create_campaigns_in_aggregator(campaigns)
    end

    def parse_issue(issue)
      campaign = Hash.new
      campaign['action_type'] = ACTION_TYPE
      campaign['origin_system'] = ORIGIN_SYSTEM
      campaign['browser_url'] = issue['link'] #might be blank
      campaign['title'] = issue['name']
      campaign['description'] = issue['reason']
      campaign['template'] = issue['script']
      campaign['targets'] = parse_targets(issue['contacts'])
          
      campaign['identifiers'] = ["#{ORIGIN_SYSTEM}:#{issue['id']}"]
      # ^ yes?
      campaign.reject{ |k,v| v.empty? }
    end

    def create_campaigns_in_aggregator(campaigns)
      campaigns.each { |campaign| create_campaign_in_aggregator(campaign) }
    end

    def create_campaign_in_aggregator(campaign_data)
      find_or_create_campaign(campaign_data)
    rescue Exception => e
      # Rescuing all exceptions is typically a terrible idea.
      # We're doing it here because we always want to ensure the scraper can
      # continue iterating through the list of scraped campaigns.

      log_scrape_failure(e, campaign_data)
    end

    def find_or_create_campaign(campaign_data)
      # We're gently slicing stuff, rather than deleting, since deleting
      # elements from the hash would mutate it and we want the full list of 
      # attributes in cases where scraping fails and we log those attributes

      campaign_attrs = campaign_data.slice(*CAMPAIGN_ATTRS)
      targets = find_or_create_targets(campaign_data['targets'])

      CTAAggregatorClient::AdvocacyCampaign.create(campaign_attrs, targets)
    rescue RestClient::Found => err
      nil
    end

    def find_or_create_targets(targets)
      return unless targets
      target_ids = targets.map { |target_data| find_or_create_target(target_data) }
      { targets: target_ids }
    end

    def find_or_create_target(target_data)
      response = CTAAggregatorClient::Target.create(target_data)
      target_id = JSON.parse(response.body)['data']['id']
      target_id
    rescue RestClient::Found => err
      if err.http_headers[:location]
        target_id = err.http_headers[:location].split('/').last
        target_id
      end
    end

    def is_department?(text)
      if text =~ /dep[^"\r\n]*\sof\s"]/i
        true
      end
    end

    def parse_targets(target_data = [])
      target_data.map do |data|
        target = Hash.new

        full_name_and_organization = data['name'].split(',')

        # Sometimes 5Calls pops in a department but no user
        # e.g. "Department of Justice"
        if is_department?(full_name_and_organization[0])
          target['organization'] = full_name_and_organization[0]
        else
          full_name = full_name_and_organization[0].split(' ')

          target['organization'] = full_name_and_organization[1]
          target['given_name'] = full_name.shift
          target['family_name'] = full_name
        end

        target['phone_numbers'] = [ primary: true, number: data['phone'], number_type: :work ]
        target.reject{ |k,v| v.nil? }
      end
    end

    def issues
      response = RestClient.get(ORIGIN_URL)
      JSON.parse(response)['issues']
    end
  end
end

