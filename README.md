# contracts
A bin for all the contracts we do

## Deployments

### Testnet

#### GithubHint: `0xa464a2c92f310190e10a29d498f711fc23148924`

Example code:
```
var GithubHint = web3.eth.contract([{"constant":false,"inputs":[{"name":"_content","type":"bytes32"},{"name":"_url","type":"string"}],"name":"hintURL","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_content","type":"bytes32"},{"name":"_accountSlashRepo","type":"string"},{"name":"_commit","type":"bytes20"}],"name":"hint","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"entries","outputs":[{"name":"accountSlashRepo","type":"string"},{"name":"commit","type":"bytes20"},{"name":"owner","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_content","type":"bytes32"}],"name":"unhint","outputs":[],"type":"function"}]);
theGithubHint = GithubHint.at('0xa464a2c92f310190e10a29d498f711fc23148924');
theGithubHint.hint('0x0a6ff473dd56cb7663c96826c7aa0353493e6270e0119c40613156d775ff5a90', 'ethcore/contracts', '0xa0b88f13366484ffbebbf0e90b6ee20dcafae32e', web3.eth.reporter);
// Wait until reporter reports it is mined.
theGithubHint.entries('0x0a6ff473dd56cb7663c96826c7aa0353493e6270e0119c40613156d775ff5a90') // returns an entry.
```

#### TokenReg: `0x3379a0960aff3575ce20d2669a4821d3166e9bdb`

Example code:
```
var TokenReg = web3.eth.contract([{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"token","outputs":[{"name":"o_addr","type":"address"},{"name":"o_tla","type":"string"},{"name":"o_base","type":"uint256"},{"name":"o_name","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_new","type":"address"}],"name":"setOwner","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"},{"name":"_tla","type":"string"},{"name":"_base","type":"uint256"},{"name":"_name","type":"string"}],"name":"register","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_fee","type":"uint256"}],"name":"setFee","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"},{"name":"_key","type":"bytes32"}],"name":"meta","outputs":[{"name":"","type":"bytes32"}],"type":"function"},{"constant":true,"inputs":[{"name":"_tla","type":"string"}],"name":"fromTLA","outputs":[{"name":"o_id","type":"uint256"},{"name":"o_addr","type":"address"},{"name":"o_base","type":"uint256"},{"name":"o_name","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"drain","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"tokenCount","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"}],"name":"unregister","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"fromAddress","outputs":[{"name":"o_id","type":"uint256"},{"name":"o_tla","type":"string"},{"name":"o_base","type":"uint256"},{"name":"o_name","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"type":"function"}]);
var theTokenReg = TokenReg.at('0x3379a0960aff3575ce20d2669a4821d3166e9bdb');
+theTokenReg.fee() // returns 10^18
+theTokenReg.tokenCount() // returns 0
tokenreg.register('0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca', "GAV", 1000000, "GAVcoin", {value: 1000000000000000000}, web3.eth.reporter );
// Wait for reporter to say it's mined.
+theTokenReg.tokenCount() // returns 1
+theTokenReg.token(0)[1] // returns ["0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca", "GAV", 1000000, "GAVcoin"]
theTokenReg.fromTLA("GAV")[1] // returns '0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca'
theTokenReg.fromAddress("0x79a20ddadf9ea64aab79a9c9d2b9c3775ee340ca")[1] // returns 'GAV'
```
