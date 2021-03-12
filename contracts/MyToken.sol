pragma solidity ^0.7.6;

import "/Users/hderoche/project/ICO/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20{
    
    string private _name;
    string private _ticker;

    constructor(
    ) ERC20("MarsToken", "MARS") {
    }


}