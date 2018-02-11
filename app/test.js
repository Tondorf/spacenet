window.addEventListener('load', function() {

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    web3js = new Web3(web3.currentProvider);
  } else {
    console.log('No web3? You should consider trying MetaMask!')
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    //web3js = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  // Now you can start your app & access web3 freely:
  startApp()

})

function startApp() {
  console.log(web3.version.api)
  console.log(web3.version.network)
  console.log(web3.eth.coinbase)
  web3.eth.getBalance(web3.eth.coinbase, function(error, result) {
    if (!error)
      console.log(web3.fromWei(result.toNumber(), web3.ether))
    else
      console.error(error)
  })
}
