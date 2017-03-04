# contracts
A bin for all the contracts we do

## Deployments

### Testnet

#### Registry `0x8e4e9b13d4b45cb0befc93c3061b1408f67316b2`

Example code:
```
var Registry = web3.eth.contract([{"constant":false,"inputs":[{"name":"_new","type":"address"}],"name":"setOwner","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"confirmReverse","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"}],"name":"reserve","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"},{"name":"_value","type":"bytes32"}],"name":"set","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"}],"name":"drop","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"}],"name":"getAddress","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_amount","type":"uint256"}],"name":"setFee","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_to","type":"address"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"bytes32"}],"name":"reserved","outputs":[{"name":"reserved","type":"bool"}],"type":"function"},{"constant":false,"inputs":[],"name":"drain","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_who","type":"address"}],"name":"proposeReverse","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"}],"name":"getUint","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"}],"name":"get","outputs":[{"name":"","type":"bytes32"}],"type":"function"},{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"reverse","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"},{"name":"_value","type":"uint256"}],"name":"setUint","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[],"name":"removeReverse","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"bytes32"},{"name":"_key","type":"string"},{"name":"_value","type":"address"}],"name":"setAddress","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"}],"name":"Drained","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"}],"name":"FeeChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"bytes32"},{"indexed":true,"name":"owner","type":"address"}],"name":"Reserved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"bytes32"},{"indexed":true,"name":"oldOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"Transferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"bytes32"},{"indexed":true,"name":"owner","type":"address"}],"name":"Dropped","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"bytes32"},{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"key","type":"string"}],"name":"DataChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"string"},{"indexed":true,"name":"reverse","type":"address"}],"name":"ReverseProposed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"string"},{"indexed":true,"name":"reverse","type":"address"}],"name":"ReverseConfirmed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"name","type":"string"},{"indexed":true,"name":"reverse","type":"address"}],"name":"ReverseRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"old","type":"address"},{"indexed":true,"name":"current","type":"address"}],"name":"NewOwner","type":"event"}]);
var theRegistry = Registry.at('0x8e4e9b13d4b45cb0befc93c3061b1408f67316b2');
theRegistry.reserved(web3.sha3('gavofyork')) // returns false
theRegistry.reserve(web3.sha3('gavofyork'), web3.eth.reporter);
// Wait for mine
theRegistry.reserved(web3.sha3('gavofyork')) // returns true
theRegistry.getAddress(web3.sha3('gavcoin'), 'A') // returns '0x00..00'
theRegistry.setAddress(web3.sha3('gavcoin'), 'A', web3.eth.defaultAccount)
// Wait for mine
theRegistry.getAddress(web3.sha3('gavcoin'), 'A') // returns web3.eth.defaultAccount
theRegistry.reverse(web3.eth.defaultAccount) // returns ''
theRegistry.proposeReverse(web3.sha3('gavofyork'), web3.eth.defaultAccount, web3.eth.reporter) // sent from owner of 'gavofyork'
theRegistry.confirmReverse(web3.sha3('gavofyork'), web3.eth.reporter) //sent from web3.eth.defaultAccount
// Wait for mine
theRegistry.reverse(web3.eth.defaultAccount) // returns 'gavofyork'
```

#### GithubHint

Example code:
```
var GithubHint = web3.eth.contract([{"constant":false,"inputs":[{"name":"_content","type":"bytes32"},{"name":"_url","type":"string"}],"name":"hintURL","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_content","type":"bytes32"},{"name":"_accountSlashRepo","type":"string"},{"name":"_commit","type":"bytes20"}],"name":"hint","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"entries","outputs":[{"name":"accountSlashRepo","type":"string"},{"name":"commit","type":"bytes20"},{"name":"owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_content","type":"bytes32"}],"name":"unhint","outputs":[],"type":"function"}]);
theGithubHint = GithubHint.at(theRegistry.getAddress(web3.sha3('githubhint'), 'A'));
theGithubHint.hint('0x0a6ff473dd56cb7663c96826c7aa0353493e6270e0119c40613156d775ff5a90', 'ethcore/contracts', '0xa0b88f13366484ffbebbf0e90b6ee20dcafae32e', web3.eth.reporter);
// Wait until reporter reports it is mined.
theGithubHint.entries('0x0a6ff473dd56cb7663c96826c7aa0353493e6270e0119c40613156d775ff5a90') // returns an entry.
```

