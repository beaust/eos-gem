EOS Gem
=======

## About
This is a small wrapper library for interacting with the [EOS](https://eos.io/) blockchain.

## Dependencies
* Ruby 2.5+

## Installation
```sh
$ gem install eos
```

## Examples
```rb
client = EOSIO::Client.new(host: 'jungle2.cryptolions.io', signatures: ['...'])
client.get_table_rows(table: 'token', scope: 'cryptolocker', code: 'cryptolocker')
# => {"rows"=>[], "more"=>false}

client.transact({
  actions: [{
    account: 'coolinvoicer',
    name: 'create',
    authorization: [{
      actor: 'gocoingocoin',
      permission: 'active'
    }]
  }],
  data: {
    user: 'gocoingocoin',
    invoice_id: 1,
    amount: 100
  }
})

# => TK
```

## Contributing
1. Branch (`git checkout -b fancy-new-feature`)
2. Commit (`git commit -m "Fanciness!"`)
3. Test (`bundle exec rake spec`)
4. Lint (`bundle exec rake rubocop`)
5. Push (`git push origin fancy-new-feature`)
6. Ye Olde Pulle Requeste
