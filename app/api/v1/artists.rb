module V1
  class Artists < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)
        entity.as_json(:include => :albums)
      end
    end

    params :bio do
      optional :bio, type: String, allow_blank: false
    end

    resource :artists do

      desc "Return list of artists"
      get do
        format_entity Artist.all
      end

      desc "Return one artist"
      params do
        use :id
      end
      get ':id' do
        format_entity show(Artist.find_by_id(params[:id]))
      end

      desc "Add an artist"
      params do
        use :bio
        use :name
        optional :albums, type: JSON
      end
      post do
        params[:albums]
        o = create(Artist.new(name: params[:name], bio: params[:bio])) { |a|
          add_to_collection(:albums, a.albums) { |item|
            Album.new(name: item.name)
          }
          a.save
        }
        format_entity o
      end

      desc "Update an artist"
      params do
        use :id
        use :optional_name
        use :bio
        optional :albums, type: JSON
      end
      put ':id' do
        params[:albums]

        o = update(Artist.find_by_id(params[:id])) { |a|
          add_to_collection(:albums, a.albums) { |item|
            Album.new(name: item.name)
          }
          a.update strong_params(params, :name, :bio)
        }
        format_entity o
      end

      desc "Delete an artist"
      params do
        use :id
      end
      delete ':id' do
        delete(Artist.find_by_id(params[:id])) {|a|
            a.destroy
        }
      end
    end
  end
end