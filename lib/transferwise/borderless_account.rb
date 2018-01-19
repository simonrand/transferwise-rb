module Transferwise
  class BorderlessAccount < APIResource
    def self.collection_url(resource_id = nil)
      "/#{API_VERSION}/borderless-accounts"
    end

    def self.convert(borderless_account_id, quote_id, headers)
      url = "/#{resource_url(borderless_account_id)}/conversions"

      params = { 'quoteId' => quote_id }
      response = Request.request(:post, url, params, headers)
      convert_to_transferwise_object(response)
    end
  end
end
