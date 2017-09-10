require 'scraper/emilys_list'
require 'scraper/five_calls'
require 'scraper/resistance_calendar'

module Scraper
  class << self

    def emilys_list
      EmilysList.new(ScrapeFail)
    end

    def five_calls
      FiveCalls.new(ScrapeFail)
    end
    
    def resistance_calendar
      ResistanceCalendar.new(ScrapeFail)
    end
  end
end
