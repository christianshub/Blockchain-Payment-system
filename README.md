## Getting started
### Prerequisites

(What things you need to install the software and how to install them)

### Installing

(something here on how to get a development env running)

### Testing
Start ganache and execute the following command in the root directory of your project

    truffle migrate --reset
    
Start the truffle console:

    truffle develop
    
Interact with your contract using in a test case:

    let digidi = await DiGiDiMarketPlace.new()
    digidi.getNumOfMediaFiles()
    
    // Register new file
    let mediaId = web3.utils.sha3("my-file-as-a-string")
    digidi.registerMediaFile(mediaId, web3.utils.toWei("2"), "IPFS address", [accounts[1], accounts[2]], [3, 3])
    
    digidi.getNumOfMediaFiles()
    
    // Returns fobidden access
    digidi.requestMediaFileStream(mediaId, {value:web3.utils.toWei("3"), from : accounts[1]});
    
    // Add approver
    digidi.updateApprover(accounts[1], true)
    
    // Approve media file
    digidi.approveMediaFile(mediaId, true)
    digidi.requestMediaFileStream(mediaId, {value:web3.utils.toWei("3")});
    
    // The pull payment
    let oldValueAccOne = web3.eth.getBalance(accounts[1]);
    digidi.requestPayment({from:accounts[1]});
    web3.eth.getBalance(accounts[1]);
        
    // Pull payment again...
    let oldValueAccTwo = web3.eth.getBalance(accounts[2]);
    digidi.requestPayment({from:accounts[2]});
    web3.eth.getBalance(accounts[2]);
    
## License

This project is licensed under the MIT License - see the (LICENSE.md) file for details
