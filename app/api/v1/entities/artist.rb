module V1
  module Entities

    class Artist < V1::Entities::Base

      expose :bio
      expose :albums, using: V1::Entities::Album, if: {type: :artist_full}

    end
  end
end
