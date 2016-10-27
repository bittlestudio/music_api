class AddArtistToAlbum < ActiveRecord::Migration[5.0]
  def change
    add_index :albums, :artist_id
    add_foreign_key :albums, :artists, on_delete: :cascade
  end
end
