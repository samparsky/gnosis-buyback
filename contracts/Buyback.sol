pragma solidity ^0.4.24;

import "@gnosis.pm/util-contracts/contracts/Token.sol";
import "@gnosis.pm/dx-contracts/contracts/DutchExchange.sol";
import "@gnosis.pm/dx-contracts/contracts/Oracle/PriceOracleInterface.sol";

/**
* Set maximum an address can buy
* approve and allow
*/

contract BuyBack {

    address public owner;

    // SellToken the token that is sold
    address public sellToken;
    address public buyToken;
    address public burnAddress;

    // mapping of the sell token to 
    mapping (address => uint) public balances;
    // mapping (address => uint) public 

    // This is a mapping of auction id to amount
    uint[] auctionIndexes;
    mapping(uint => uint) public auction;

    bool shouldBurnToken;

    // BuyToken the token that is bought
    DutchExchange public dx;

    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }

    event Withdraw(
        address indexed sellToken,
        address indexed buyToken,
        uint balance,
        uint auctionIndex
    );

    event Deposit(
        address indexed tokenAddress,
        uint amount
    );

    event ModifyAuction(
        uint auctionIndex,
        uint amount
    );

    event ModifyBurnAddress(
        address burnAddress
    );

    event Burn (
        address indexed tokenAddress,
        address burnAddress,
        uint amount
    );
       
    /**
     * @notice Constructor
     * @param _buyToken Address of the security token
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    constructor(address _buyToken, address _sellToken, bool _burn, uint[] _auctionIndexs, uint[] _auctionAmounts) public {
        sellToken = _sellToken;
        buyToken = _buyToken;
        shouldBurnToken = _burn;

        require(_auctionIndexs.length == _auctionAmounts.length, "Invalid auction amount and index");
        
        // map the auction ids to the auction amount
        for(uint i = 0; i < _auctionIndexs.length; i++ ){
            auction[_auctionIndexs[i]] = _auctionAmounts[i];
        }

        // (pricetNum, priceDen) = dx.getPriceOfTokenInLastAuction(token);
    }

    function modifyAuctionsMulti(uint[] _auctionIndexs, uint[] _auctionAmounts) external onlyOwner  {
        require(_auctionIndexs.length == _auctionAmounts.length, "Invalid auction amount and index");
        for(uint i = 0; i < _auctionIndexs.length; i++){
            modifyAuction(_auctionIndexs[i], _auctionAmounts[i]);
        }
    }

    function modifyAuction(uint _auctionIndex, uint _auctionAmount) public onlyOwner {
        // require(_auctionInd)
        auction[_auctionIndex] = _auctionAmount;
        emit ModifyAuction(_auctionIndex, _auctionAmount);
    }

    function modifyBurn(bool _burn) external {
        shouldBurnToken = _burn;
    }

    function modifyBurnAddress(address _burnAddress) public {
        burnAddress = _burnAddress;
        emit ModifyBurnAddress(_burnAddress);
    }

    function updateDutchExchange(DutchExchange _dx) external onlyOwner {
        dx = _dx;
    }

    /**
     * @notice deposit
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function deposit(address _token, uint _amount) public onlyOwner returns (uint) {
        require(_amount > 0, "Amount must be greater than 0");
        require(_token == sellToken, "Only alloweds");
        require(Token(_token).transferFrom(msg.sender, this, _amount), "Transfer not successful");
        
        balances[_token] += _amount;
        emit Deposit(_token, _amount);

        return _amount;
    }

    /**
     * @notice approve trading
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function approve() public {
        // approve the dx proxy contract to trade on my behalf
        // _sellToken
        for( uint i = 0; i < auctionIndexes.length; i++ ) {
            dx.postSellOrder(sellToken, buyToken, auctionIndexes[i], auction[auctionIndexes[i]]);
        }
    }

    /**
     * @notice approve trading
     * @param token Address of the deposited token 
     * @param _sellToken Address of the polytoken
     * @param _burn Should burn the token after buy back success
     * @param 
     */
    function claim() public {
        uint balance;

        for(uint i = 0; i < auctionIndexes.length; i++) {
            (balance, ) = dx.claimSellerFunds(sellToken, buyToken, this, auctionIndexes[i]);
            if(shouldBurnToken == true){
                if( burnAddress != address(0) ){
                    burnTokensWithAddress(buyToken, burnAddress, balance);
                }

                burnTokens(buyToken, balance);
            }
            emit Withdraw(sellToken, buyToken, balance, auctionIndexes[i]);
        }
    }

    /**
     * @notice burnTokens
     * @param _token Address of the  token
     * @param _amount Amount of tokens to burn
     */
    function burnTokens(address _token, uint _amount) public {
        // transfer the tokens to address(0)
        require(_amount > 0, "Amount should be greater than 0");
        require(Token(_token).transferFrom(this, address(0), _amount), "Failed transfer");
        emit Burn(
            _token,
            address(0),
            _amount
        );
    }

    /**
     * @notice burnTokensWithAddress
     * @param _token Address of the  token
     * @param _amount Amount of tokens to burn
     * @param _burnAddress Address to send burn tokens
     */
    function burnTokensWithAddress(address _token, address _burnAddress, uint _amount) public {
        // transfer the tokens to address(0)
        require(_amount > 0, "Amount required to be greater than 0");
        require(Token(_token).transferFrom(this, _burnAddress, _amount), "Failed to transfer to burn address");
        emit Burn(
            _token,
            _burnAddress,
            _amount
        );
    }

}