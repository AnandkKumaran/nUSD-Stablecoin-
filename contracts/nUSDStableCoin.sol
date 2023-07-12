// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title nUSDStableCoin
 * @author Anand
 * Collateral: ETH
 * Minting: Algorithmic
 *
 * This is the contract is govered by DSCEngine
 *
 */
contract nUSDStableCoin is ERC20Burnable, Ownable {
    error nUSDStableCoin__MustbeMoreThanZero();
    error nUSDStableCoin__BurnAmountExceedBalance();
    error nUSDStableCoin__NotZeroAddress();

    constructor() ERC20("nUSDStableCoin", "nUSD") {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert nUSDStableCoin__MustbeMoreThanZero();
        }

        if (balance < _amount) {
            revert nUSDStableCoin__BurnAmountExceedBalance();
        }

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert nUSDStableCoin__NotZeroAddress();
        }

        if (_amount <= 0) {
            revert nUSDStableCoin__MustbeMoreThanZero();
        }

        _mint(_to, _amount);
        return true;
    }
}