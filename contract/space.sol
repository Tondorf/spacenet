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
		uint creation;
		uint immuneUntil;
	}

	modifier owns(address _player, uint _planetID) {
		require(planets[_planetID].owner == _player);
		_;
	}

	modifier homebaseOf(uint _planetID, address _player) {
		require(homebases[_player] == _planetID);
		_;
	}

	modifier hasAtLeast(uint _planetID, uint _fleet) {
		require(planets[_planetID].fleets >= _fleet);
		_;
	}

	Planet[] public planets;
	mapping (address => uint[]) internal player2planets; // homeplanet is always first in the list
	mapping (address => uint) internal homebases; // store player's homebases, this never changes
	mapping (address => uint) internal shipcount; // mainly for statistics, shipcount=score

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
		uint immuneUntil = now + 1 minutes; // <- for testing // 1 days;
		if (_homebase) {
			immuneUntil = now + 1 weeks;
		}
		uint id = planets.push(Planet(hash, _player, _fleet, now, immuneUntil)) - 1; // create planet
		player2planets[_player].push(id); // add home planet to player's mapping array
		shipcount[_player] += _fleet; // increase ship counter for player
	}

	function _removeOwnership(uint _planetID) private {
		require(planets[_planetID].owner != 0x0);
		address owner = planets[_planetID].owner;

		uint len = player2planets[owner].length;
		require(len > 1); // don't do anything if homebase is only planet

		// start at index 1 so homebase never get's deleted
		for (uint i = 1; i < len; i++) {
			if (player2planets[owner][i] == _planetID) {
				player2planets[owner][i] = player2planets[owner][len-1];
				delete player2planets[owner][len-1];
				player2planets[owner].length--;
			}
		}
		planets[_planetID].owner = 0x0;
		planets[_planetID].immuneUntil = now;
	}

	function _takeOwnership(uint _planetID, address _player) private owns(0x0, _planetID) {
		planets[_planetID].owner = _player;
		player2planets[_player].push(_planetID);
	}

	// Transfer ships from one planet to another, caller must own both
	function transfer(uint _from, uint _to, uint _fleet) external owns(msg.sender, _from) owns(msg.sender, _to) hasAtLeast(_from, _fleet) {
		planets[_from].fleets -= _fleet;
		planets[_to].fleets += _fleet;
		// don't need to update shipcount (yet)
		// TODO: calculate cost or something
	}

	// Attack another planet that is owned by another player
	function attack(uint _from, uint _to, uint _fleet) external owns(msg.sender, _from) hasAtLeast(_from, _fleet) {
		require(planets[_to].owner != msg.sender);
		require(planets[_to].owner != 0x0);
		planets[_from].fleets -= _fleet; // ships take off
		shipcount[planets[_from].owner] -= _fleet;

		// TODO: calculate cost or something

		Planet storage target = planets[_to];
		uint attackers = _fleet;
		uint defendants = target.fleets;
		if (attackers == defendants) {
			// planet becomes uninhabited
			_removeOwnership(_to);
			target.fleets = 0;
		} else if (attackers < defendants) { // attacker loses
			target.fleets -= attackers;
			shipcount[target.owner] -= attackers;
		} else if (attackers > defendants) { // attacker wins, change ownership
			target.fleets = attackers - defendants;
			shipcount[target.owner] -= defendants; // victim loses all ships

			// transfer ownership
			_removeOwnership(_to);
			_takeOwnership(_to, msg.sender);

			// update shipcount
			shipcount[target.owner] += target.fleets; // add ships that survived to old/new owner total
		}
	}

	// Colonize an uninhabited planet.
	// Uninhabited planets come into existance as a result of a tied battle.
	function colonize(uint _from, uint _to, uint _fleet) external owns(msg.sender, _from) owns(0x0, _to) hasAtLeast(_from, _fleet) {
		planets[_from].fleets -= _fleet;
		planets[_to].fleets += _fleet;
		// don't need to update shipcount (yet)
		_takeOwnership(_to, msg.sender);
		// TODO: calculate cost or something
	}

	// Start an expedition that discovers a new planet with a chance of losing
	// ships along the way as well as find new fleets at the new planet
	function expedition(uint _from, uint _fleet) external owns(msg.sender, _from) hasAtLeast(_from, _fleet) {
		planets[_from].fleets -= _fleet;
		shipcount[msg.sender] -= _fleet; // ships depart
		uint wayloss = 0; // TODO: calculate
		uint newPlanetGain = 0; // TODO: calculate
		_newPlanet(msg.sender, _fleet-wayloss+newPlanetGain, false); // shipcount is adjusted inside
	}

	// Buy ships that spawn at homebase
	function buyShips() external payable {
		uint ships = msg.value / SHIP_COST;
		uint homebaseID = player2planets[msg.sender][0];
		Planet storage homebase = planets[homebaseID]; // homebase is first in list
		homebase.fleets += ships;
		shipcount[msg.sender] += ships;
		msg.sender.transfer(msg.value - ships * SHIP_COST); // send back the change
	}

	// Getter

	function getPlanetIDsForPlayer(address _player) external view returns (uint[]) {
		return player2planets[_player]; // what if key doesn't exist
	}

	function getPlanet(uint _planetID) external view returns (address, uint, uint, uint) {
		Planet storage p = planets[_planetID];
		return (p.owner, p.fleets, p.creation, p.immuneUntil);
	}

	function getUninhabitedPlanetIDs() external view returns (uint[]) {
		uint[] memory uninhabitedIDs;
		uint counter = 0;
		for (uint i = 0; i < planets.length; i++) {
			if (planets[i].owner == 0x0) {
				uninhabitedIDs[counter] = i;
				counter++;
			}
		}
		return uninhabitedIDs;
	}

	function getFleetCountForPlayer(address _player) external view returns (uint) {
		return shipcount[_player]; // what if key doesn't exist
	}

    function echo(uint _x) external pure returns (uint) {
        return _x;
    }
}
