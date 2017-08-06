require 'scraper'

namespace :scrape do

  task :emilys_list => :environment do
    Scraper.emilys_list.scrape
  end

end
