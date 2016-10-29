module APIHelpers
  extend Grape::API::Helpers

  params :name do
    requires :name, type: String, allow_blank: false
  end

  params :optional_name do
    optional :name, type: String, allow_blank: false
  end

  params :id do
    requires :id, type: Integer
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

  def create(entity)
    if yield entity
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