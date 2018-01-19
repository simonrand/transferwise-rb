module Transferwise

  STATUS_CLASS_MAPPING = {
    400 => "InvalidRequestError",
    404 => "InvalidRequestError",
    401 => "AuthenticationError"
  }

  class TransferwiseError < StandardError
    attr_reader :message, :http_status, :http_body, :http_headers, :json_body

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      "#{status_string}#{@message}"
    end
  end

  class APIConnectionError < TransferwiseError
  end

  class APIError < TransferwiseError
  end

  class AuthenticationError < TransferwiseError
  end

  class InvalidRequestError < TransferwiseError
  end

  class ParseError < TransferwiseError
  end

end
