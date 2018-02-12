window.addEventListener('load', function() {
  if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
  }

  startApp()
});

function loadFile(filename, callback, forceMimeType = '') {   
	var xobj = new XMLHttpRequest();
  if (forceMimeType) {
	  xobj.overrideMimeType(forceMimeType);
  }
	xobj.open('GET', filename, true);
	xobj.onreadystatechange = function () {
		if (xobj.readyState == 4 && xobj.status == "200") {
			callback(xobj.responseText);
		}
	};
	xobj.send(null);  
}

function wireContract(contractABI, contractLocation) {
  web3.eth.defaultAccount = web3.eth.accounts[0];

	var abi = web3.eth.contract(contractABI);
  var contract = abi.at(contractLocation);
  contract.echo(1337, function(error, result) {
    if(!error) { console.log('Echo: ' + result); }
    else { console.error('Error: ' + error); }
  });
  contract.getPlanet(0, function(error, result) {
    if(!error) { console.log('Echo: ' + typeof(result) + " " + result ); }
    else { console.error('Error: ' + error); }
  });
  contract.getPlanet(1, function(error, result) {
    if(!error) { console.log('Echo: ' + typeof(result) + " " + result ); }
    else { console.error('Error: ' + error); }
  });
}

function startApp() {
	loadFile('contractABI.json', function(contractABI) {
	  loadFile('contractLocation.txt', function(contractLocation) {
      wireContract(JSON.parse(contractABI), contractLocation.trim());
    });
	}, 'application/json');
}
