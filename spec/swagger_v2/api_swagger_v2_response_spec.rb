require 'spec_helper'

describe 'exposing' do
  include_context "the api entities"

  before :all do
    module TheApi
      class ResponseApi < Grape::API
        format :json

        desc 'This returns something',
          params: Entities::UseResponse.documentation,
          failure: [{code: 400, message: 'NotFound', model: Entities::ApiError}]
        post '/params_response' do
          { "declared_params" => declared(params) }
        end

        desc 'This returns something',
          entity: Entities::UseResponse,
          failure: [{code: 400, message: 'NotFound', model: Entities::ApiError}]
        get '/entity_response' do
          { "declared_params" => declared(params) }
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheApi::ResponseApi
  end

  describe "uses entity as response object" do
    subject do
      get '/swagger_doc/entity_response'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject).to eql({
        "info"=>{"title"=>"API title", "version"=>"v1"},
        "swagger"=>"2.0",
        "produces"=>["application/json"],
        "host"=>"example.org",
        "schemes"=>["https", "http"],
        "paths"=>{
          "/entity_response"=>{
            "get"=>{
              "produces"=>["application/json"],
              "responses"=>{
                "200"=>{"description"=>"This returns something", "schema"=>{"$ref"=>"#/definitions/UseResponse"}},
                "400"=>{"description"=>"NotFound", "schema"=>{"$ref"=>"#/definitions/ApiError"}}}}}},
        "definitions"=>{
          "ResponseItem"=>{
            "type"=>"object",
            "properties"=>{"id"=>{"type"=>"integer"}, "name"=>{"type"=>"string"}}},
          "UseResponse"=>{
            "type"=>"object",
            "properties"=>{"description"=>{"type"=>"string"}, "$responses"=>{"$ref"=>"#/definitions/ResponseItem"}}},
          "ApiError"=>{
            "type"=>"object",
            "properties"=>{"code"=>{"type"=>"integer"}, "message"=>{"type"=>"string"}}}
      }})
    end
  end

  describe "uses params as response object" do
    subject do
      get '/swagger_doc/params_response'
      JSON.parse(last_response.body)
    end


    # usage of grape-entity 0.4.8 preduces a wrong definition for ParamsResponse, this one:
    # "definitions" => {
    #   "ParamsResponse"=>{"properties"=>{"description"=>{"type"=>"string"}}},
    #   "ApiError"=>{"type"=>"object", "properties"=>{"code"=>{"type"=>"integer"}, "message"=>{"type"=>"string"}}}
    # }
    # (`$response` property is missing)

    specify do
      expect(subject).to eql({
        "info"=>{"title"=>"API title", "version"=>"v1"},
        "swagger"=>"2.0",
        "produces"=>["application/json"],
        "host"=>"example.org",
        "schemes"=>["https", "http"],
        "paths"=>{
          "/params_response"=>{
            "post"=>{
              "produces"=>["application/json"],
              "parameters"=>[
                {"in"=>"formData", "name"=>"description", "description"=>nil, "type"=>"string", "required"=>false, "allowMultiple"=>false},
                {"in"=>"formData", "name"=>"$responses", "description"=>nil, "type"=>"string", "required"=>false, "allowMultiple"=>true}],
              "responses"=>{
                "201"=>{"description"=>"This returns something", "schema"=>{"$ref"=>"#/definitions/ParamsResponse"}},
                "400"=>{"description"=>"NotFound", "schema"=>{"$ref"=>"#/definitions/ApiError"}}}
        }}},
        "definitions"=>{
          "ParamsResponse"=>{"properties"=>{"description"=>{"type"=>"string"}, "$responses"=>{"type"=>"string"}}},
          "ApiError"=>{"type"=>"object", "properties"=>{"code"=>{"type"=>"integer"}, "message"=>{"type"=>"string"}}}
      }})
    end
  end

end
