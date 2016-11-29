module V1
  module Entities

    class Playlist < V1::Entities::Base

      expose :songs, using: V1::Entities::Song

    end
  end
end
