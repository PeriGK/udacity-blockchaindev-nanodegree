
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";


contract StarNotary is ERC721 {
    struct Star {
        string name;
    }

    address public owner;
	// tokenId -> Star
    mapping(uint256 => Star) public tokenIdToStarInfo;
	// tokenId -> price
    mapping(uint256 => uint256) public starsForSale;

	// subtask 1.1 - Add a name and a symbol for your starNotary tokens.
    // check doc https://docs.openzeppelin.com/contracts/3.x/erc721
    constructor (string memory name, string memory symbol)
        public
        ERC721("MyStarNotary", "MSN")
    {}

	// subtask 1.2 - Looks up the stars using the Token ID, and then returns the name of the star.
	function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns (string memory) {
		return tokenIdToStarInfo[_tokenId].name;
	}

	// subtask 1.3 - Add a function called exchangeStars, so 2 users can exchange their star tokens...Do not worry about the price, just write code to exchange stars between users.
	function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address sender1 = ownerOf(_tokenId1);
        address sender2 = ownerOf(_tokenId2);
		transferFrom(sender1, sender2, _tokenId1);
		transferFrom(sender2, sender1, _tokenId2);
	}

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public {
        // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You can't sale the Star you don't owned"
        );
        starsForSale[_tokenId] = _price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if (msg.value > starCost) {
            // Refund the sender if more value than needed is provide
            msg.sender.transfer(msg.value - starCost);
        }
    }
}
