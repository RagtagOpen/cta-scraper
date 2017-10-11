module Scraper
  class ManualInputSheet < ScraperBase
    def scrape
      manual_input_sheet = ManualInputSheet.new
      manual_input_sheet.load_sheet
      advocacy_campaigns = manual_input_sheet.advocacy_campaigns
      create_campaigns(advocacy_campaigns)
    end

    private

    def create_campaigns(advocacy_campaigns)
      advocacy_campaigns.each do |campaign|
        create_campaign(campaign)
      end
    end

    def create_campaign(campaign)
      find_or_create_campaign(campaign)
    rescue Exception => e
      # Rescuing all exceptions is typically a terrible idea.
      # We're doing it here because we always want to ensure the scraper can
      # continue iterating through the list of scraped campaigns.

      log_scrape_failure(e, campaign_data)
    end

    def find_or_create_campaign(campaign)
      campaign.create
    rescue RestClient::Found
      nil
    end
  end
end
