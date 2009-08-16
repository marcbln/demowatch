class EventTranslations < ActiveRecord::Migration
  def self.up
    create_table :event_translations do |t|
      t.string     :locale, :limit => 2
      t.references :event
      t.text       :title
      t.text       :description
      t.string     :location
      t.timestamps
    end
    
    events = Event.find :all
    events.each do |e|
      EventTranslation.create(
        :event=> e,  
        :locale => 'de', 
        :title => e[:title], 
        :description => e[:description],
        :location => e[:location])
      p e[:title]
    end

  end




  def self.down
    drop_table :event_translations
  end
end


