pragma solidity ^0.4.24;

import "@gnosis.pm/util-contracts/contracts/Token.sol";
import "@gnosis.pm/dx-contracts/contracts/DutchExchange.sol";
import "@gnosis.pm/dx-contracts/contracts/Oracle/PriceOracleInterface.sol";

/**
* Set maximum an address can buy
*
*
*
*
*/

contract BuyBack {

    address public owner;

    // SellToken the token that is sold
    address public sellToken;
    address public buyToken;
    bool shouldBurnToken;
    // BuyToken the token that is bought
    DutchExchange public dx;

    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }

    event SellTokensDeposit(
        address indexed tokenAddress,
        uint256 amount,
        uint256 
    );

    event BuyTokensDeposit (

    );

    event BuyBack (
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 token
    );
       
    /**
     * @notice Constructor
     * @param _buyToken Address of the security token
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     */
    constructor(address _buyToken, address _sellToken, bool _burn) public {
        sellToken = _sellToken;
        buyToken = _buyToken;
        shouldBurnToken = _burn;
        (pricetNum, priceDen) = dx.getPriceOfTokenInLastAuction(token);
    }

    function updateDutchExchange (DutchExchange _dx) external onlyOwner {
        dx = _dx;
    }

    function transfer() {

    }

    function burnTokens() {

    }

    function () payable {
        emit BuyTokenDeposit(

        );
    }



}