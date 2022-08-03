// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Bored is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 _maxSupply = 10000;
    uint256 _tokenId = 0;
    uint256 public _price = 0.25 ether; //change
    uint256 public _wlprice = 0.20 ether;
    string baseURI =
        "https://gateway.pinata.cloud/ipfs/Qmb4SR94qhMGktfJGjUB5ZkwoVvcCKAs3t1SJsRX3vV3Pu/"; //change
    string baseExtension = ".json";
    mapping(address => bool) public presaleWallets;
    uint256 public presaleTime = block.timestamp + 30; //change

    constructor() ERC721("Bored Bulldogs", "BBD") {}

    //---------------------------------------------------------------------------------//
    function mint(address _to) external payable {
        require(_maxSupply > 0);
        if (presaleWallets[_to] != true) {
            require(getpresaleTime(), "Public Sale Not Opened");
            require(this.balanceOf(_to) <= 5, "Already minted Enough");
            require(_price <= msg.value, "Not Enough Ether");
            safeMint(_to);
        } else {
            require(_wlprice <= msg.value, "Not Enough Ether");
            safeMint(_to);
        }
    }

    //---------------------------------------------------------------------------------//
    function safeMint(address to) public {
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, mergedURI());
        _tokenId++;
        _maxSupply--;
    }

    //---------------------------------------------------------------------------------//
    function getpresaleTime() public view returns (bool) {
        if (block.timestamp > presaleTime) {
            return true;
        } else return false;
    }

    //---------------------------------------------------------------------------------//
    function addPresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = true;
    }

    //---------------------------------------------------------------------------------//
    function removePresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = false;
    }

    //---------------------------------------------------------------------------------//
    function setPrice(uint256 _newPrice) public onlyOwner {
        _price = _newPrice;
    }

    //---------------------------------------------------------------------------------//
    function setWLPrice(uint256 _newPrice) public onlyOwner {
        _wlprice = _newPrice;
    }

    //---------------------------------------------------------------------------------//
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //---------------------------------------------------------------------------------//
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    //---------------------------------------------------------------------------------//
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    //---------------------------------------------------------------------------------//
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mergedURI() public view returns (string memory) {
        return
            string(
                abi.encodePacked(baseURI, uint2str(_tokenId), baseExtension)
            );
    }

    //---------------------------------------------------------------------------------//
    //Not a part of code
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
//royalty to be added
