module V1
  module Entities

    class Album < V1::Entities::Base

      expose :full_album_url
      expose :artist, using: V1::Entities::Artist, if: { type: :album_full }

      expose :songs, using: V1::Entities::Song, if: { type: :album_full }, unless: {collection: true}

    end
  end
end
