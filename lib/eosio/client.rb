require 'faraday'
require 'json'

require_relative './serializer'

# Module housing all logic for interacting with the EOS blockchain.
module EOSIO
  # Thrown if connection details (such as host) are missing.
  class ConnectionError < StandardError; end

  # Thrown if authorization details (specifically, signatures) are missing.
  class AuthorizationError < StandardError; end

  # Client used to connect to the EOS blockchain.
  class Client
    attr_reader :conn

    def initialize(options)
      configure options
      @conn = default_connection
      @chain_id ||= get_info['chain_id']
    end

    # Returns a hash describing the JSON response.
    def get_table_rows(options, limit = 10, json = true)
      resp = @conn.post do |req|
        req.url '/v1/chain/get_table_rows'
        req.headers['Content-Type'] = 'application/json'
        req.body = options.merge(limit: limit, json: json).to_json
      end

      JSON.parse resp.body
    end

    # Fetches the ABI for the specified contract.
    def get_abi(account_name)
      resp = @conn.post do |req|
        req.url '/v1/chain/get_abi'
        req.headers['Content-Type'] = 'application/json'
        req.body = { account_name: account_name }.to_json
      end

      JSON.parse resp.body
    end

    # Fetches metadata about the current EOS network connection.
    def get_info
      resp = @conn.get { |req| req.url '/v1/chain/get_info' }

      JSON.parse resp.body
    end

    # Takes a transaction hash and optional TAPoS data (`blocks_behind`,
    # `expire_seconds`) and creates a transaction against the EOS blockchain.
    def transact(txn, blocks_behind = 3, expire_seconds = 30)
      serializer = Serializer.new
      serializer.serialize_tx(txn.merge(blocks_behind: blocks_behind, expire_seconds: expire_seconds))

      @conn.post do |req|
        req.url '/v1/chain/push_transaction'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          signatures: @signatures,
          compression: 0,
          packed_context_free_data: '',
          packed_trx: serializer.array_to_hex
        }.to_json
      end
    end

    private

    def configure(options)
      raise ConnectionError, 'host required (e.g. jungle2.cryptolions.io)' unless options[:host]
      raise AuthorizationError, 'at least one signature is required' unless options[:signatures]

      @blockchain = options[:blockchain] || 'eos'
      @protocol = options[:protocol] || 'http'
      @host = options[:host]
      @chain_id = options[:chain_id]
      @port = options[:port] || 80
      @signature = options[:signatures]
    end

    def default_connection
      Faraday.new(url: "#{@protocol}://#{@host}:#{@port}") do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
