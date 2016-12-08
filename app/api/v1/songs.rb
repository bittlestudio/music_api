module V1
  class Songs < Grape::API

    helpers APIHelpers

    helpers do
      def format_entity(entity)

        if entity.respond_to? :each
          entity.each do |song|
            song.album.data_url = get_album_uploads_url
          end
        else
          entity.album.data_url = get_album_uploads_url
        end

        #entity.as_json(include: {album: {methods: :full_album_url, except: [:artist_id, :album_art], include: :artist}}, except: [:album_id, :seconds], methods: :duration)
        present entity, with: V1::Entities::Song, type: :song_full
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
        format_entity check_entity_exists(Song.find_by_id(params[:id]))
      end

      desc "Adds a song."
      params do
        use :name
        requires :seconds, type:Integer, desc: "Duration of song in seconds."
        requires :album_id, type:Integer, desc: "ID of the album the song belongs to."
      end
      post do
        song = create(Song.new(name: params[:name], album_id: params[:album_id], seconds: params[:seconds])){ |o|
          o.save
        }
        format_entity song
      end

      desc "Updates a song."
      params do
        use :id
        use :optional_name
        optional :seconds, type:Integer, desc: "Duration of song in seconds."
        optional :album_id, type:Integer, desc: "ID of the album the song belongs to."
      end
      put ':id' do
        song = update(Song.find_by_id(params[:id])) { |o|
          o.update strong_params(params, :name, :album_id, :seconds)
        }
        format_entity song
      end

      desc "Deletes a song."
      params do
        use :id
      end
      delete ':id' do
        delete(Song.find_by_id(params[:id])) {|song|
          song.destroy
        }
      end

    end
  end
end