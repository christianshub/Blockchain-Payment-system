pragma solidity ^0.5.8;
// The current version does not use micropayments, uRaiden, nor state-channels.
// These are all technologies which could be used, but given the constraints of a 2 day hack a ton

// The purpose of this contract is to check that user has access to the song.
// If the user does not have access, the user should pay
// and then split then funds among the shares

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/payment/PullPayment.sol";
import "./MediaLibrary.sol";

contract Payments is MediaLibrary {
    using SafeMath for uint256;

    uint safeIndexOwed = 0;
    address payable owner;

    /**
        The map of tokens/money owed.
        The address is the address of the shareholders, and the money owed to them
        All values are calculated in Finney because of the insufficient decimal calculation of Solidity
    */
    mapping (address => uint256) owed;

    constructor() public {
        owner = msg.sender;
    }

    // Payout to the msg.sender if they are owe some ether
    function requestPayment() public returns(bool) {
        uint256 amounts = owed[msg.sender];
        owed[msg.sender] = 0;

        msg.sender.transfer(amounts);

        return true;
    }

    // Lets the msg.sender know their balance
    function getBalance() internal view returns (uint256) {
        return getUserBalance(msg.sender);
    }

    function getUserBalance(address usr) internal view returns(uint256) {
        return owed[usr];
    }

    // Whenever a MediaFile is purchased, we update the amount owed
    // Using safeIndexOwed to get along with potential out of gas exceptions
    function updateOwed(bytes32 mediaID) internal returns(bool) {

        uint8 numOfShares = 0;

        for (uint i=safeIndexOwed; i<shareholderLibrary[mediaID].length; i++) {
            Share memory currentShare = shareholderLibrary[mediaID][i];

            // There might be some problems with the rounding and stuff
            // The inverse of the shares should add up to one
            uint256 amountToShareholder_i = mediaLibrary[mediaID].price / currentShare.share;
            owed[currentShare.shareholder] += amountToShareholder_i;

            safeIndexOwed.add(1);

            numOfShares = numOfShares+1;
        }

        safeIndexOwed = 0;


        return true;
    }
}
