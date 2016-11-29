module V1
  module Entities

    class Song < V1::Entities::Base

      expose :duration
      expose :album, using: V1::Entities::Album, if: { type: :song_full }

    end
  end
end
