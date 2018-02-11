pragma solidity ^0.4.18;

// libraries
//import "./StringLib.sol";
//import "./oraclizeAPI_0.5.sol";

// my stuff
import "./ownable.sol";

contract Space is Ownable {

	uint REGISTRATION_FEE = 1 ether;
	uint X = 10;
	uint Y = 10;

	struct Planet {
		uint x;
		uint y;
		string name;
		uint size;

		Mine ironMine;
		Mine copperMine;
	}

	struct Mine {
		uint level;
		uint resource;
	}

	struct Spaceship {
		uint planetID;
		//uint flyingTo;
		uint hp;
		uint laser;
		uint shield;
	}

	modifier owns(address _player, uint _planetID) {
		require(planet2owner[_planetID] == _player);
		_;
	}

	Planet[] internal planets;
	mapping (uint => address) internal planet2owner;
	uint colonizedPlanets;
	uint[] internal freePlanetIDs;

	Spaceship[] internal spaceships;
	mapping (uint => address) internal spaceship2owner;

	function Space() public {
		colonizedPlanets = 0;
		for (uint y = 0; y < Y; y++) {
			for (uint x = 0; x < X; x++) {
				uint size = 1 + uint(keccak256(now + x + y)) % 100;
				Mine memory iron = Mine(1, 1000);
				Mine memory copp = Mine(1, 1000);
				uint planetID = planets.push(Planet(x, y, "", size, iron, copp));
				freePlanetIDs.push(planetID);
			}
		}
	}

	function register(string _planetname) external payable {
		require(msg.value >= REGISTRATION_FEE); // registration fee is 1 ether
		if (msg.value > REGISTRATION_FEE) {
			msg.sender.transfer(msg.value - REGISTRATION_FEE); // send back everything that was too much
		}
		bool success = _assignPlanet(msg.sender, _planetname);
		if (!success) { // refund
			msg.sender.transfer(REGISTRATION_FEE);
		}
	}

	function _assignPlanet(address _playerID, string _planetname) internal returns (bool) {
		uint freePlanets = freePlanetIDs.length;
		if (freePlanets == 0) {
			return false;
		}
		uint freePlanetID = uint(keccak256(uint(_playerID) + now)) % freePlanets;
		uint newPlayerPlanetID = freePlanetIDs[freePlanetID];

		planets[newPlayerPlanetID].name = _planetname;
		planet2owner[newPlayerPlanetID] = _playerID;
		colonizedPlanets++;

		freePlanetIDs[freePlanetID] = freePlanetIDs[freePlanetIDs.length]; // move last element to that one that was just assigned
		delete freePlanetIDs[freePlanetIDs.length];
		return true;
	}

	function buildSpaceship(uint _planetID) external owns(msg.sender, _planetID) {
		require (planets[_planetID].ironMine.resource >= 100);
		planets[_planetID].ironMine.resource -= 100;
		uint spaceshipID = spaceships.push(Spaceship(_planetID, 100, 10, 10));
		spaceship2owner[spaceshipID] = msg.sender;
	}

}
