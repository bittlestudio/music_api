module V1
  class Playlists < Grape::API

    helpers APIHelpers

    helpers do
      # 0 you should check out Grape Entity. it does a great job of what this method
      #   does, and much more
      #### Didn't know about it. Will do!
      def format_entity(entity)
        entity.as_json(include: [:songs])
      end
    end

    resource :playlists do

      desc "Returns list of playlists."
      get do
        format_entity Playlist.all
      end

      desc "Returns one playist."
      params do
        use :id
      end
      get ':id' do
        format_entity check_entity_exists(Playlist.find_by_id(params[:id]))
      end

      desc "Adds a playlist."
      params do
        use :name
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts song ID."
      end
      post do
        playlist = create(Playlist.new(name: params[:name])){ |o|
          if params[:songs]
            params[:songs].each do |song|
              aux_song = Song.find_by_id(song.id)
              raise "Song does not exist" unless aux_song
              o.songs << aux_song
            end
          end

          o.save
        }
        format_entity playlist
      end

      desc "Updates a playlist."
      params do
        use :id
        use :optional_name
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts song ID."
      end
      put ':id' do
        playlist = update(Playlist.find_by_id(params[:id])) { |o|
          if params[:songs]
            params[:songs].each do |song|
              aux_song = Song.find_by_id(song.id)
              raise "Song does not exist" unless aux_song
              o.songs << aux_song
            end
          end
          o.update strong_params(params, :name)
        }
        format_entity playlist
      end

      desc "Deletes a playlist."
      params do
        use :id
      end
      delete ':id' do
        delete(Playlist.find_by_id(params[:id])) {|playlist|
          playlist.destroy
        }
      end

      desc "Deletes songs from playlist."
      params do
        use :id
        requires :songs, type: JSON, desc: "Collection of songs to delete. Accepts song ID."
      end
      delete ':id/songs' do

        delete(Playlist.find_by_id(params[:id])) do |playlist|
          params[:songs].each do |song|
            aux_song = Song.find_by_id(song.id)
            raise "Song does not exist" unless aux_song
            playlist.songs.delete(aux_song)
          end
        end

      end

    end
  end
end
