module V1
  class Artists < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)

        if entity.respond_to? :each
          entity.each do |e|
            e.albums.each do |a|
              set_album_url (a)
            end
          end
        else
          entity.albums.each do |a|
            set_album_url (a)
          end
        end

        entity.as_json(:include => {albums: {except: [:artist_id, :album_art], methods: :full_album_url}})
      end

      params :bio do
        optional :bio, type: String, allow_blank: false, desc: "Biography text of the artist."
      end
    end

    resource :artists do

      desc "Returns list of artists."
      get do
        format_entity Artist.includes(:albums).all
      end

      desc "Returns one artist."
      params do
        use :id
      end
      get ':id' do
        format_entity show(Artist.find_by_id(params[:id]))
      end

      desc "Adds an artist."
      params do
        use :bio
        use :name
        optional :albums, type: JSON, desc: "Collection of albums of this artist. Accepts name."
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

      desc "Updates an artist."
      params do
        use :id
        use :optional_name
        use :bio
        optional :albums, type: JSON, desc: "Collection of albums of this artist. Accepts name."
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

      desc "Deletes an artist."
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