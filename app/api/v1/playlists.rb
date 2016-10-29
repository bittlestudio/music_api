module V1
  class Playlists < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)
        entity.as_json(include: [:songs])
      end
    end

    resource :playlists do

      desc "Return list of playlists"
      get do
        format_entity Playlist.all
      end

      desc "Return one playist"
      params do
        use :id
      end
      get ':id' do
        format_entity show(Playlist.find_by_id(params[:id]))
      end

      desc "Add a playlist"
      params do
        use :name
        optional :songs, type: JSON
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

      desc "Update a playlist"
      params do
        use :id
        use :optional_name
        optional :songs, type: JSON
      end
      put ':id' do
        o = update(Playlist.find_by_id(params[:id])) { |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.find_by_id(item.id)
          }
          a.update strong_params(params, :name)
        }
        format_entity o
      end

      desc "Delete a playlist"
      params do
        use :id
      end
      delete ':id' do
        delete(Playlist.find_by_id(params[:id])) {|a|
          a.destroy
        }
      end

      desc "Delete songs from playlist"
      params do
        use :id
        requires :song, type: JSON
      end
      delete ':id/songs' do
        Playlist.find_by_id(params[:id]).songs.delete(params[:song_id])
        status 204
      end

    end
  end
end