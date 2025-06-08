// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WellnessToken is ERC20, Ownable {
    mapping(address => bool) public minters;
    
    event MinterStatusChanged(address indexed minter, bool status);
    
    constructor() ERC20("Wellness Token", "WELL") {
        _mint(msg.sender, 1000000 * 10**18); // Initial supply
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Not authorized to mint");
        _;
    }
    
    function setMinter(address minter, bool status) external onlyOwner {
        minters[minter] = status;
        emit MinterStatusChanged(minter, status);
    }
    
    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }
} 