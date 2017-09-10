require 'scraper/scraper_base'
require 'hyperclient'
require 'cta_aggregator_client'

module Scraper
  class ResistanceCalendar < ScraperBase

    ORIGIN_SYSTEM = "Resistance Calendar"
    SYSTEM_NAME = "resistance-calendar"
    ORIGIN_URL = "https://resistance-calendar.herokuapp.com/v1/events"
    EVENT_ATTRS = [
      'browser_url', 'origin_system', 'title', 'description', 'start_date', 'end_date', 'free', 'featured_image_url', 'identifiers'
    ].freeze
    
    def scrape
      osdi = Hyperclient.new(ORIGIN_URL)
      create_events_in_aggregator( osdi['osdi:events'] )
    end
    
    # this needs to be here, and not in scraper_base, because we can only use a subset of the location data from resistance cal
    def find_or_create_event(event_data)
      event_attrs = event_data._attributes.to_h.slice(*EVENT_ATTRS)
      
      if ed = event_data['location']
        location_hash = {address_lines: ed['address_lines'], locality: ed['locality'], region: ed['region'], postal_code: ed['postal_code'], venue: ed['venue']}
        location = find_or_create_location( location_hash )   
        event_attrs.merge!(location) 
      end
      response = CTAAggregatorClient::Event.create(event_attrs)

    rescue RestClient::Found => err
      nil
    end
    
  end
end