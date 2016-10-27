class Album < ApplicationRecord
  include HasName

  has_many :songs, dependent: :destroy
  belongs_to :artist
  validates :name, presence:true

end