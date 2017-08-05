class CreateScrapeFails < ActiveRecord::Migration[5.1]
  def change
    create_table :scrape_fails do |t|
      t.string :status_code
      t.string :message
      t.text :backtrace
      t.text :event_attrs

      t.timestamps
    end
  end
end
