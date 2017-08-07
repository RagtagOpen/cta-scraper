class AlterScrapeFailsAddScrapeAttrsCol < ActiveRecord::Migration[5.1]
  def up
    add_column :scrape_fails, :scrape_attrs, :jsonb, default: {}
    remove_column :scrape_fails, :event_attrs
  end

  def down
    remove_column :scrape_fails, :scrape_attrs
    add_column :scrape_fails, :event_attrs, :text
  end
end
