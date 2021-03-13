pragma solidity ^0.7.6;

import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable{
    
    using SafeMath for uint;

    string private _name;
    string private _ticker;
    uint8 private _decimals;

    uint256 public totalIssuedToken;

    // Mapping for whitelists
    mapping(address => uint8) public phase;
    mapping(address => bool) public allowedUsers;
    uint256 public count;
    mapping(uint8 => uint256) public tokenIssued;

    event Airdrop(address user);

    constructor(
        uint8 decimals_,
        uint256 amount_
    ) ERC20("MarsToken", "MARS") Ownable() {
        _setupDecimals(decimals_);
        _mint(msg.sender, amount_);
        count = 0;
        totalIssuedToken = 0;
    }

    function allowToken(address recipient_) onlyOwner {
        allowedUsers[recipient_] = true;
    }

    modifier allowedUsers() {
        require(allowedUsers[msg.sender] == true, "You are not allowed to buy this token");
        _;
    }

    // Set phase, First 100 -> 1, then 1000 -> pahse 2 -> 10000 pahse 3
    function setPhase(address recipient_) onlyOwner {
        if (count < 10) {
        phase[recipient_] = 1;
        }
        else if (count < 100) {
            phase[recipient_] = 2;
        }
        else if (count < 1000) {
            phase[recipient_] = 3;
        } else {

        }
        count += 1;
    }

    function getToken(uint256 amount_) payable internal allowedUsers returns(uint256) {
        SafeMath.add(totalIssuedToken, amount_);
        if (phase[msg.sender] == 1) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[1], amount_);
        }
        else if (phase[msg.sender] == 2) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[2], amount_);
        }
        else if (phase[msg.sender] == 3) {
            transferFrom(owner(), msg.sender, amount_);
            SafeMath.add(tokenIssued[3], amount_);

        }
        else throw;
    }

    function airdrop(address payable recipient_, uint256 amount_) payable onlyOwner {
        _mint(recipient_, amount_);
        Airdrop(recipient_);
    }

    receive () external payable {
        getToken(msg.value);
    }

}