module V1
  module Entities

    class Base < Grape::Entity

      expose :id, :name, :created_at, :updated_at

    end
  end
end
