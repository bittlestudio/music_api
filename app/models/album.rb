class Album < ApplicationRecord
  include HasName, HasFiles

  attr_reader :cover, :data_url

  has_many :songs, dependent: :destroy
  belongs_to :artist
  validates :name, presence:true

  def data_url=(value)
    @data_url = value + self.id.to_s + '/'
  end

  def full_album_url
    if self.data_url && self.album_art
      self.data_url + self.album_art
    end
  end

  def cover=(file)
    if file
      validate_mime_type file.type, [Mime[:jpeg], Mime[:png], Mime[:gif]] if file
      validate_size file, 256
      @cover = file
    end
  end

  def add_cover(path)
    if @cover
      path = path + self.id.to_s + '/'
      upload_cover path
    end
  end

  def update_cover(path)
    if @cover
      path = path + self.id.to_s + '/'
      delete_file path, album_art
      upload_cover path
    end
  end

  private
  def upload_cover(path)
    file = upload_file path, @cover
    self.album_art = file.original_filename
  end
end