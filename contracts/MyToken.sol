pragma solidity ^0.7.6;

import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract MyToken is ERC20, Ownable {
    
    using SafeMath for uint;

    string private _name;
    string private _ticker;
    uint8 private _decimals;

    uint256 public totalIssuedToken;

    // Mapping for whitelists
    mapping(address => uint8) public phase;
    uint256 public count;
    mapping(uint8 => uint256) public tokenIssued;

    event Airdrop(address user, uint256 amount_);

    constructor(
        uint8 decimals_,
        uint256 amount_
    ) ERC20("MarsToken", "MARS") Ownable() {
        _setupDecimals(decimals_);
        _mint(msg.sender, amount_);
        count = 0;
        totalIssuedToken = 0;
    }

    modifier allowUsers(address recipient_) {
        require(phase[recipient_] > 0, "you are not allowed to buy tokens");
        _;
    }


    // Set phase, First 10 -> 1, then 100 -> pahse 2 -> 1000 phase 3
    function setPhase(address recipient_) public onlyOwner {
        if (count < 10) {
        phase[recipient_] = 1;
        }
        else if (count < 100) {
            phase[recipient_] = 2;
        }
        else {
            phase[recipient_] = 3;
        }
        count += 1;
    }


// The phase mapping is set at 0 for all addresses by default
// So the modifier check if the address is set above 0
// if the user is at 0, he cannot buy the token
    function _getToken(uint256 amount_) internal allowUsers(msg.sender) returns(uint256) {
        SafeMath.add(totalIssuedToken, amount_);
        if (phase[msg.sender] == 1) {

            transferFrom(owner(), msg.sender, 5000*amount_);
            SafeMath.add(tokenIssued[1], 5000*amount_);
            SafeMath.add(totalIssuedToken, 5000*amount_);
        }
        else if (phase[msg.sender] == 2) {
            transferFrom(owner(), msg.sender, 2000*amount_);
            SafeMath.add(tokenIssued[2], 20000*amount_);
            SafeMath.add(totalIssuedToken, 2000*amount_);
        }
        else if (phase[msg.sender] == 3) {
            transferFrom(owner(), msg.sender, 1000*amount_);
            SafeMath.add(tokenIssued[3], 1000*amount_);
            SafeMath.add(totalIssuedToken, 1000*amount_);
        }
    }

    function airdrop(address payable recipient_, uint256 amount_) public payable onlyOwner {
        _mint(recipient_, amount_);
        Airdrop(recipient_, amount_);
    }

    receive () external payable {
        _getToken(msg.value);
    }

}