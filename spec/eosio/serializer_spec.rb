require 'spec_helper'

describe EOSIO::Serializer do
  before do
    @serializer = EOSIO::Serializer.new
  end

  describe '#serialize_uint64' do
    it 'correctly serializes unsigned 64-bit integers' do
      serialized = @serializer.serialize_uint64 '100'
      expect(serialized).to eq [100, 0, 0, 0, 0, 0, 0, 0]
    end
  end

  describe '#serialize_name' do
    it 'correctly serializes names' do
      serialized = @serializer.serialize_name 'ericericeric'
      expect(serialized).to eq [128, 220, 85, 200, 93, 133, 220, 85]
    end
  end
end
