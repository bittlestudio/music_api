require 'hasname'

class Album < ApplicationRecord
  has_many :songs
  belongs_to :artist
  validates :name, presence:true

  include HasName
end