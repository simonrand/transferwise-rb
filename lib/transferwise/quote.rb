module Transferwise
  class Quote < APIResource
    def self.create(params = {}, opts = {})
      response = Transferwise::Request.request(:post, collection_url(nil, api_version: 'v3'), params, opts)
      convert_to_transferwise_object(response)
    end
  end
end
