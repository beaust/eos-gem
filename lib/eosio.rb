require 'faraday'
require 'json'

# Module housing all logic for interacting with the EOS blockchain.
module EOSIO
  # Thrown if connection details (such as host) are missing.
  class ConnectionError < StandardError; end

  # Client used to connect to the EOS blockchain.
  class Client
    attr_reader :conn

    def initialize(options)
      configure options
      @conn = default_connection
    end

    # Returns a hash describing the JSON response.
    def get_table_rows(options, limit = 10, json = true)
      resp = @conn.post do |req|
        req.url '/v1/chain/get_table_rows'
        req.headers['Content-Type'] = 'application/json'
        req.body = options.merge!(limit: limit, json: json).to_json
      end

      JSON.parse resp.body
    end

    private

    def configure(options)
      raise ConnectionError, 'host required (e.g. jungle2.cryptolions.io)' unless options[:host]

      @blockchain = options[:blockchain] || 'eos'
      @protocol = options[:protocol] || 'http'
      @host = options[:host]
      @port = options[:port] || 80
    end

    def default_connection
      Faraday.new(url: "#{@protocol}://#{@host}:#{@port}") do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
