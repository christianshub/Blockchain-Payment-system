pragma solidity ^0.5.8;

import "./Payments.sol";

/*
    The market place
*/
contract DiGiDiMarketPlace is Payments {
    using SafeMath for uint256;

    event IPFSAddressEvent(string, bytes32);
    event GetMediaFilePriceEvent(uint256);

    //ToDo: Use real IPFS adresses
    string constant TEMPORARY_IPFS_ADDRESS = "asdadas";


    constructor() public {
        approverMap[msg.sender] = true;
    }


    // Manages that a user is able to retrieve a media file
    function requestMediaFileStream(bytes32 mediaId) public payable returns(bool) {
        // The price of the song
        uint256 price = getPrice(mediaId);

        require(price > 0, "Media has no price");

        // Make sure the msg had enough ether
        require(price <= msg.value, "Not enough funds sent");

        // For testing, as there is no real access control implementation
        require(mediaLibrary[mediaId].approved || approverMap[msg.sender], "You are not permitted to access this file");

        // Update the balance of all stakeholders
        updateOwed(mediaId);

        // Pay back change
        uint256 change = msg.value.sub(price);

        emit IPFSAddressEvent(TEMPORARY_IPFS_ADDRESS, mediaId);
        msg.sender.transfer(change);

        return true;
    }

    function getPrice(bytes32 mediaId) public returns (uint256) {
        emit GetMediaFilePriceEvent(mediaLibrary[mediaId].price);
        return mediaLibrary[mediaId].price;
    }
}