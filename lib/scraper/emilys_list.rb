require 'scraper/scraper_base'

module Scraper
  class EmilysList < ScraperBase

    ORIGIN_SYSTEM = "Emily's List"
    ORIGIN_URL = "http://www.emilyslist.org/pages/entry/events"
    EVENT_ATTRS = [
      'browser_url', 'origin_system', 'title', 'description', 'start_date', 'end_date', 'free', 'featured_image_url'
    ].freeze

    def scrape
      raw_page = HTTParty.get(ORIGIN_URL)
      events = []
      event_urls(raw_page).each do |link|
        events << events_for_page(link)
      end
      create_events_in_aggregator(events)
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

      scrape_fail.create!(
        status_code: e.http_code,
        message: e.message,
        backtrace: e.backtrace[1..4],
        scrape_attrs: event_data
      )
    end

    def find_or_create_event(event_data)
      # We're gently slicing stuff, rather than deleting, since deleting
      # elements from the hash would mutate it and we want the full list of 
      # attributes in cases where scraping fails and we log those attributes

      event_attrs = event_data.slice(*EVENT_ATTRS)
      location = find_or_create_location(event_data['location'])

      CTAAggregatorClient::Event.create(event_attrs, location)
    rescue RestClient::Found => err
      nil
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

    def event_urls(raw_page)
      page = Nokogiri::HTML(raw_page)
      urls = []
      page.xpath('//h2[text()="Upcoming Events"]/following-sibling::p').each do |p|

        date_and_location = p.css('strong').first

        next unless date_and_location

        links = p.css('a')
        next unless links.first
        event_url = p.xpath('./a[1]/@href').first.content

        # past events link to flickr sets, not event pages
        if /secure\.emilyslist\.org/ =~ event_url
          urls << p.css('a').first.attributes['href'].value
        end
      end
      urls
    end

    def events_for_page(link)
      page = load_webpage(link)

      event = Hash.new
      event['browser_url'] = link
      event['origin_system'] = ORIGIN_SYSTEM

      title_node = page.xpath("/html/body//h1")[1]
      title = parse_title(title_node)
      event['title'] = title

      date_node = find_start_date_node(title_node)
      schedule_node = page.at('p:contains("Schedule")')
      event['start_date'] = parse_start_date(date_node, schedule_node)

      event['free'] = payment_button_present?(page)

      if date_lumped_with_location_data?(date_node)
        location_data = parse_node_data(date_node)
        location_data.shift
      else
        location_node = find_next_node(date_node)
        location_data = parse_node_data(location_node)
      end
      event['location'] = parse_location(location_data)

      event
    end

    def parse_title(title_node)
      title_node.children[0].text.strip
    end

    def payment_button_present?(page)
      page.search('input[id=processbutton]').first ? false : true
    end

    def find_start_date_node(current_node)
      el = current_node.next_element
    rescue ArgumentError
      el.next_element
    end

    def parse_start_date(current_node, schedule_node = nil)
      next_node = find_next_node(current_node)
      if schedule_node
        start_date = current_node.children.first.text.strip
        start_time = schedule_near_node(schedule_node)
      else
        schedule = text_without_empty_lines(current_node)
        start_date = schedule[0].text.gsub("\r\n", '')
        start_time = schedule[1].text.gsub("\r\n", '').split('-')[0]
      end

      date_text = start_date + ' ' + start_time
      date_from_node(date_text)
    rescue TypeError => err
      # A TypeError: no implicit conversion of nil into String error will be raised when unable to get value for a date_text component
      nil
    end

    def text_without_empty_lines(node)
      node.children.reject { |child| child.text.gsub("\r\n", '').empty? }
    end

    def time_from_text(text)
      raw_time = text.match(/(\d+):(\d+)\s(a.m.|p.m.|AM|PM|A.M.|P.M)/)
      raw_time[0]
    end

    def schedule_near_node(node)
      # meant to capture html like this
      # Schedule:
      # 10:30 a.m. — Political Briefing
      # 12:00 p.m. — Luncheon and Panel
      # Occasionally the time are in first element, other times they in the elment after

      schedule_text = text_without_empty_lines(node)[1]
      if !schedule_text
        schedule = node.next_element.children.reject { |child| child.text.gsub("\r\n", '').empty? }[1].text.gsub("\r\n", '').split('—')[0]
      else
        schedule = schedule_text.text.gsub("\r\n", '').split('—')[0]
      end

      is_a_time?(schedule) ? schedule : ''
    end

    def is_a_time?(possibly_a_time)
      Time.parse(possibly_a_time)
      true
    rescue ArgumentError
      return false
    end

    def date_from_node(node)
      DateTime.parse(node)
    end

    def date_lumped_with_location_data?(node)
      trimmed_node_data = parse_node_data(node)
      date_found = date_from_node(trimmed_node_data[0])
      zip_from_address_found = is_zipcode?(trimmed_node_data.last.split(' ').last)

      return date_found && zip_from_address_found

      # Exceptions are rescued when parsing date fails
    rescue ArgumentError
      return false
    rescue TypeError
      return false
    end

  end
end
