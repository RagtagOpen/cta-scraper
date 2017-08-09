class ALterScrapeFailAddActiveCol < ActiveRecord::Migration[5.1]
  def change
    add_column :scrape_fails, :active, :boolean, default: true
  end
end
