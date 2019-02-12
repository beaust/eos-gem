require 'faraday'
require 'json'

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

    # Transacts against the EOS blockchain. For reasons I hate,
    # this shells out to Node, so we have a dependency on a
    # Node.js runtime (8+). More in `bridge.js`.
    def transact(txn)
      bridge = File.expand_path(File.join('..', '..', 'bridge.js'), File.dirname(__FILE__))
      `node #{bridge} "#{@protocol}://#{@host}:#{@port}" #{@signatures.first} #{txn[:account]} #{txn[:action]} #{txn[:invoice_id]} #{txn[:amount]}`
    end

    # Serializes JSON to hex string.
    def serialize(transaction)
      action = transaction[:actions][0]

      resp = @conn.post do |req|
        req.url '/v1/chain/abi_json_to_bin'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          code: action[:account],
          action: action[:name],
          args: transaction[:data]
        }.to_json
      end

      JSON.parse(resp.body)['binargs']
    end

    # Inflates hex string back to JSON.
    def deserialize(code, action, binargs)
      resp = @conn.post do |req|
        req.url '/v1/chain/abi_bin_to_json'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          code: code,
          action: action,
          binargs: binargs
        }.to_json
      end

      JSON.parse(resp.body)['args']
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
      @signatures = options[:signatures]
    end

    def default_connection
      Faraday.new(url: "#{@protocol}://#{@host}:#{@port}") do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
