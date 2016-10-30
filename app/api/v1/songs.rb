module V1
  class Songs < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)

        if entity.respond_to? :each
          entity.each do |e|
            set_album_url (e.album)
          end
        else
          set_album_url (entity.album)
        end

        entity.as_json(include: {album: {methods: :full_album_url, except: [:artist_id, :album_art], include: :artist}}, except: :album_id)
      end
    end

    resource :songs do

      desc "Return list of songs"
      get do
        format_entity Song.all
      end

      desc "Return one song"
      params do
        use :id
      end
      get ':id' do
        format_entity show(Song.find_by_id(params[:id]))
      end

      desc "Add a song"
      params do
        use :name
        requires :duration, type:Integer
        requires :album_id, type:Integer
      end
      post do
        o = create(Song.new(name: params[:name], album_id: params[:album_id], duration: params[:duration])){ |a|
          a.save
        }
        format_entity o
      end

      desc "Update a song"
      params do
        use :id
        use :optional_name
        optional :duration, type:Integer
        optional :album_id, type:Integer
      end
      put ':id' do
        o = update(Song.find_by_id(params[:id])) { |a|
          a.update strong_params(params, :name, :album_id, :duration)
        }
        format_entity o
      end

      desc "Delete a song"
      params do
        use :id
      end
      delete ':id' do
        delete(Song.find_by_id(params[:id])) {|a|
          a.destroy
        }
      end

    end
  end
end