class Artist < ApplicationRecord
  include HasName

  has_many :albums, dependent: :destroy
  validates :name, presence:true

end
