module Transferwise
  class Profile < APIResource
    def self.fund(profile_id, transfer_id, headers)
      url = "#{resource_url(profile_id, api_version: 'v3')}/transfers/#{transfer_id}/payments"

      params = { 'type' => 'BALANCE' }
      response = Request.request(:post, url, params, headers)
      convert_to_transferwise_object(response)
    end

    def self.balances(profile_id, headers)
      url = "#{resource_url(profile_id, api_version: 'v4')}/balances"

      response = Request.request(:get, url, { types: 'STANDARD' } , headers)
      convert_to_transferwise_object(response)
    end
  end
end
