class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  acts_as_paranoid

  belongs_to :commentable, :polymorphic => true

  validates_presence_of  :title
  validates_length_of    :title, :within => 3..100
  validates_presence_of  :comment

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

end