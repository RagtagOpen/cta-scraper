require 'scraper/emilys_list'
require 'scraper/five_calls'

module Scraper
  class << self

    def emilys_list
      EmilysList.new(ScrapeFail)
    end

    def five_calls
      FiveCalls.new(ScrapeFail)
    end
  end
end
