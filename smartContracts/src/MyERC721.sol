// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;	

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721 {

    error MyERC721_NotOwnerOrApproved();
    error MyERC721_LimitReached();
    error MyERC721_ZeroAddress();

    /**
     * @notice there is 2 mappings to facilitate the tranfer of tokens. :
     *  1. s_tokenURIs is a mapping that stores the token URI for each token ID.
     *  2. s_owners is a mapping that stores the owner of each token ID.
     */
    mapping (uint256 id => string) public s_tokenURIs;
    mapping (uint256 tokenId => address) public s_creators;
    mapping (address owner => uint256 tokenIds) public s_creatorsCount;

    uint256 public constant MAX_TOKENS = 10;

    uint256 public tokenCounter;

    constructor() ERC721("EduVemba","EV") {
        tokenCounter = 0;
    }
    /**
     * @dev This is a mint function that requires a string as an argument-
     * @notice The string is the image URI of the NFT.
     * The mint send the token to me so it is contract property to send the NFT to the winner
     * 
     */
    function mint(string memory _imagURI) public {
        if (s_creatorsCount[msg.sender] == MAX_TOKENS) {
            revert MyERC721_LimitReached();
        }
        s_tokenURIs[tokenCounter] = _imagURI;
        s_creators[tokenCounter] = msg.sender;
        s_creatorsCount[msg.sender]++;
        _safeMint(address(this), tokenCounter);
        tokenCounter++;
    }

    /**
     * 
     * @param _winner send the NFT for a random winner or
     * if No one entered the game then it sends to the owner of the contract.
     * 
     */
    function transferToken(address _winner, uint256 tokenId) public {
        if (_winner == address(0)) {
            revert MyERC721_ZeroAddress();
        }
        if (ownerOf(tokenId) != address(this)) {
            revert MyERC721_NotOwnerOrApproved();
        }
        _safeTransfer(address(this), _winner, tokenId, "");
    }

    /**
     * 
     * @param tokenId is the id of the token to be transferred.
     */
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return s_tokenURIs[tokenId];
    }

    
}