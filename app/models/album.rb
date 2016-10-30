class Album < ApplicationRecord
  include HasName

  attr_accessor :data_url

  has_many :songs, dependent: :destroy
  belongs_to :artist
  validates :name, presence:true

  def full_album_url
    if self.data_url && self.album_art
      self.data_url + self.album_art
    end
  end
end