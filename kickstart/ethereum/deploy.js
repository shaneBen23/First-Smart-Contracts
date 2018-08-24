const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledFactory = require('./build/CampaignFactory.json');

const provider = new HDWalletProvider(
  'nurse shrimp end lunch book brain exclude nerve message hawk betray now',
  'https://rinkeby.infura.io/dHRT6sR6UQHeGrLuM7JO'
);

const web3 = new Web3(provider);

const deploy = async () => {

 const accounts = await web3.eth.getAccounts();

 console.log('Account to do deploy', accounts[0]);

 const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
 .deploy({ data: compiledFactory.bytecode })
 .send({ gas: '1000000', from: accounts[0] });

 console.log("address", result.options.address);
}
deploy();

//deployed contract address 0xbfCdaA38BE9c719e5cA916EFD735137F8b243438
