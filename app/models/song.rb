class Song < ApplicationRecord
  has_and_belongs_to_many :playlists
  belongs_to :album
  validates :name, presence:true
  validates :duration, presence:true, numericality: { only_integer: true }
end