#### TokenReg

Example code:
```
var TokenReg = web3.eth.contract([{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"token","outputs":[{"name":"addr","type":"address"},{"name":"tla","type":"string"},{"name":"base","type":"uint256"},{"name":"name","type":"string"},{"name":"owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_new","type":"address"}],"name":"setOwner","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"},{"name":"_tla","type":"string"},{"name":"_base","type":"uint256"},{"name":"_name","type":"string"}],"name":"register","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_fee","type":"uint256"}],"name":"setFee","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"},{"name":"_key","type":"bytes32"}],"name":"meta","outputs":[{"name":"","type":"bytes32"}],"type":"function"},{"constant":true,"inputs":[{"name":"_tla","type":"string"}],"name":"fromTLA","outputs":[{"name":"id","type":"uint256"},{"name":"addr","type":"address"},{"name":"base","type":"uint256"},{"name":"name","type":"string"},{"name":"owner","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"drain","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"tokenCount","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"}],"name":"unregister","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"fromAddress","outputs":[{"name":"id","type":"uint256"},{"name":"tla","type":"string"},{"name":"base","type":"uint256"},{"name":"name","type":"string"},{"name":"owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"},{"name":"_key","type":"bytes32"},{"name":"_value","type":"bytes32"}],"name":"setMeta","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"tla","type":"string"},{"indexed":true,"name":"id","type":"uint256"},{"indexed":false,"name":"addr","type":"address"},{"indexed":false,"name":"name","type":"string"}],"name":"Registered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"tla","type":"string"},{"indexed":true,"name":"id","type":"uint256"}],"name":"Unregistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"id","type":"uint256"},{"indexed":true,"name":"key","type":"bytes32"},{"indexed":false,"name":"value","type":"bytes32"}],"name":"MetaChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"old","type":"address"},{"indexed":true,"name":"current","type":"address"}],"name":"NewOwner","type":"event"}]);
var theTokenReg = TokenReg.at(theRegistry.getAddress(web3.sha3('tokenreg'), 'A'));
+theTokenReg.fee() // returns 10^18
+theTokenReg.tokenCount() // returns 0
theTokenReg.register('0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca', "GAV", 1000000, "GAVcoin", {value: 1000000000000000000}, web3.eth.reporter);
// Wait for reporter to say it's mined.
+theTokenReg.tokenCount() // returns 1
+theTokenReg.token(0)[1] // returns ["0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca", "GAV", 1000000, "GAVcoin"]
theTokenReg.fromTLA("GAV")[1] // returns '0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca'
theTokenReg.fromAddress("0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca")[1] // returns 'GAV'
```

#### GavCoin

Example code:
```
var GavCoin = web3.eth.contract([{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_who","type":"address"},{"name":"_maxPrice","type":"uint256"}],"name":"buyin","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"remaining","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"},{"name":"_units","type":"uint256"}],"name":"refund","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_who","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"price","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"buyer","type":"address"},{"indexed":true,"name":"price","type":"uint256"},{"indexed":true,"name":"amount","type":"uint256"}],"name":"Buyin","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"buyer","type":"address"},{"indexed":true,"name":"price","type":"uint256"},{"indexed":true,"name":"amount","type":"uint256"}],"name":"Refund","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"}],"name":"NewTranch","type":"event"}]);
var theGavCoin = GavCoin.at(theRegistry.getAddress(web3.sha3('gavcoin'), 'A'));
+theGavCoin.balanceOf(web3.eth.defaultAccount) // returns 0
+theGavCoin.price() // returns 10^15 // Note price is denoted in "nominal" currency which is 10^6 base units.
+theGavCoin.remaining() // returns 10^9
web3.eth.sendTransaction({to: theGavCoin.address, value: 100 * 10^15 / 10^6, gas: 1000000}, web3.eth.reporter)
// Wait for reporter to say transaction is mined.
+theGavCoin.balanceOf(web3.eth.defaultAccount) // returns 100 * 10^6
+theGavCoin.price() // returns 2 * 10^15
+theGavCoin.remaining() // returns 10^9
// Wait 7 days.
theGavCoin.refund(10^15, 50 * 10^6, web3.eth.reporter)  // request a refund of 50 at the initial price.
// Wait for reporter to say transaction is mined.
+theGavCoin.balanceOf(web3.eth.defaultAccount) // returns 50 * 10^6
```
