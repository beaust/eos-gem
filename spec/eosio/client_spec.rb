require 'spec_helper'

describe EOSIO::Client do
  before do
    stub_request(:get, "http://jungle2.cryptolions.io/v1/chain/get_info").with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v0.15.4'
      }).to_return(status: 200, body: '{"chain_id":"e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473"}', headers: {})
  end

  describe '#new' do
    context 'when all connection details are provided' do
      it 'returns a connection object' do
        client = EOSIO::Client.new(host: 'jungle2.cryptolions.io', signatures: ['test'])

        expect(client).to be_an EOSIO::Client
        expect(client.conn).to be_a Faraday::Connection
      end
    end

    context 'when connection details are missing' do
      it 'throws an error when host is missing' do
        expect { EOSIO::Client.new(signatures: ['foobarbaz']) }.to raise_error EOSIO::ConnectionError
      end

      it 'throws an error when signatures are missing' do
        expect { EOSIO::Client.new(host: 'foobarbaz') }.to raise_error EOSIO::AuthorizationError
      end
    end
  end

  describe '#get_table_rows' do
    before do
      stub_request(:post, 'http://jungle2.cryptolions.io/v1/chain/get_table_rows').with(
        body: '{"table":"test","scope":"test","code":"test","limit":10,"json":true}',
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v0.15.4'
        }
      ).to_return(status: 200, body: '{"rows":["success"], "more":"false"}', headers: {})
    end

    subject(:client) { EOSIO::Client.new(host: 'jungle2.cryptolions.io', signatures: ['foobarbaz']) }

    it 'gets contract data' do
      response = client.get_table_rows(table: 'test', scope: 'test', code: 'test')
      expect(response['rows'][0]).to eq 'success'
    end
  end

  # @TODO, along with new tests for the serializer
  pending '#transact'
end
