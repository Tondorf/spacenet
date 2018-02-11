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

	uint constant REGISTRATION_FEE = 1 ether;
	uint constant X = 10;
	uint constant Y = 10;

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
	// colonizedPlanets == X*Y - freePlanets.length
	uint[] internal freePlanets;

	Spaceship[] internal spaceships;
	mapping (uint => address) internal spaceship2owner;

	function Space() public {
		for (uint y = 0; y < Y; y++) {
			for (uint x = 0; x < X; x++) {
				uint size = 10 + uint(keccak256(block.timestamp + x + y)) % 41; // size range: 10-50
				Mine memory iron = Mine(1, 1000);
				Mine memory copp = Mine(1, 1000);
				uint planetID = planets.push(Planet(x, y, "", size, iron, copp));
				freePlanets.push(planetID);
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

	function _assignPlanet(address _player, string _planetname) internal returns (bool) {
		if (freePlanets.length == 0) {
			return false;
		}
		uint nextFreeID = uint(keccak256(uint(_player) + block.timestamp)) % freePlanets.length;
		uint newPlayerPlanetID = freePlanets[nextFreeID]; // colonize planet with this ID

		planets[newPlayerPlanetID].name = _planetname; // set player-chosen name
		planet2owner[newPlayerPlanetID] = _player; // create planet->player relation

		freePlanets[nextFreeID] = freePlanets[freePlanets.length]; // move last element to the one that was just assigned
		delete freePlanets[freePlanets.length]; // delete last element
		freePlanets.length--;
		return true;
	}

	function buildSpaceship(uint _planetID) external owns(msg.sender, _planetID) {
		require(_planetID < planets.length);
		require(planets[_planetID].ironMine.resource >= 100);
		planets[_planetID].ironMine.resource -= 100;
		uint spaceshipID = spaceships.push(Spaceship(_planetID, 100, 10, 10));
		spaceship2owner[spaceshipID] = msg.sender;
	}

	function getPlanetIDsForPlayer(address _player) external view returns (uint[]) {
		uint[] memory planetIDs;
		uint counter = 0;
		for (uint i = 0; i < planets.length; i++) {
			if (planet2owner[i] == _player) {
				planetIDs[counter] = i;
				counter++;
			}
		}
		return planetIDs;
	}

	function getPlanet(uint _planetID) external view returns (uint, uint, string, uint) {
		require(_planetID < planets.length);
		Planet memory p = planets[_planetID];
		return (p.x, p.y, p.name, p.size);
	}

	function getSpaceshipIDsForPlayer(address _player) external view returns (uint[]) {
		uint[] memory spaceshipIDs;
		uint counter = 0;
		for (uint i = 0; i < spaceships.length; i++) {
			if (spaceship2owner[i] == _player) {
				spaceshipIDs[counter] = i;
				counter++;
			}
		}
		return spaceshipIDs;
	}

	function getSpaceshipIDsForPlanet(uint _planetID) external view returns (uint[]) {
		uint[] memory spaceshipIDs;
		uint counter = 0;
		for (uint i = 0; i < spaceships.length; i++) {
			if (spaceships[i].planetID == _planetID) {
				spaceshipIDs[counter] = i;
				counter++;
			}
		}
		return spaceshipIDs;
	}

	function getSpaceship(uint _spaceshipID) external view returns (Spaceship) {
		require(_spaceshipID < spaceships.length);
		return spaceships[_spaceshipID];
	}

}
