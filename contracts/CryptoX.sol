// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoX is ERC20 {
    address public admin;
    uint256 public MAX_SUPPLY = 100_000;
    constructor() ERC20("CryptoX", "CRPTX") {
        admin = msg.sender;
        _mint(admin, MAX_SUPPLY*10**18);
    }

}