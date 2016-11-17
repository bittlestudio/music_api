module APIHelpers
  extend Grape::API::Helpers

  params :name do
    requires :name, type: String, allow_blank: false, desc: "Name of the item."
  end

  params :optional_name do
    optional :name, type: String, allow_blank: false, desc: "Name of the item."
  end

  params :id do
    requires :id, type: Integer, desc: "ID of item to retrieve."
  end

  # +1 shows familiarity with Ruby syntactic sugar (trailing unless clause) - can help code readability
  # -1 a lot of these are procedural methods that could be part of a model layer mixin or concern
  def validate_mime_type(type, validtypes)
    raise "Uploaded file MIME type is not valid. Valid types are #{validtypes.join ", "}" unless validtypes.include? type
  end

  def validate_size(file, maxsizekb)
    raise "Maximum upload size is #{maxsizekb.to_s}KB" unless File.size(file[:tempfile])<= maxsizekb*1024
  end

  def album_uploads_path
    APP_CONFIG['uploads_path'] + 'albums/'
  end

  def album_uploads_uri
    '/' + APP_CONFIG['uploads_uri'] + 'albums/'
  end

  # -1 this should be in the Album model, an Albums URL is a concern of Album
  def generate_album_url(id, filename)
    request.env['rack.url_scheme'] + '://' + request.env['HTTP_HOST'] + album_uploads_uri + id.to_s + '/'
  end

  # -1 this should be in the Album model, an Albums URL is a concern of Album
  def set_album_url (album)
    album.data_url = generate_album_url album.id, album.album_art
  end

  def strong_params(params, *keys)
    ret = {}
    keys.each do |key|
      ret[key] = params[key] if params[key]
    end
    ret
  end

  def show(entity)
    entity || error!(:not_found, 404)
  end

  # ? the purpose of this is to handle creation of an entity an do redirection in the same method?
  #   why not reply with the created entity directly and not redirect the consumer/client?
  #   is there a benefit to this that I'm missing?
  def create(entity)
    if yield entity
      header 'Location', request.url + '/' + entity.id.to_s
      entity
    else
      raise entity.errors.to_a.join ', '
    end

    rescue Exception => msg
      error! msg, 422

  end

  def update(entity)
    a = show entity

    if yield a
      a
    else
      raise a.errors.to_a.join ', '
    end
    rescue Exception => msg
      error! msg, 422
  end

  def delete(entity)
    a = show entity
    yield a
    # ? is this the proper HTTP status code if you're showing content to the client?
    status 204
    rescue Exception => msg
      error! msg, 422
  end

  def add_to_collection(key, collection)
    if params[key]
      params[key].each do |item|
        collection << yield(item)
      end
    end
  end
end
