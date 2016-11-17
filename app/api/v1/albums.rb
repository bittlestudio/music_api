module V1
  class Albums < Grape::API

    helpers APIHelpers

    helpers do

      def format_entity(entity)

        if entity.respond_to? :each
          entity.each do |e|
            set_album_url (e)
          end
        else
          set_album_url (entity)
        end
        original = entity.as_json(include: [:artist, {songs:{except: :album_id}}], except: [:artist_id, :album_art], methods: :full_album_url)
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
        format_entity (show(Album.find_by_id(params[:id])))
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
        o = create(Album.new(name: params[:name], artist_id: params[:artist_id])){ |a|

          validate_mime_type params[:album_art].type, [Mime[:jpeg], Mime[:png], Mime[:gif]] if params[:album_art]
          validate_size params[:album_art], 256

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
          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }

          if a.save
            if params[:album_art]
              file = ActionDispatch::Http::UploadedFile.new(params[:album_art])
              UploadHelper::upload_file("#{album_uploads_path}#{a.id}", file)
              a.album_art = file.original_filename
              a.save
            else
              true
            end
          end
        }
        format_entity o
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
        o = update(Album.find_by_id(params[:id])) { |a|

          validate_mime_type params[:album_art].type, [Mime[:jpeg], Mime[:png], Mime[:gif]] if params[:album_art]
          validate_size params[:album_art], 256

          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }

          # -1 this would be a great thing to DRY up into its own method since you use it above also
          #### Definitely. I did create an upload file method though, but I could have gone a little bit further.
          if params[:album_art]
            file = ActionDispatch::Http::UploadedFile.new(params[:album_art])
            path = "#{album_uploads_path}#{a.id}"

            UploadHelper::delete_file(path, a.album_art) if a.album_art
            UploadHelper::upload_file(path, file)
            a.album_art = file.original_filename
          end
          a.update strong_params(params, :name, :artist_id)
        }
        #params.album_art.type
        #params.avatar.type     # => 'image/png'
        format_entity o
      end

      desc "Deletes an album."
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
