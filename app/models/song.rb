class Song < ApplicationRecord
  include HasName

  has_and_belongs_to_many :playlists
  belongs_to :album
  validates :name, presence:true
  # +1 good validation
  validates :duration, presence:true, numericality: { only_integer: true }

  # 0 instead of overriding duration, which matches the DB column, and then
  #   providing seconds as a separate getter, I would just make seconds the
  #   DB column name and make duration the formated method.
  #   alternative would be to keep the column name as-is but call the
  #   duration method duration_min_sec or something like that.
  def duration
    Time.at(self[:duration]).strftime("%M:%S") if self[:duration]
  end

  def seconds
    self[:duration]
  end
end
