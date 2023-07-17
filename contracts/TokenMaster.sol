// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact skka3134@gmail.com
contract TokenMaster is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public totalOccasions;

    struct Occasion {
        uint256 id;
        string name;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
    }
    mapping(uint256 => Occasion) occasions;
    mapping(uint256 => mapping(address => bool)) public hasBought;
    mapping(uint256 => mapping(uint256 => address)) public seatTaken;
    mapping(uint256 => uint256[]) seatsTaken;

    constructor() ERC721("TokenMaster", "TM") {}

    function list(
        string memory _name,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) public onlyOwner {
        totalOccasions++;
        occasions[totalOccasions] = Occasion(
            totalOccasions,
            _name,
            _cost,
            _maxTickets,
            _maxTickets,
            _date,
            _time,
            _location
        );
    }

    function safeMint(uint256 _id, uint256 _seat) public payable {
        require(_id != 0);
        require(_id <= totalOccasions);

        require(msg.value >= occasions[_id].cost);

        require(seatTaken[_id][_seat] == address(0));
        require(_seat <= occasions[_id].maxTickets);
        occasions[_id].tickets -= 1;

        hasBought[_id][msg.sender] = true;
        seatTaken[_id][_seat] = msg.sender;

        seatsTaken[_id].push(_seat);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function getOccasion(uint256 _id) public view returns (Occasion memory) {
        return occasions[_id];
    }

    function getSeatsTaken(uint256 _id) public view returns (uint256[] memory) {
        return seatsTaken[_id];
    }

    // function withdraw() public onlyOwner {
    //     (bool success, ) = owner.call{value: address(this).balance}("");
    //     require(success);
    // }
}
