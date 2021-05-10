pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//TODO 仅用于测试

//SPDX-License-Identifier: <SPDX-License>
contract TokenDemo is ERC20, Ownable {

    constructor()ERC20("Test Token", "Test"){
        uint totalSupply = 500000 * (10 ** decimals());
        _mint(owner(), totalSupply);
    }

    function decimals() public pure override returns (uint8){
        return 9;
    }

    function mint(address to, uint amount) public onlyOwner() {
        _mint(to, amount);
    }

    function burn(uint amount) public {
        _burn(_msgSender(), amount);
    }
}