require 'indirizzo/address'
require 'nokogiri'
require 'httparty'
require 'cta_aggregator_client'

module Scraper
  class ScraperBase

    def initialize(scrape_fail)
      @scrape_fail = scrape_fail
    end

    private

    attr_reader :scrape_fail

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
      node_data.children.map { |data| data.text.strip  }.reject(&:empty?)
    end

    def load_webpage(link)
      raw_page = HTTParty.get(link)
      Nokogiri::HTML(raw_page)
    end
  end
end
