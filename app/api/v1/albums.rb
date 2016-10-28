module V1
  class Albums < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)
        entity.as_json(include: [:artist, :songs], except: :artist_id)
      end
    end

    resource :albums do

      desc "Return list of albums"
      get do
        format_entity Album.all
      end

      desc "Return one album"
      params do
        use :id
      end
      get ':id' do
        format_entity show(Album.find_by_id(params[:id]))
      end

      desc "Add an album"
      params do
        requires :artist_id, type: Integer
        use :name
        optional :songs, type: JSON
      end
      post do
        o = create(Album.new(name: params[:name], artist_id: params[:artist_id])){ |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }
          a.save
        }
        format_entity o
      end

      desc "Update an album"
      params do
        use :id
        use :optional_name
        optional :artist_id, type: Integer
        optional :songs, type: JSON
      end
      put ':id' do
        o = update(Album.find_by_id(params[:id])) { |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }
          a.update strong_params(params, :name, :artist_id)
        }
        format_entity o
      end

      desc "Delete an album"
      params do
        use :id
      end
      delete ':id' do
        delete(Album.find_by_id(params[:id])) {|a|
          a.destroy
        }
      end
    end
  end
end