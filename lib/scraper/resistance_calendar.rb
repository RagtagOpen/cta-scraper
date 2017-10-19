require 'scraper/scraper_base'
require 'hyperclient'
require 'cta_aggregator_client'

module Scraper
  class ResistanceCalendar < ScraperBase

    ORIGIN_SYSTEM = "Resistance Calendar"
    SYSTEM_NAME = "resistance-calendar"
    ORIGIN_URL = "https://resistance-calendar.herokuapp.com/v1/events"
    
    def scrape(page: 1)
      if page == 'all'
        i = 1
        loop do
          url = "#{ORIGIN_URL}?page=#{i}"
          osdi = Hyperclient.new(url)
          if osdi['osdi:events'].blank?
            break
          else
            create_events_in_aggregator( osdi['osdi:events'] )
          end
          i += 1
        end
      else
        url = "#{ORIGIN_URL}?page=#{page}"
        osdi = Hyperclient.new(url)
        create_events_in_aggregator( osdi['osdi:events'] )
      end
      
    end
    
    # this needs to be here, and not in scraper_base, because we can only use a subset of the location data from resistance cal
    def find_or_create_event(event_data)
      event_attrs = event_data._attributes.to_h.slice(*EVENT_ATTRS)
      
      if ed = event_data['location']

        return if ineligible_location(ed)

        location_hash = {address_lines: ed['address_lines'], locality: ed['locality'], region: ed['region'], postal_code: ed['postal_code'], venue: ed['venue']}
        location = find_or_create_location( location_hash )   
        event_attrs.merge!(location) 
      end
      response = CTAAggregatorClient::Event.create(event_attrs)

    rescue RestClient::Found => err
      nil
    end

    def ineligible_location(event_data)
      # Resistance Calendar occasionally pops in events from Australia
      (event_data['region'] && event_data['region'].length > 2) || 
        (event_data['postal_code'] && event_data['postal_code'].length < 5)
    end

  end
end
