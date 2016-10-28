module APIHelpers
  extend Grape::API::Helpers

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

  def create
    a = yield
      #location = v1_artists_path(id: a.id)
      #header 'Location', Rails.application.routes.url_helpers.artist_url (a)
      #header 'Location', location
    rescue Exception => msg
      error! msg, 422
  end

  def update(entity)
    a = show entity

    if yield a
      a
    else
      error!(a.errors, 422)
    end
    rescue Exception => msg
      error! msg, 422
  end

  def delete(entity)
    a = show entity
    yield a
    status 204
    rescue Exception => msg
      error! msg, 422
  end
end