class Event < ActiveRecord::Base

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
  validates_presence_of  :title
  validates_length_of    :title, :within => 3..100
  validates_presence_of  :link
  validates_presence_of  :tag_list
  validates_presence_of  :organisation

  belongs_to :organisation
  belongs_to :user
  
  translates :title, :description, :location
  accepts_nested_attributes_for :globalize_translations

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
  def translation_attributes=( translation_attributes)
    p '===================='
    p translation_attributes.inspect
    p '===================='
  end

# returns all languages for which a translation exists
# used for the language-selection tabs in forms
  def languages
    translations = EventTranslation.find(:all, :conditions=> "event_id='#{self.id}'", :order => 'locale ASC')
    langs = []
    translations.each do |t|
      langs.push t.locale.to_s # ist komischerweise ein symbol
    end
    return langs
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

#  def validate
#    errors.add_to_base "Bitte geben Sie eine Adresse ein." if address.blank?
#  end



end
