require 'spec_helper'

describe EOSIO::Client do
  describe '#new' do
    context 'when all connection details are provided' do
      it 'returns a connection object' do
        client = EOSIO::Client.new(host: 'jungle2.cryptolions.io')

        expect(client).to be_an EOSIO::Client
        expect(client.conn).to be_a Faraday::Connection
      end
    end

    context 'when connection details are missing' do
      it 'throws an error' do
        expect { EOSIO::Client.new({}) }.to raise_error EOSIO::ConnectionError
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

    subject(:client) { EOSIO::Client.new(host: 'jungle2.cryptolions.io') }

    it 'gets contract data' do
      response = client.get_table_rows(table: 'test', scope: 'test', code: 'test')
      expect(response['rows'][0]).to eq 'success'
    end
  end
end
