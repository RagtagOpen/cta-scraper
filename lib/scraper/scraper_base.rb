require 'indirizzo/address'
require 'nokogiri'
require 'httparty'
require 'cta_aggregator_client'

module Scraper
  class ScraperBase

    EVENT_ATTRS = [
      'browser_url', 'origin_system', 'title', 'description', 'start_date', 'end_date', 'free', 'featured_image_url', 'identifiers'
    ].freeze
    
    def initialize(scrape_fail)
      @scrape_fail = scrape_fail
    end
    
    private

    attr_reader :scrape_fail

    def parse_text(text=nil)
      text.nil? ? text : text.strip
    end

    def find_next_node(current_node)
      el = current_node.next_element

      if el.children
        el_children_with_data = el.children.reject { |child| child.text.gsub("\r\n", '').empty? }
        if el_children_with_data.any?
          el
        else
          el.next_element
        end
      end
    end

    def parse_location(location_data)
      return if location_data.empty?
      city_state_zip = Indirizzo::Address.new(location_data.pop)
      location = {
        address_lines: location_data,
        locality: city_state_zip.city.first.titlecase,
        region: city_state_zip.state,
        postal_code: city_state_zip.zip
      }
    end

    def is_zipcode?(candidate)
      candidate.length == 5 && candidate.scan(/[[:digit:]]/).any?
    end

    def parse_node_data(node_data)
      if node_data.children
        node_data.children.map { |data| data.text.strip  }.reject(&:empty?)
      end
    end

    def load_webpage(link)
      raw_page = HTTParty.get(link)
      Nokogiri::HTML(raw_page)
    end

    def log_scrape_failure(e, scrape_attrs)
      if e.try(:http_code)
        scrape_fail.create!(
          status_code: e.http_code,
          message: e.http_body,
          backtrace: e.backtrace[1..4],
          scrape_attrs: scrape_attrs
        )
      else
        # catches scraping errors raised prior to making req to API.
        scrape_fail.create!(
          message: e,
          backtrace: e.backtrace[1..4],
          scrape_attrs: scrape_attrs
        )
      end
    end
    
    def create_events_in_aggregator(events)
      events.each { |event| create_event_in_aggregator(event) }
    end
    
    def create_event_in_aggregator(event_data)
      find_or_create_event(event_data)
    rescue Exception => e
      # Rescuing all exceptions is typically a terrible idea.
      # We're doing it here because we always want to ensure the scraper can
      # continue iterating through the list of scraped events.

      log_scrape_failure(e, event_data)
    end

    def find_or_create_location(location_data)
      response = CTAAggregatorClient::Location.create(location_data)
      location_id = JSON.parse(response.body)['data']['id']
      { location: location_id }
    rescue RestClient::Found => err
      if err.http_headers[:location]
        location_id = err.http_headers[:location].split('/').last
        { location: location_id }
      end
    end
    
  end
end
