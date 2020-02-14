pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
    The smart contract should fulfill all requirements of the ERC20 standard as required by the Drizzle Framework
*/

contract MediaLibrary is ERC20 {
    using SafeMath for uint256;

    // The share represents the divisor
    struct Share {
        address shareholder;
        uint8 share;
    }

    struct  MediaFile {
        address artist;
        bool approved;
        uint256 price;
        string ipfsAddress;
    }

    mapping(bytes32 => MediaFile) public mediaLibrary;
    mapping(bytes32 => Share[]) public shareholderLibrary;
    mapping(address => bool) approverMap;


    uint256 numOfMediaFiles;    // Number of media files
    address payable owner;      // Person, who deployed this smart contract


    event MediaIDEvent(bytes32);


    constructor() public {
        owner = msg.sender;
        numOfMediaFiles = 0;
    }

    // Add a new media file to the smart contract
    function registerMediaFile(bytes32 mediaId, uint256 price, string memory ipfsAddress, address[] memory shareholders, uint8[] memory shares) public returns(bool) {
        require(shareholders.length == shares.length, "Shareholders and shares are not of the same length");

        mediaLibrary[mediaId] = MediaFile(tx.origin, false, price, ipfsAddress);

        bool artistIncluded = false;

        for(uint8 i=0; i < shareholders.length; i++) {
            require(shares[i] > 0, "Shares must be bigger than zero!");

            Share memory s = Share(shareholders[i], shares[i]);
            shareholderLibrary[mediaId].push(s);

            if(shareholders[i] == msg.sender)
                artistIncluded = true;
        }

        // The media file being uploaded, downloaded, or streamed
        numOfMediaFiles = numOfMediaFiles.add(1);

        emit MediaIDEvent(mediaId);

        return true;
    }

    //Returns the current number of media files orchestrated by the smart contract
    function getNumOfMediaFiles() public view returns(uint256) {
        return numOfMediaFiles;
    }

    // Update a registered media file
    // Should also be doable
    function updateMediaFile(bytes32 oldFileHash, bytes32 newFileHash, uint8 newPrice, string memory ipfsArray, address[] memory shareholders, uint8[] memory shares) public returns(bool) {

        if(mediaLibrary[oldFileHash].artist  == msg.sender) {
            delete mediaLibrary[oldFileHash];

            mediaLibrary[newFileHash] = MediaFile(msg.sender, false, newPrice, ipfsArray);
        }

        return true;
    }


    // Remove an already registered media file from the smart contract registry
    function unregisterMediaFile(bytes32 trackId) public returns(bool) {
        require(mediaLibrary[trackId].artist == msg.sender, "You are not the owner.");

        delete mediaLibrary[trackId];
        numOfMediaFiles = numOfMediaFiles.sub(1);

        return true;
    }


    // Request an registered media file hash and artist
    function checkAccessToMediaFile(string memory trackId) private view returns (bool) {
        MediaFile memory mediaFile = mediaLibrary[stringToBytes32(trackId)];

        if(mediaFile.approved == true || approverMap[msg.sender])
            return true;

        return false;
    }

    // Approve a registered media file
    function approveMediaFile(string memory trackId, bool approved) public view returns(bool) {
        require(approverMap[msg.sender], "Not allowed to approve the media file");

        MediaFile memory file = mediaLibrary[stringToBytes32(trackId)];
        file.approved = approved;

        return true;
    }


    /**
      Below, there are helper functions for the conversion of data types
    */

    // Convert string to bytes32
    function stringToBytes32(string memory source) public pure returns(bytes32 result) {
        bytes memory tmpEmptyStringTest = bytes(source);
        if (tmpEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    // Set or revoke the permission to approve songs
    function updateApprover(address usr, bool permission) public returns(bool) {
        if(approverMap[msg.sender] && usr != owner)
            approverMap[usr] = permission;

        return true;
    }
}