/**
 * I _really_ hate doing it this way, but since EOS has moved almost all
 * of the packing and signing functionality out of their RPC endpoints,
 * the only other option is to port all the cryptographic functionality
 * (and potentially dependent libraries) out of JavaScript/TypeScript
 * and into Ruby. In the interest of expedience, for now, we'll have Ruby
 * shell out to Node in order to avoid this overhead.
 */

const { Api, JsonRpc, JsSignatureProvider } = require("eosjs");
const fetch = require("node-fetch");
const { TextEncoder, TextDecoder } = require("util");

// Normally I wouldn't use positional args like this, but we shouldn't
// be calling this code directly (it should always be wrapped by the
// Ruby library), so this is probably fine for now.
const URI = process.argv[2];
const KEY = process.argv[3];
const ACCOUNT = process.argv[4];
const ACTION = process.argv[5];
const INVOICE_ID = process.argv[6];
const AMOUNT = process.argv[7];

const eosSignatureProvider = new JsSignatureProvider([KEY]);
const eosRpc = new JsonRpc(URI, { fetch });
const eosApi = new Api({ rpc: eosRpc, signatureProvider: eosSignatureProvider, textDecoder: new TextDecoder(), textEncoder: new TextEncoder() });

(async () => {
  let result = await eosApi.transact({ actions: [{
    account: ACCOUNT,
    name: ACTION,
    authorization: [{
      actor: ACCOUNT,
      permission: "active",
    }],
    data: {
      user: ACCOUNT,
      invoice_id: INVOICE_ID,
      amount: AMOUNT,
    }
  }]}, { blocksBehind: 3, expireSeconds: 30 });

  console.log(result);
})();
