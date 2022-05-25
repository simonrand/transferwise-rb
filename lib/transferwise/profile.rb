module Transferwise
  class Profile < APIResource
    def self.collection_url(resource_id = nil)
      "/v2/#{CGI.escape(class_name.downcase)}s"
    end

    def self.fund(profile_id, transfer_id, headers)
      url = "#{resource_url(profile_id, api_version: 'v3')}/transfers/#{transfer_id}/payments"

      params = { 'type' => 'BALANCE' }
      response = Request.request(:post, url, params, headers)
      convert_to_transferwise_object(response)
    end

    def self.list(filters = {}, headers = {}, resource_id = nil)
      response = Transferwise::Request.request(:get, collection_url(resource_id), filters, headers)
      convert_to_transferwise_object(response)
    end
  end
end
