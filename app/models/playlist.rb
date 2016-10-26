require 'hasname'

class Playlist < ApplicationRecord
  has_and_belongs_to_many :songs
  validates :name, presence:true

  include HasName
end
