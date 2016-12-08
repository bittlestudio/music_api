module V1
  class Albums < Grape::API

    helpers APIHelpers

    helpers do

      def format_entity(entity)

        if entity.respond_to? :each
          entity.each do |album|
            album.data_url = get_album_uploads_url
          end
        else
          entity.data_url = get_album_uploads_url
        end
        #original = entity.as_json(include: [:artist, {songs:{except: [:album_id, :seconds], methods: :duration}}], except: [:artist_id, :album_art], methods: :full_album_url)
        present entity, with: V1::Entities::Album, type: :album_full
      end

    end

    resource :albums do

      desc "Returns list of albums."
      get do
        format_entity Album.all
      end

      desc "Returns one album."
      params do
        use :id
      end
      get ':id' do
        format_entity check_entity_exists(Album.find_by_id(params[:id]))
      end

      desc "Adds an album."
      params do
        use :name
        requires :artist_id, type: Integer, desc: "ID of the artist this album belongs to."
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts name and duration in seconds."
        optional :album_art, type:File, desc: "Album cover file. Must be .jpg, .png or .gif. Maximum size: 256 KB."
      end
      post do
        # -1 use semantic names for variables, for maintainability.
        # "album" and "song" are better than "o" and "a"
        #### Agree.
        album = create(Album.new(name: params[:name], artist_id: params[:artist_id])){ |o|

          o.cover = params[:album_art]

          # -1 this is more procedural than OO. it's essentially a C function. passing a pointer
          # and modifying the data instead of having an object own operations in its own domain
          #
          # pseudo code examples of alternatives:
          #
          # songs.each do |song|
          #   album.add_song Song.new(...)
          # end
          #
          # or:
          # songs.each do |song|
          #   album.songs << Song.new(...)
          # end
          #### Agree. I tried to dry up some code, but I could have done it differently, starting by using the model layer.
          #### I guess I just got enthusiastic with helpers and yield :P
          if params[:songs]
            params[:songs].each do |song|
              o.songs << Song.new(name: song.name, seconds: song.seconds)
            end
          end

          if o.save
            if o.cover
              o.add_cover APP_CONFIG['uploads_path'] + 'albums/'
              o.save
            end
          end
        }
        format_entity album
      end

      desc "Updates an album."
      params do
        use :id
        use :optional_name
        optional :artist_id, type: Integer, desc: "ID of the artist this album belongs to."
        optional :songs, type: JSON, desc: "Collection of songs of this album. Accepts name and duration in seconds."
        optional :album_art, type:File, desc: "Album cover file. Must be .jpg, .png or .gif. Maximum size: 256 KB."
      end
      put ':id' do
        album = update(Album.find_by_id(params[:id])) { |o|

          o.cover = params[:album_art]

          if params[:songs]
            params[:songs].each do |song|
              o.songs << Song.new(name: song.name, seconds: song.seconds)
            end
          end

          # -1 this would be a great thing to DRY up into its own method since you use it above also
          #### Definitely. I did create an upload file method though, but I could have gone a little bit further.

          o.update_cover APP_CONFIG['uploads_path'] + 'albums/'
          o.update strong_params(params, :name, :artist_id)
        }
        #params.album_art.type
        #params.avatar.type     # => 'image/png'
        format_entity album
      end

      desc "Deletes an album."
      params do
        use :id
      end
      delete ':id' do
        delete(Album.find_by_id(params[:id])) {|album|
          album.destroy
        }
      end
    end
  end
end
