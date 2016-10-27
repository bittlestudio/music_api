class AddSongsAndPlaylistsToPlaylistsSong < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :playlists_songs, :songs, on_delete: :cascade
    add_foreign_key :playlists_songs, :playlists, on_delete: :cascade
  end
end
