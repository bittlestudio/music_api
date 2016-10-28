module V1
    class Base < Grape::API

      version 'v1', using: :path
      #format :json
      content_type :json, 'application/json'
      content_type :xml, 'application/xml'

      default_format :json


      mount V1::Artists

    end
end