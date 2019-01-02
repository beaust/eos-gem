# Module housing all logic for interacting with the EOS blockchain.
module EOSIO
  # Handles serializing transactions for broadcast on EOS.
  class Serializer
    attr_reader :buffer

    def initialize
      @buffer = []
    end

    # Serializes EOS transaction data to (the equivalent of) a Uint8 array.
    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-api.ts#L156
    def serialize_tx(transaction)
      serialize({
        max_net_usage_words: 0,
        max_cpu_usage_ms: 0,
        delay_sec: 0,
        context_free_actions: [],
        actions: [],
        transaction_extensions: []
      }.merge(transaction))
    end

    # Converts an array of integers to a hex string.
    def array_to_hex
      ''.tap do |str|
        @buffer.each { |i| str << "00#{i.to_s(16)}"[-2..-1] }
      end
    end

    # Handles serialization for EOS data
    # (currently only supports `transact`).
    # @TODO: Create a type map and read the types
    # from the ABI, using those types to perform
    # arbitrary serialization.
    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-serialize.ts#L762
    def serialize(data)
      # The action data take the following shape:
      #
      # actions: [{
      #   account: "invoicer",     # type `name` (generally)
      #   name: "create",          # type `name` (generally)
      #   authorization: [{
      #     actor: "your_account"  # type `name` (generally)
      #     permission: "active",  # type `name` (generally)
      #   }]
      # }]
      data[:actions].each do |action|
        action.each do |_, value|
          @buffer << serialize_name(value) if value.is_a? String
        end
      end

      # @TODO: Don't hardcode this
      data[:actions][0][:authorization].each do |auth|
        auth.each do |_, value|
          @buffer << serialize_name(value)
        end
      end

      # The data field take the following shape:
      #   data: {                    # type `bytes`  (generally)
      #     user: "your_account",    # type `name`   (in our case)
      #     invoice_id: invoice_id,  # type `uint64` (in our case)
      #     amount: amount           # type `uint64` (in our case)
      #   }
      #
      # Here, we assume that data are either uint_64 or name. We can
      # generalize this later as additional functionality is required.
      data[:data].each do |_, value|
        @buffer << if value.is_a? Integer
                     serialize_uint64(value)
                   else
                     serialize_name(value)
                   end
      end

      @buffer.flatten!
    end

    # Serializes an EOS field of type `uint64`.
    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-numeric.ts#L52
    def serialize_uint64(data)
      decimal_to_binary 8, data.to_s
    end

    # Serializes an EOS field of type `name`.
    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-serialize.ts#L298
    def serialize_name(name)
      out = Array.new(8, 0)
      bit = 63

      name.chars do |c|
        c = char_to_symbol c.ord
        c = c << 1 if bit < 5

        4.downto(0).each do |i|
          if bit >= 0
            out[bit / 8] |= ((c >> i) & 1) << (bit % 8)
            bit -= 1
          end
        end
      end

      out
    end

    private

    # Ensures characters in a name string are in 'a'..'z' + 1..5.
    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-serialize.ts#L302
    def char_to_symbol(char)
      return char - 'a'.ord + 6 if char >= 'a'.ord && char <= 'z'.ord

      return char - '1'.ord + 1 if char >= '1'.ord && char <= '5'.ord

      0
    end

    # @see https://github.com/EOSIO/eosjs/blob/master/src/eosjs-numeric.ts#L52
    def decimal_to_binary(size, str)
      result = Array.new(size, 0)

      str.chars do |c|
        carry = c.ord - '0'.ord

        0.upto(size - 1).each do |i|
          x = result[i] * 10 + carry
          result[i] = x
          carry = x >> 8
        end
      end

      result
    end
  end
end
