// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {nUSDStableCoin} from "./nUSDStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title nUsd Engine
 * @author Anand
 *
 *
 * @notice This contract is the core of the nUsd Stystem. 
   It handles all the logic for mining and redeeming nUsd.
   And the collateral is ETH
 * @notice This contract is VERY loosly based on the MakerDAO DSS (DAI) system.
 */
contract nUSDEngine is ReentrancyGuard {
    ////////////////
    //   Errors   //
    ////////////////
    error nUSDEngine__NeedsMoreThanZero();
    error nUSDEngine__TransferFailed();
    error nUSDEngine__MintFailed();

    /////////////////////////
    //   State Variables   //
    /////////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant TOKEN_MULTIPLIER = 2;

    address private s_priceFeed; 
    mapping(address user =>  uint256 amount) private s_collateralDeposited;
    mapping(address user => uint256 amountnUsdMinted) private nUSDMinted;

    nUSDStableCoin private immutable i_nUsd;

    /////////////////////////
    //   Events            //
    /////////////////////////
    event CollateralDeposited(address indexed user, uint256 indexed amount);
    event CollateralRedeemed(address indexed user, uint256 indexed amount, address from, address to);

    ////////////////
    // Modifiers  //
    ////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert nUSDEngine__NeedsMoreThanZero();
        }
        _;
    }


    ////////////////
    // Functions  //
    ////////////////


    // 0x694AA1769357215DE4FAC081bf1f309aDC325306 price feed

    constructor(address priceFeedAddress, address nUSDAddress) {
        s_priceFeed = priceFeedAddress;
        i_nUsd = nUSDStableCoin(nUSDAddress);
    }

    /////////////////////////
    // External Functions  //
    /////////////////////////

    function depositCollateralAndMintnUsd() external payable moreThanZero(msg.value) {
        uint256 usdPrice = getUsdValue(msg.value);
        depositeCollateral(msg.value);
        mintnUsd(usdPrice/TOKEN_MULTIPLIER);
    }

    // /**
    //  * @notice follow CEI
    //  * @param tokenCollateralAddress The address of the token to deposit as collateral
    //  */
    function depositeCollateral(uint256 amount)
        internal  
        moreThanZero(amount)
        nonReentrant
    {
        s_collateralDeposited[msg.sender] += amount;
        emit CollateralDeposited(msg.sender, msg.value);
    }


    /*
     * @param amountnUsdToBurn: The amount of nUsd you want to burn
     * @notice This function will withdraw your collateral and burn nUsd in one transaction
     */
    function redeemCollateralFornUsd(uint256 amountnUsdToBurn)
        external
        moreThanZero(amountnUsdToBurn)
    {
        uint256 amountETH = getEthAmountFromUsd(amountnUsdToBurn) / TOKEN_MULTIPLIER;
        _burnnUsd(amountnUsdToBurn, msg.sender, msg.sender);
        _redeemCollateral(amountETH, msg.sender, payable(msg.sender));
    }

    /**
     * @notice follow CEI
     * @param amountnUsdToMint The amount of decentralised stable coin to mint
     * @notice they must have more collateral value than the minimum threshold
     */

    function mintnUsd(uint256 amountnUsdToMint) internal moreThanZero(amountnUsdToMint) nonReentrant {
        nUSDMinted[msg.sender] += amountnUsdToMint;
        bool minted = i_nUsd.mint(msg.sender, amountnUsdToMint);

        if (!minted) {
            revert nUSDEngine__MintFailed();
        }
    }

    function _burnnUsd(uint256 amountnUsdToBurn, address onBehalfOf, address nUsdFrom) private {
        nUSDMinted[onBehalfOf] -= amountnUsdToBurn;

        bool success = i_nUsd.transferFrom(nUsdFrom, address(this), amountnUsdToBurn);

        if (!success) {
            revert nUSDEngine__TransferFailed();
        }
        i_nUsd.burn(amountnUsdToBurn);
    }

    //////////////////////////////////////////
    // Private and Internal View Functions  //
    //////////////////////////////////////////

    function _redeemCollateral(uint256 amountCollateral, address from, address payable to)
        private
    {
        s_collateralDeposited[from] -= amountCollateral;
        emit CollateralRedeemed(from, amountCollateral, from, to);
        to.transfer(amountCollateral);

    }

    /////////////////////////////////////////
    // Public and External View Functions  //
    /////////////////////////////////////////

    function getUsdValue(uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // 1 ETH = 2000 USD
        // The returned value from CL will be 1000 * 1e8
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    function getEthAmountFromUsd( uint256 usdAmountInWei) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // 1 ETH = 2000 USD
        // The returned value from Chainlink will be 2000 * 1e8
        // Most USD pairs have 8 decimals, so we will just pretend they all do
        return ((usdAmountInWei * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION));
    }
}