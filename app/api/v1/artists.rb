module V1
  class Artists < Grape::API

    helpers APIHelpers

    resource :artists do

      desc "Return list of artists"
      get do
        Artist.all
      end

      desc "Return one artist"
      params do
        requires :id, type: Integer
      end
      get ':id' do
        show Artist.find_by_id(params[:id])
      end

      desc "Add an artist"
      params do
        optional :bio, type: String, allow_blank: false
        requires :name, type: String, allow_blank: false
      end
      post do
        create {Artist.create(name: params[:name], bio: params[:bio])}
      end

      desc "Update an artist"
      params do
        requires :id, type: Integer
        optional :bio, type: String, allow_blank: false
        optional :name, type: String, allow_blank: false
      end
      put ':id' do
        update(Artist.find_by_id(params[:id])) { |a| a.update strong_params(params, :name, :bio) }
      end

      desc "Delete an artist"
      params do
        requires :id, type: Integer
      end
      delete ':id' do
        delete(Artist.find_by_id(params[:id])) {|a|
            a.destroy
        }
      end
    end
  end
end