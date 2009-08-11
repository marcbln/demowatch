class Event < ActiveRecord::Base

  include TranslationHelper

  acts_as_taggable
  acts_as_bookmarkable
  acts_as_mappable :default_units => :kms, 
                   :default_formula => :sphere, 
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  acts_as_paranoid
  acts_as_commentable

#  before_validation_on_create :geocode_address
  
  validates_presence_of  :address
  validates_presence_of  :link
  validates_presence_of  :tag_list
  validates_presence_of  :organisation

  belongs_to :organisation
  belongs_to :user

  has_many :event_translations
  after_update :save_translations
  validates_associated :event_translations, :message=>'^Sie müssen für jede Sprache einen Titel angeben'
#  translates :title, :description, :location
#  accepts_nested_attributes_for :event_translations

  DemoEvent = 0
  PicketEvent = 1
  FlashmobEvent = 2
  ChainEvent = 3
  
  def self.event_types
    [
      [ I18n.t("events.event_types.DemoEvent"), DemoEvent ],
      [ I18n.t("events.event_types.PicketEvent"), PicketEvent ],
      [ I18n.t("events.event_types.FlashmobEvent"), FlashmobEvent ],
      [ I18n.t("events.event_types.ChainEvent"), ChainEvent ]
      ]
  end

# SEO friendly URLs
  def to_param
    id.to_s+'-' + title.downcase.
    gsub('á', 'a').
    gsub('à', 'a').
    gsub('â', 'a').
    gsub('ä', 'ae').
    gsub('ö', 'oe').
    gsub('ü', 'ue').
    gsub('ß', 'ss').
    gsub(/([^a-z0-9]+)/, ' ').strip().gsub(' ', '-')
  end

# pagination parameters
  def self.per_page
    50
  end

  def link= value
    if value == ''
      self [:link]=value
    else
      if value =~ /@/
        self [:link]='mailto:'+value unless value =~ /^mailto:/
      elsif value =~ /^http:\/\//
        self [:link]=value
      else
        self [:link]='http://'+value
      end
    end
  end


  # virtual attribute setter
  def existing_translation_attributes=( translation_attributes)
    translation_attributes.each do |tr_id,tr_attributes|
      tr = event_translations.detect { |t| t.id == tr_id.to_i  }
      tr.attributes = tr_attributes
    end
  end
  # virtual attribute setter
  def new_translation_attributes=( translation_attributes)
    translation_attributes.each do |translation|
      event_translations.build(translation)
    end
  end

  def save_translations
    event_translations.each do |tr|
      tr.save(false)
    end
  end

  def title
    return TranslationHelper.get_translation( event_translations, :title)
  end
  def description
    return TranslationHelper.get_translation( event_translations, :description)
  end
  def location
    return TranslationHelper.get_translation( event_translations, :location)
  end

# returns all languages for which translations exist
# .... unused...
  def languages
    translations = EventTranslation.find(:all, :conditions=> "event_id='#{self.id}'", :order => 'locale ASC')
    langs = []
    translations.each do |t|
      langs.push t.locale.to_s
    end
    return langs
  end
  
  
  def coordinates
    [ latitude, longitude ]
  end
  
  def contras
    Event.find(:all, :conditions => [ "(NOT id='" + String(id) + "') AND city LIKE '" + city + "' AND startdate >= '" + I18n.l(startdate - 4.hours,:format => "%Y-%m-%d %H:%M:%S") + "' AND startdate <= '" + I18n.l(startdate + 4.hours,:format => "%Y-%m-%d %H:%M:%S") + "'"])
  end
  
  def changed_at
    last = comments.map{|c| c.updated_at} << updated_at
    last.max
  end

  # index types  
  Yearly = 0
  Monthly = 1

  def self.chron_sections events, index_type=Yearly
    result = []
    events.each do |event| 
      format =  index_type == Yearly ? '%Y' : "%B#{' %Y' if event.startdate.year != Time.now.year}"
      section = I18n.l(event.startdate, :format => format)
      if result.empty? || result.last.first != section
        result << [section, [event]]
      else
        result.last.last << event
      end
    end
    result
  end
  
private

  def validate
    ev = Event.find_by_id( id)
    if( !(ev.nil? || ev.address != address))
      return
    end
    geo=GeoKit::Geocoders::MultiGeocoder.geocode(address)
    errors.add(:address, I18n.t("activerecord.errors.messages.google_not_found")) if !geo.success
    self.address,self.city,self.latitude,self.longitude = geo.full_address,geo.city,geo.lat,geo.lng if geo.success

#    puts( geo.state + '##################');
  end


end
