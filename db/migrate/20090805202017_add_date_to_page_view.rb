class AddDateToPageView < ActiveRecord::Migration
  def self.up
    add_column :page_views, :date, :date
  end

  def self.down
    remove_column :page_views, :date
  end
end
