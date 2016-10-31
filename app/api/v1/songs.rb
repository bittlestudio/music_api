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

      desc "Returns list of songs."
      get do
        format_entity Song.all
      end

      desc "Returns one song."
      params do
        use :id
      end
      get ':id' do
        format_entity show(Song.find_by_id(params[:id]))
      end

      desc "Adds a song."
      params do
        use :name
        requires :duration, type:Integer, desc: "Duration of song in seconds."
        requires :album_id, type:Integer, desc: "ID of the album the song belongs to."
      end
      post do
        o = create(Song.new(name: params[:name], album_id: params[:album_id], duration: params[:duration])){ |a|
          a.save
        }
        format_entity o
      end

      desc "Updates a song."
      params do
        use :id
        use :optional_name
        optional :duration, type:Integer, desc: "Duration of song in seconds."
        optional :album_id, type:Integer, desc: "ID of the album the song belongs to."
      end
      put ':id' do
        o = update(Song.find_by_id(params[:id])) { |a|
          a.update strong_params(params, :name, :album_id, :duration)
        }
        format_entity o
      end

      desc "Deletes a song."
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