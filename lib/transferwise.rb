# Transferwise Ruby bindings
require 'open-uri'
require 'oauth2'
require 'rest-client'
require 'json'

# Version
require "transferwise/version"

# Oauth2 Authentication
require "transferwise/oauth"

# Resources
require 'transferwise/transferwise_object'
require 'transferwise/api_resource'
require 'transferwise/profile'
require 'transferwise/quote'
require 'transferwise/account'
require 'transferwise/transfer'
require 'transferwise/util'
require 'transferwise/request'
require 'transferwise/borderless_account'
require 'transferwise/borderless_account/balance_currency'
require 'transferwise/borderless_account/statement'
require 'transferwise/borderless_account/transaction'

# Errors
require 'transferwise/transferwise_error'

module Transferwise

  class << self
    attr_accessor :mode
    attr_accessor :access_token

    def api_base
      live_url = 'https://api.transferwise.com'
      test_url = 'https://api.sandbox.transferwise.tech'
      @api_base ||= mode == 'live' ? live_url : test_url
    end
  end
end
