class AlterScrapeFailChangeBacktraceDataType < ActiveRecord::Migration[5.1]
  def up
    change_column :scrape_fails, :backtrace, :text, array: true, default: [], using: "(string_to_array(backtrace, ','))"
  end

  def down
    change_column :scrape_fails, :backtrace, :text
  end
end
