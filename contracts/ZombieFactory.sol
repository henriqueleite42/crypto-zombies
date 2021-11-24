pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../utils/SafeMath.sol";

contract ZombieFactory is Ownable {
	using SafeMath for uint256;
	using SafeMath32 for uint32;
	using SafeMath16 for uint16;

	event NewZombie(uint256 zombieId, string name, uint256 dna);

	uint256 dnaDigits = 16;
	uint256 dnaModulus = 10**dnaDigits;
	uint256 cooldownTime = 1 days;

	struct Zombie {
		string name;
		uint256 dna;
		uint32 level;
		uint32 readyTime;
		uint16 winCount;
		uint16 lossCount;
	}

	Zombie[] public zombies;

	mapping(uint256 => address) public zombieToOwner;
	mapping(address => uint256) ownerZombieCount;

	function _createZombie(string memory _name, uint256 _dna) internal {
		zombies.push(
			Zombie({
				name: _name,
				dna: _dna,
				level: 1,
				readyTime: uint32(block.timestamp + cooldownTime),
				winCount: 0,
				lossCount: 0
			})
		);
		uint256 id = zombies.length - 1;
		zombieToOwner[id] = msg.sender;
		ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
		emit NewZombie(id, _name, _dna);
	}

	function _generateRandomDna(string memory _str)
		private
		view
		returns (uint256)
	{
		uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
		return rand % dnaModulus;
	}

	function createRandomZombie(string memory _name) public {
		require(ownerZombieCount[msg.sender] == 0);
		uint256 randDna = _generateRandomDna(_name);
		randDna = randDna - (randDna % 100);
		_createZombie(_name, randDna);
	}
}