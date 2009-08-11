class CreatePageViews < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.string :url
      t.integer :count
    end
  end

  def self.down
    drop_table :page_views
  end
end
