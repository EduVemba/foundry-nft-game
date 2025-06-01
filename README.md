# NFT Game

  This is an NFT Game that lets users send NFTs so it can be sended Randomly to the ones on NFT pool and make creators make money of their creation.

   ## Functions

   Principal functions:

   ```shell
        function createGame(string memory _imageURI);

        function enterGame(uint256 _gameId);
   ``` 
   ⚠️ The others function are Openzeppelin ERC721 overrided and Chainlink VRF and UpKepp Automation for random winner and Auto-Game closure.


   # TODO:
     1- Unit Tests;
     2- Integration Tests;
     3- Deployable;
     4- Web for Interaction.
        1- Ethers.js;
        2- wallet connection;
        3- interface for game interaction.
            1- create;
            2- enter.

   # Tech stack
    Solidity + Foundry
    Chainlink VRF + Automation
    OpenZeppelin Contracts (ERC721)
    Ethers.js + HTML/CSS