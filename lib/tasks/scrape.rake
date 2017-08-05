require 'scraper'

namespace :scrape do

  task :emily_list => :environment do
    Scraper.emilys_list.scrape
  end

end
