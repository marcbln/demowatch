require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  RoleUser = 0
  RoleAdmin = 1
  
  acts_as_taggable
  has_many :organizers, :dependent => :destroy
  has_many :organisations, :through => :organizers
  has_many :bookmarks, :dependent => :destroy
  has_many :comments
  has_many :events
  
  belongs_to :zip,
             :class_name => "Zip",
             :foreign_key => "zip_id"
  
  
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :tag_list, :zip

  acts_as_state_machine :initial => :pending
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def is_admin?
    role == RoleAdmin
  end
  
  def has_organisation?
    not organisations.empty?
  end
  
  def owns? item
    case item 
      when Organisation
        organizer = organizers & item.organizers
        !organizer.empty? && organizer.first.role == Organizer::RoleAdmin  
      when Event
       organizer = organizers & item.organisation.organizers
       item.user == self || !organizer.empty? && organizer.first.role == Organizer::RoleAdmin
      when User
        item == self 
      when Comment
        item.user == self 
    end
  end
    
  def self.find_by_event( event)
    tag_ids = []
    event.tags.each { |t| tag_ids << t.id }
    return self.find_by_sql( "SELECT * FROM `users`, `taggings`
                              WHERE `users`.`id` = `taggings`.`taggable_id` 
                                AND `taggings`.`taggable_type` = 'User' 
                                AND `taggings`.`tag_id` IN ( #{tag_ids.join(',')} )
                                AND `users`.`deleted_at` IS NULL
                                AND `users`.`state` = 'active'
                                GROUP BY `users`.`id` "
                              );
   
  end





  
protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) if self.activation_code.nil?
    end
    
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end


    def initialize( args)
      zip = args.delete( :zip)
      super( args)
      self.zip = Zip.find_by_zip( zip)
    end
    
    

    
private

#    def validate
#      errors.add 'ZIP', 'PLZ konnte nicht gefunden werden.' if self.zip.nil?       
#    end

end
