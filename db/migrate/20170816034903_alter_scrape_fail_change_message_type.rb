class AlterScrapeFailChangeMessageType < ActiveRecord::Migration[5.1]
  def up
    # theoretically the following command changes the datatype from text to jsonb.
    # change_column :scrape_fails, :messge, :jsonb, using: 'message::JSON', default: {}
    # However, it's not working, so we're just going to blow away the old column and make a new one the right way
    # Project hasn't hit prod env yet, so no danger in losing data.
    remove_column :scrape_fails, :message
    add_column :scrape_fails, :message, :jsonb, default: {}
  end

  def down
    remove_column :scrape_fails, :message
    add_column :scrape_fails, :message, :text
  end
end
