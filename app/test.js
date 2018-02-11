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
	var abi = web3.eth.contract(contractABI);
  var contract = abi.at(contractLocation);
}

function startApp() {
	loadFile('contractABI.json', function(contractABI) {
	  loadFile('contractLocation.txt', function(contractLocation) {
      wireContract(JSON.parse(contractABI), contractLocation);
    });
	}, 'application/json');
}
