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

        #entity.as_json(:include => {albums: {except: [:artist_id, :album_art], methods: :full_album_url}})
        present entity, with: V1::Entities::Artist, type: :artist_full
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
        # +1 good use of helpers throughout for params blocks
        use :id
      end
      get ':id' do
        format_entity check_entity_exists(Artist.find_by_id(params[:id]))
      end

      desc "Adds an artist."
      params do
        use :bio
        use :name
        optional :albums, type: JSON, desc: "Collection of albums of this artist. Accepts name."
      end
      post do
        params[:albums]
        artist = create(Artist.new(name: params[:name], bio: params[:bio])) { |o|
          if params[:albums]
            params[:albums].each do |album|
              o.albums << Album.new(name: album.name)
            end
          end

          o.save
        }
        format_entity artist
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

        artist = update(Artist.find_by_id(params[:id])) { |o|
          if params[:albums]
            params[:albums].each do |album|
              o.albums << Album.new(name: album.name)
            end
          end

          o.update strong_params(params, :name, :bio)
        }
        format_entity artist
      end

      desc "Deletes an artist."
      params do
        use :id
      end
      delete ':id' do
        delete(Artist.find_by_id(params[:id])) {|artist|
          artist.destroy
        }
      end
    end
  end
end
