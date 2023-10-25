module Transferwise
  class Quote < APIResource
    API_VERSION = 'v3'

    def self.collection_url(resource_id = nil, api_version: API_VERSION)
      super(resource_id, api_version:)
    end

    def self.create_authenticated(profile_id, params = {}, opts = {})
      url = "/#{API_VERSION}/profiles/#{profile_id}/quotes"
      response = Transferwise::Request.request(:post, url, params, opts)
      convert_to_transferwise_object(response)
    end
  end
end
