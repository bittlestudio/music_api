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
        format_entity show(Playlist.find_by_id(params[:id]))
      end

      desc "Adds a playlist."
      params do
        use :name
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts song ID."
      end
      post do
        o = create(Playlist.new(name: params[:name])){ |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.find_by_id(item.id)
          }
          a.save
        }
        format_entity o
      end

      desc "Updates a playlist."
      params do
        use :id
        use :optional_name
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts song ID."
      end
      put ':id' do
        o = update(Playlist.find_by_id(params[:id])) { |a|
          add_to_collection(:songs, a.songs) { |item|
            s = Song.find_by_id(item.id)
            raise "Song does not exist" unless s
            s
          }
          a.update strong_params(params, :name)
        }
        format_entity o
      end

      desc "Deletes a playlist."
      params do
        use :id
      end
      delete ':id' do
        delete(Playlist.find_by_id(params[:id])) {|a|
          a.destroy
        }
      end

      desc "Deletes songs from playlist."
      params do
        use :id
        #requires :song_id, type: Integer
        requires :songs, type: JSON, desc: "Collection of songs to delete. Accepts song ID."
      end
      delete ':id/songs' do

        delete(Playlist.find_by_id(params[:id])) do |p|
          params[:songs].each do |item|
            s = Song.find_by_id(item.id)
            raise "Song does not exist" unless s
            p.songs.delete(Song.find_by_id(s.id))
          end
        end

      end

    end
  end
end
