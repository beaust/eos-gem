EOS Gem
=======

## About
This is a small wrapper library for interacting with the [EOS](https://eos.io/) blockchain.

## Dependencies
* [Ruby](https://www.ruby-lang.org/) (2.5+)
* [Node.js](https://nodejs.org) (8+)

## Installation
```sh
$ gem install eos
```

## Examples
```rb
client = EOSIO::Client.new(host: 'jungle2.cryptolions.io', signatures: ['5KcS87XxX33eszpmRb25dGSXm4WKYEnyjHaEMFj9RAp9uRPmRg8'])
client.get_table_rows(table: 'invoices', scope: 'invoicer1111', code: 'invoicer1111')
# => {"rows"=>[{"key"=>1, "invoice_id"=>"1", "amount"=>10000, "paid"=>0}, {"key"=>2, "invoice_id"=>"2", "amount"=>30000, "paid"=>0}], "more"=>false}

client.transact({ account: 'invoicer1111', action: 'create', invoice_id: 3, amount: 10000 })
# => "{ transaction_id:\n   'b15f882664368cdca1f35b8d9627b1b1959919a9a4821328e403fbe37e1223bd',\n  processed:\n   { id:\n      'b15f882664368cdca1f35b8d9627b1b1959919a9a4821328e403fbe37e1223bd',\n     block_num: 10113136,\n     block_time: '2019-01-22T19:48:38.000',\n     producer_block_id: null,\n     receipt:\n      { status: 'executed', cpu_usage_us: 336, net_usage_words: 14 },\n     elapsed: 336,\n     net_usage: 112,\n     scheduled: false,\n     action_traces: [ [Object] ],\n     except: null } }\n"
```

## Contributing
1. Branch (`git checkout -b fancy-new-feature`)
2. Commit (`git commit -m "Fanciness!"`)
3. Test (`bundle exec rake spec`)
4. Lint (`bundle exec rake rubocop`)
5. Push (`git push origin fancy-new-feature`)
6. Ye Olde Pulle Requeste
