// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Pausable.sol";
import "./Modifier.sol";

contract Pool1 is Pausable, Modifier {
    
    using SafeMath for uint256;

    constructor (ERC20 _bamiTokenAddress, ERC20 _BUSDTokenAddress, ERC20 _hesmanTokenAddress) {
        bamiTokenAddress = _bamiTokenAddress;
        BUSDTokenAddress = _BUSDTokenAddress;
        hesmanTokenAddress = _hesmanTokenAddress;
        initialTime = block.number.mul(3);
    } //x

    // Function to change address of Bami, BUSD and Hesman token
    // Choose 0 for Bami, 1 for BUSD, 2 for Hesman
    function changeTokenAddress(uint256 _options, ERC20 _tokenAddress) external onlyOwner {
        require(_options >= 0 && _options <= 2, "Input 0 for Bami, 1 for BUSD, 2 for Hesman");
        if(_options == 0) {
            bamiTokenAddress = _tokenAddress;
        } else if(_options == 1) {
            BUSDTokenAddress = _tokenAddress;
        } else if(_options == 2) {
            hesmanTokenAddress = _tokenAddress;
        }
    } //x

    // Withdraw all tokens inside this pool to owner
    // Choose 0 for Bami, 1 for BUSD, 2 for Hesman, any other number to transfer all
    function ownerWithdrawALLToken(uint256 _options) external onlyOwner {
        if(_options == 0) {
            bamiTokenAddress.transfer(msg.sender, bamiTokenAddress.balanceOf(address(this)));
        } else if(_options == 1) {
            BUSDTokenAddress.transfer(msg.sender, BUSDTokenAddress.balanceOf(address(this)));
        } else if(_options == 2) {
            hesmanTokenAddress.transfer(msg.sender, hesmanTokenAddress.balanceOf(address(this)));
        } else {
            bamiTokenAddress.transfer(msg.sender, bamiTokenAddress.balanceOf(address(this)));
            BUSDTokenAddress.transfer(msg.sender, BUSDTokenAddress.balanceOf(address(this)));
            hesmanTokenAddress.transfer(msg.sender, hesmanTokenAddress.balanceOf(address(this)));
        }
    } //x

    // Withdraw certain amount of token from this pool to owner
    // Choose 0 for Bami, 1 for BUSD, 2 for Hesman, any other number to transfer all
    function ownerWithdrawToken(uint256 _options, uint256 _amount) external onlyOwner {
        if(_options == 0) {
            bamiTokenAddress.transfer(msg.sender, _amount);
        } else if(_options == 1) {
            BUSDTokenAddress.transfer(msg.sender, _amount);
        } else if(_options == 2) {
            hesmanTokenAddress.transfer(msg.sender, _amount);
        } else {
            bamiTokenAddress.transfer(msg.sender, _amount);
            BUSDTokenAddress.transfer(msg.sender, _amount);
            hesmanTokenAddress.transfer(msg.sender, _amount);
        }
    } //x


    // --------- ĐĂNG KÍ --------- //


    // Staking BAMI
    function stakeBamiToken(uint256 _amount) external isNotPaused isNotPassStakingTime isNotOutOfSlot hasNotStaked hasEnoughBamiTokenToStake {
        require(_amount >= BamiStakingLimit, "Your input is too small");
        bamiTokenAddress.transferFrom(msg.sender, address(this), _amount);
        userStakingAmount[msg.sender] = _amount;
        slotHasBeenBought++;
    } //x

    // --------- KẾT THÚC ĐĂNG KÍ --------- //



    // --------- MUA HESMAN --------- //


    // Buy Hesman with bami token
    function buyHesmanTokenWithBami(uint256 _amount) external isNotPaused isPassStakingTime hasStaked hasEnoughBamiToken(_amount) {
        bamiTokenAddress.transferFrom(msg.sender, address(this), _amount * BamiToHesmanExchangeRate);
        userOwnHesman[msg.sender] += _amount;
    }

    // Buy Hesman with BUSD
    function buyHesmanTokenWithBUSD(uint256 _amount) external isNotPaused isPassStakingTime hasStaked hasEnoughBUSDToken(_amount) {
        BUSDTokenAddress.transferFrom(msg.sender, address(this), _amount * BUSDToHesmanExchangeRate);
        userOwnHesman[msg.sender] += _amount;
    }

    // --------- KẾT THÚC MUA HESMAN --------- //


    // --------- RÚT HESMAN --------- //

    // Withdraw staked Bami token
    function withdrawStakedBamiToken() isNotPaused isUnStakeTime public {
        require(userStakingAmount[msg.sender] >= 5000, "You don't have aby Bami token");
        bamiTokenAddress.transfer(msg.sender, userStakingAmount[msg.sender]);
        userStakingAmount[msg.sender] = 0;
    }

    // Withdraw Hesman token
    function withdrawHesmanToken() isNotPaused isUnStakeTime external {
        require(userOwnHesman[msg.sender] > 0, "You don't have any Hesman token");
        hesmanTokenAddress.transfer(msg.sender, userOwnHesman[msg.sender]);
        userOwnHesman[msg.sender] = 0;
        withdrawStakedBamiToken();
    }

    // --------- KẾT THÚC RÚT HESMAN --------- //

}