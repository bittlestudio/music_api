class AddAlbumToSong < ActiveRecord::Migration[5.0]
  def change
    add_index :songs, :album_id
    add_foreign_key :songs, :albums, on_delete: :cascade
  end
end
