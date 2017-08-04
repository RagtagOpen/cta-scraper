require 'nokogiri'
require 'httparty'
require 'cta_aggregator_client'
require 'Indirizzo'

module Scraper
  class EmilysList
    ORIGIN_SYSTEM = "Emily's List"

    def scrape
      raw_page = HTTParty.get("http://www.emilyslist.org/pages/entry/events")
      events = []
      event_links(raw_page).each do |link|
        events << events_for_page(link)
      end
      # create_events_in_aggregator(events)
    end

    private

    def create_events_in_aggregator(events)
      events.each do |event|
        location_data = location_payload(event.delete('location'))
        unless location
        # record that payload was provided by there was trouble parsing location data

        end
        response = CTAAggregatorClient::Event.create(event, location_data)
      end
    end

    def location_payload(location_data)
      response = CTAAggregatorClient::Location.create(location_data)
      if response.status == 200 || response.status == 201
        location = JSON.parse(response.body)['data']['id']
        { location: location }
      end
    end

    def event_links(raw_page)
      page = Nokogiri::HTML(raw_page)
      events = []
      page.xpath('//h2[text()="Upcoming Events"]/following-sibling::p').each do |p|

        date_and_location = p.css('strong').first

        next unless date_and_location

        links = p.css('a')
        next unless links.first
        event_url = p.xpath('./a[1]/@href').first.content

        # past events link to flickr sets, not event pages
        if /secure\.emilyslist\.org/ =~ event_url
          events << p.css('a').first.attributes['href'].value
        end
      end
      events
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


      if date_lumped_with_location_data?(date_node)
        location_data = parse_node_data(date_node)
        location_data.shift
      else
        location_node = find_next_node(date_node)
        location_data = parse_node_data(location_node)
      end
      event['location'] = parse_location(location_data)

      
      event['free'] = payment_button_present?(page)

      p event
      # binding.pry
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
      begin
        el
      rescue ArgumentError
        el.next_element
      end
    end

    def parse_start_date(current_node, schedule_node = nil)
      begin
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
        # TypeError: no implicit conversion of nil into String raised when unable to get value for a date_text component
        nil
      end
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

      if is_a_time?(schedule)
        schedule
      else
        ''
      end
    end

    def is_a_time?(possibly_a_time)
      begin
        Time.parse(possibly_a_time)
        true
      rescue ArgumentError
        return false
      end
    end

    def date_from_node(node)
      DateTime.parse(node)
    end

    def date_lumped_with_location_data?(node)
      begin
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
        zipcode: city_state_zip.zip
      }
    end

    def is_zipcode?(candidate)
      candidate.length == 5 && candidate.scan(/[[:digit:]]/).any?
    end

    def parse_node_data(node_data)
      node_data.children.map { |data| data.text.strip  }.reject(&:empty?)
    end

    def load_webpage(link)
      raw_page = HTTParty.get(link)
      Nokogiri::HTML(raw_page)
    end

  end
end
