class Song < ApplicationRecord
  include HasName

  has_and_belongs_to_many :playlists
  belongs_to :album
  validates :name, presence:true
  validates :duration, presence:true, numericality: { only_integer: true }

  def duration
    Time.at(self[:duration]).strftime("%M:%S") if self[:duration]
  end

  def seconds
    self[:duration]
  end
end