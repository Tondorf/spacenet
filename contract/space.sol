pragma solidity ^0.4.18;

contract Ownable {
  address public owner;
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract Space is Ownable {

	uint REGISTRATION_FEE = 1 ether;
	uint SHIP_COST = 1 ether;
	uint STARTING_SHIP_COUNT = 10;

	struct Planet {
		uint hash;
		address owner;
		uint fleets;
		uint immunity;
	}

	modifier owns(address _player, uint _planetID) {
		require(planets[_planetID].owner == _player);
		_;
	}

	modifier hasAtLeast(uint _planetID, uint _fleet) {
		require(planets[_planetID].fleets >= _fleet);
		_;
	}

	Planet[] public planets;
	mapping (address => uint[]) internal player2planets; // homeplanet is always first in the list
	mapping (address => uint) internal shipcount; // mainly for statistics

	function Space() public {
		//
	}

	// Registration, to be called initially by each player
	function register() external payable {
		require(msg.value >= REGISTRATION_FEE);
		if (msg.value > REGISTRATION_FEE) {
            // send back everything that was too much
			msg.sender.transfer(msg.value - REGISTRATION_FEE);
		}
		_newPlanet(msg.sender, STARTING_SHIP_COUNT, true);
	}

	function _newPlanet(address _player, uint _fleet, bool _homebase) private {
		uint hash = uint(keccak256(block.timestamp + uint(_player)));
		uint immunity = 1 minutes; // <- for testing // 1 days;
		if (_homebase) {
			immunity = 1 weeks;
		}

		uint id = planets.push(Planet(hash, _player, _fleet, immunity)); // create planet
		player2planets[_player].push(id); // add home planet to player's mapping array
		shipcount[_player] += _fleet; // initialize ship counter for player
	}

	function transfer(uint _from, uint _to, uint _fleet) external owns(msg.sender, _from) owns(msg.sender, _to) hasAtLeast(_from, _fleet) {
		planets[_from].fleets -= _fleet;
		planets[_to].fleets += _fleet;
		// TODO: calculate cost or something
	}

	function attack(uint _from, uint _to, uint _fleet) external owns(msg.sender, _from) {
		require(planets[_to].owner != msg.sender);
		require(planets[_to].owner != 0x0);
		planets[_from].fleets -= _fleet; // ships take

		// TODO: calculate cost or something

		uint attackers = _fleet;
		uint defendants = planets[_to].fleets;
		if (attackers == defendants) {
			planets[_to].owner = 0x0; // planet becomes uninhabited
			planets[_to].fleets = 0;
		} else if (attackers < defendants) { // attacker loses
			planets[_to].fleets = defendants - attackers;
		} else if (attackers > defendants) { // attacker wins, change ownership
			planets[_to].fleets = attackers - defendants;
			planets[_to].owner = msg.sender;
		}
	}

	function expedition(uint _from, uint _fleet) external owns(msg.sender, _from) hasAtLeast(_from, _fleet) {
		planets[_from].fleets -= _fleet;
		uint wayloss = 0; // TODO: calculate
		_newPlanet(msg.sender, _fleet-wayloss, false);
	}

	// ships go to homebase
	function buyShips() external payable {
		uint ships = msg.value / SHIP_COST;
		uint homebaseID = player2planets[msg.sender][0];
		Planet storage homebase = planets[homebaseID]; // homebase is first in list
		homebase.fleets += ships;
		msg.sender.transfer(msg.value - ships * SHIP_COST); // send back the change
	}

	// Getter

	function getPlanetIDsForPlayer(address _player) external view returns (uint[]) {
		return player2planets[_player]; // what if key doesn't exist
	}

	function getPlanet(uint _planetID) external view returns (address, uint) {
		Planet storage p = planets[_planetID];
		return (p.owner, p.fleets);
	}

	function getFleetCountForPlayer(address _player) external view returns (uint) {
		return shipcount[_player]; // what if key doesn't exist
	}

}
