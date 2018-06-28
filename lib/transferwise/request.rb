module Transferwise
  class Request
    def self.api_url(url = '')
      Transferwise.api_base + url
    end

    def self.request(method, url, params={}, headers={})
      url = api_url(url)
      access_token = headers.delete(:access_token) || Transferwise.access_token
      request_opts = {
        url: url,
        method: method,
        headers: request_headers(access_token).update(headers)
      }

      if method == :get
        request_opts[:headers].update(params: params)
      else
        request_opts.update(payload: params.to_json)
      end

      response = execute_request(request_opts)
      parse(response)
    end

    # Private class methods

    def self.request_headers(access_token)
      {
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json'
      }
    end
    private_class_method :request_headers

    def self.execute_request(request_opts)
      begin
        response = RestClient::Request.execute(request_opts)
      rescue => e
        if e.is_a?(RestClient::Exception)
          response = handle_error(e, request_opts)
        else
          raise
        end
      end
      response
    end
    private_class_method :execute_request

    def self.parse(response)
      begin
        response = JSON.parse(response.body)
      rescue JSON::ParserError
        raise handle_parse_error(response.code, response.body)
      end
      response
    end
    private_class_method :parse

    def self.handle_error(e, request_opts)
      if e.is_a?(RestClient::ExceptionWithResponse) && e.response
        handle_api_error(e.response)
      else
        handle_restclient_error(e, request_opts)
      end
    end
    private_class_method :handle_error

    def self.handle_api_error(resp)
      error_obj = parse(resp).with_indifferent_access
      error_message = error_obj['error'].presence || error_obj['errors']&.map{|e| e["message"]}&.join(', ') || error_obj.to_s
      if Transferwise::STATUS_CLASS_MAPPING.include?(resp.code)
        raise "Transferwise::#{Transferwise::STATUS_CLASS_MAPPING[resp.code]}".constantize.new(error_params(error_message, resp, error_obj))
      else
        raise Transferwise::TransferwiseError.new(error_params(error_message, resp, error_obj))
      end
    end
    private_class_method :handle_api_error

    def self.handle_restclient_error(e, request_opts)
      connection_message = "Please check your internet connection and try again. "

      case e
      when RestClient::RequestTimeout
        message = "Could not connect to Transferwise (#{request_opts[:url]}). #{connection_message}"
      when RestClient::ServerBrokeConnection
        message = "The connection to the server (#{request_opts[:url]}) broke before the " \
          "request completed. #{connection_message}"
      else
        message = "Unexpected error communicating with Transferwise. "
      end

      raise Transferwise::APIConnectionError.new({message: "#{message} \n\n (Error: #{e.message})"})
    end
    private_class_method :handle_restclient_error

    def self.handle_parse_error(rcode, rbody)
      Transferwise::ParseError.new({
        message: "Not able to parse because of invalid response object from API: #{rbody.inspect} (HTTP response code was #{rcode})",
        http_status: rcode,
        http_body: rbody
      })
    end
    private_class_method :handle_parse_error

    def self.error_params(error, resp, error_obj)
      {
        message: error,
        http_status: resp.code,
        http_body: resp.body,
        json_body: error_obj,
        http_headers: resp.headers
      }
    end
    private_class_method :error_params
  end
end
