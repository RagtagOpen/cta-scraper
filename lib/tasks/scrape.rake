require 'scraper'

namespace :scrape do

  task :all => :environment do
    Scraper.emilys_list.scrape
    Scraper.five_calls.scrape
  end

  task :emilys_list => :environment do
    Scraper.emilys_list.scrape
  end

  task :five_calls => :environment do
    Scraper.five_calls.scrape
  end
  
  # bundle exec rake scrape:resistance_calendar  --trace
  task :resistance_calendar => :environment do
    Scraper.resistance_calendar.scrape
  end

end
