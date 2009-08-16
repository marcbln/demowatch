class MultilangTags < ActiveRecord::Migration
  def self.up
    create_table :tag_translations do |t|
      t.string     :locale, :limit => 2
      t.references :tag
      t.string     :name, :limit => 255
      t.timestamps
    end

    tags = Tag.find :all
    tags.each do |t|
      puts t[:name]
      TagTranslation.create(
        :tag_id => t.id,
        :locale => 'de',
        :name => t[:name]
      )
    end

  end




  def self.down
    drop_table :tag_translations
  end

end
