const MediaLibrary = artifacts.require("MediaLibrary");

module.exports = function(deployer) {
    deployer.deploy(MediaLibrary);
};