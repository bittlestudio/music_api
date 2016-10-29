module V1
  class Albums < Grape::API

    UPLOADS_PATH = '/uploads/albums/'

    helpers APIHelpers

    helpers do
      def format_entity(entity)
        o = entity.as_json(include: [:artist, {songs:{except: :album_id}}], except: [:artist_id])

        if (o['album_art'])
          path = request.env['rack.url_scheme'] + '://' + request.env['HTTP_HOST'] + UPLOADS_PATH + o['id'].to_s + '/'
          o['album_art'] = path + o['album_art']
        end
        o
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
        optional :album_art, type:File
        optional :songs, type: JSON
      end
      post do
        o = create(Album.new(name: params[:name], artist_id: params[:artist_id])){ |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }

          if a.save
            if params[:album_art]
              file = ActionDispatch::Http::UploadedFile.new(params[:album_art])
              UploadHelper::upload_file("public/#{UPLOADS_PATH}#{a.id}", file)
              a.album_art = file.original_filename
              a.save
            else
              true
            end
          end
        }
        format_entity o
      end

      desc "Update an album"
      params do
        use :id
        use :optional_name
        optional :artist_id, type: Integer
        optional :songs, type: JSON
        optional :album_art, type:File
      end
      put ':id' do
        o = update(Album.find_by_id(params[:id])) { |a|
          add_to_collection(:songs, a.songs) { |item|
            Song.new(name: item.name, duration: item.duration)
          }

          if params[:album_art]
            file = ActionDispatch::Http::UploadedFile.new(params[:album_art])
            path = "public/#{UPLOADS_PATH}#{a.id}"

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