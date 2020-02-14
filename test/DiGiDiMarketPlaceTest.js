const MediaLibrary = artifacts.require("MediaLibrary");
const DiGiDiMarketPlace = artifacts.require("DiGiDiMarketPlace");

const chai = require('chai');
const BN = require('bn.js');

chai.should();
chai.use(require('chai-bn')(BN));

contract("DiGiDiMarketPlace", accounts => {

    it("get the number of registered media files", async () => {
        const digidi = await MediaLibrary.new();

        let actualVal = await digidi.getNumOfMediaFiles();
        actualVal.should.be.a.bignumber.that.equals("0");

        let file = "my-file-as-a-string";
        let mediaId = web3.utils.sha3(file);

        await digidi.registerMediaFile(mediaId, 2, "IPFS address", [accounts[0], accounts[1], accounts[2]], [3, 3, 3]);

        actualVal = await digidi.getNumOfMediaFiles();
        actualVal.should.be.a.bignumber.that.equals("1");
    });

    it("Request media file",  async () => {
        const digidi = await DiGiDiMarketPlace.new();


        // Here we create a "file" and hash it
        let file = "my-file-as-a-string";
        let mediaId = web3.utils.sha3(file);

        // We record the old balances of accounts
        let oldBalanceAccount0 = await web3.eth.getBalance(accounts[0]);
        let oldBalanceAccount1 = await web3.eth.getBalance(accounts[1]);
        let oldBalanceAccount2 = await web3.eth.getBalance(accounts[2]);

        // We register a MediaFile, with a price 2 Ether, a dummy IPFS address, and the share distribution as shown in the args
        await digidi.registerMediaFile(mediaId, web3.utils.toWei("2"), "IPFS address", [accounts[0], accounts[1], accounts[2]], [3, 3, 3]);

        // Add an approver
        await digidi.updateApprover(accounts[1], true);

        // Approve media file
        await digidi.approveMediaFile(mediaId, true);

        // Here, we "play" the song by requesting it via its mediaId and sending 3 Ether along - enough for the song
        await digidi.requestMediaFileStream(mediaId, {value:web3.utils.toWei("3")});

        //Get Payments
        await digidi.requestPayment({from:accounts[0]});
        let newBalanceAccount0 = await web3.eth.getBalance(accounts[0]);

        await digidi.requestPayment({from:accounts[1]});
        let newBalanceAccount1 = await web3.eth.getBalance(accounts[1]);

        await digidi.requestPayment({from:accounts[2]});
        let newBalanceAccount2 = await web3.eth.getBalance(accounts[2]);


        assert(newBalanceAccount0 < oldBalanceAccount0, "The balance was not updated for accountZerp");
        assert(newBalanceAccount1 > oldBalanceAccount1, "The balance was not updated for accountOne");
        assert(newBalanceAccount2 > oldBalanceAccount2, "The balance was not updated for accountTwo");
    });

    it("Artist not included",  async () => {
        const digidi = await DiGiDiMarketPlace.new();

        let file = "my-file-as-a-string";
        let mediaId = web3.utils.sha3(file);
        await digidi.registerMediaFile(mediaId, web3.utils.toWei("2"), "IPFS address", [accounts[1], accounts[2]], [3, 3]);
    });


});

