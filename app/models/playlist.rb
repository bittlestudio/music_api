class Playlist < ApplicationRecord
  include HasName

  has_and_belongs_to_many :songs, -> { uniq }
  validates :name, presence:true

end
