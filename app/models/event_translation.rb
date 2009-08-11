class EventTranslation < ActiveRecord::Base
  belongs_to              :event
  validates_length_of     :title, :within => 3..100

end
