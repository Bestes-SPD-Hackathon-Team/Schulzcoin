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
