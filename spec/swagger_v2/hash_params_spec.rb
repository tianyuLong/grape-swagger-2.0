require 'spec_helper'

describe 'Hash Params' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :a_hash, type: Hash
      end
      post :splines do
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/splines'
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['paths']['/splines']['post']['parameters']
  end

  it 'declares hash types as object' do
    expect(subject).to eq [
      {"in"=>"formData", "name"=>"a_hash", "description"=>nil, "type"=>"object", "required"=>true, "allowMultiple"=>false}
    ]
  end
end
