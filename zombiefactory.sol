//Solidity version 
pragma solidity  >=0.5.0 <0.6.0;

/** @title Zombie factory
    @author Zarilex
    @notice creates a random zombie
    @param zombieId,name & dna
    @return  */

//The Ownable contract has an owner address, and provides basic authorization control
import "./ownable.sol";
//Math operations with safety checks that throw on error
import "./safemath.sol";

contract ZombieFactory is ownable {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    //declaring an event
    event NewZombie(uint zombieId, string name, uint dna);

    // type then variable name
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    // basically a data structure 
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    // basically a dict
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) private {
        // append to struct and returns the length which is the index 0 
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        // firing an event
        emit NewZombie(id, _name, _dna);
    } 

    function _generateRandomDna(string memory _str) private view returns (uint) {
        // randomness 
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // only new address can create a zombie
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
