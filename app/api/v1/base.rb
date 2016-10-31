module V1
    class Base < Grape::API

      version 'v1', using: :path
      prefix :api
      #format :json
      content_type :json, 'application/json'
      content_type :xml, 'application/xml'

      default_format :json

      mount V1::Artists
      mount V1::Albums
      mount V1::Songs
      mount V1::Playlists

      add_swagger_documentation(
          info: {
              title: "Music API",
              description: "This test API lets you manage most common resouces of a basic music service API.",
              contact_name: "Martin Zaleski",
              contact_email: "martinza@gmail.com"
          },
          api_version: "v1",
          hide_documentation_path: true,
          hide_format: true
      )

    end
end