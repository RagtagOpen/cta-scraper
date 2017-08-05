require 'scraper/emilys_list'

module Scraper
  class << self

    def emilys_list
      EmilysList.new(ScrapeFail)
    end

  end
end
