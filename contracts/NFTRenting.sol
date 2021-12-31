pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTRenting is Ownable, IERC721Receiver{

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Lending {
        address lender;
        uint256 price;
        uint256 maxDuration;
        uint256[] rentingIds;
    }

    struct Renting {
        address renter;
        address lender;
        uint256 tokenId;
        uint256 duration;
        uint256 rentedAt;
    }

    constructor(
        address _nftAddress,
        address _beneficiary
    ) public {
        nftAddress = IERC721(_nftAddress);
        beneficiary = _beneficiary;
    }

    address beneficiary;

    IERC721 public nftAddress;

    uint256 private _feeService = 0;   
    uint256 public SECOND_PER_HOUR = 3600;
    uint256 public rentingId = 1;    

    mapping(uint256 => Lending) private _lendingInfo;

    mapping(address => EnumerableSet.UintSet) private _tokenIdWithLending;

    mapping(uint256 => Renting) private _rentingInfo;

    mapping(address => EnumerableSet.UintSet) private _rentingIdWithRenting;

    event Lend(address indexed lender, uint256 indexed tokenId, uint256 maxDuration, uint256 price);
    event Rent(address indexed renter, address indexed lender, uint256 rentingId, uint256 price, uint256 duration, uint256 rentedAt);

    event CancelLending(address indexed lender, uint256 indexed tokenId);
    event UpdateLending(address indexed lender, uint256 indexed lendingId, uint256 price, uint256 maxDuration);

    //FALLBACK FUNCTION
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
    //============================================VIEW FUNCTION ===========================================================
    //============================================VIEW LENDING ============================================================

    //get lending infomation by 1 address
    function getTokenLendingsByAddress(address lender)
        external
        view
        returns (Lending[] memory)
    {
            uint256 length = _tokenIdWithLending[lender].length(); 

            Lending[] memory lendings = new Lending[](length);
            for (uint256 i = 0; i < length; i++) {
                uint256 tokenId = _tokenIdWithLending[lender].at(i);
                Lending memory lending = _lendingInfo[tokenId];
                lendings[i] = lending;
            }
            return lendings;
    }

    function getTokenIdsLendingsByAddress(address lender)
        external
        view
        returns (uint256[] memory)
    {
            uint256 length = _tokenIdWithLending[lender].length(); 

            uint256[] memory tokenIds = new uint256[](length);
            for (uint256 i = 0; i < length; i++) {
                tokenIds[i] = _tokenIdWithLending[lender].at(i);
            }
            return tokenIds;
    }

    function getLendingInfo(uint256 tokenId) external view returns(Lending memory) {
        Lending memory lending = _lendingInfo[tokenId];
        return lending;
    }

    //===============================================VIEW RENTING ==================================================

    function getTokenRenting(uint256 _rentingId) external view returns(Renting memory) {
        Renting memory renting = _rentingInfo[_rentingId];

        return renting;
    }

    function getTokenIdsByAddress(address lender) public view returns(uint256[] memory){
            uint256 length = _tokenIdWithLending[lender].length(); 

            uint256[] memory tokenIds = new uint256[](length);
            for (uint256 i = 0; i < length; i++) {
                tokenIds[i] = _tokenIdWithLending[lender].at(i);
            }
            return tokenIds;
    }

    function getBatchTokenRentings(uint256 from, uint256 to) public view returns(Renting[] memory) {

        Renting[] memory rentings;
        for(uint256 i = from; i < to; i++) {
            Renting memory renting = _rentingInfo[i];
            rentings[i] = renting;
        }
        return rentings;
    }

    function getAllTokenRentings() external view returns(Renting[] memory) {

        return getBatchTokenRentings(0, rentingId);
    }


    function  getAllRentingByTokenId( uint256 tokenId) external view returns(Renting[] memory) {
        uint256[] memory rentingIds = _lendingInfo[tokenId].rentingIds;
        uint256 length = rentingIds.length;
        Renting[] memory rentings = new Renting[](length);
        for(uint256 i = 0; i < length; i++) {
            Renting memory renting = _rentingInfo[rentingIds[i]];
            rentings[i] = renting;   
        }
        return rentings;
    }

    //===================================================PRIVATE FUNCTION================================================

    function isRentingExpired(Renting memory renting) private view returns(bool) {
        if(block.timestamp > renting.rentedAt.add(renting.duration)) {
            return true;
        }
    }

    //==================================================== PUBLIC FUNCTION ==============================================
    //==================================================== LEND FUNCTION ================================================
    function lendToken(
        uint256 tokenId,
        uint256 rentPrice,
        uint256 maxDuration
    ) external {
        _lendToken(tokenId, rentPrice, maxDuration);
    }

    function cancelLendingToken(uint256 _tokenId) public {
        _cancelLendingToken(_tokenId);
    }

    //=============================================RENT FUNCTION =====================================================

    function rentToken(uint256 tokenId, uint256 duration) external payable {
        _rentToken(tokenId, duration);

    }

    //================================================== PRIVATE FUNCTION =======================================================
    //================================================== LEND FUNCTION ==========================================================
    function _lendToken(uint256 _tokenId, uint256 _rentPrice, uint256 _maxDuration) private {
        address lender = msg.sender;
        Lending storage lending = _lendingInfo[_tokenId];
        lending.lender = lender;
        lending.price = _rentPrice;
        lending.maxDuration = _maxDuration;
        if(!_tokenIdWithLending[lender].contains(_tokenId)) {
            _tokenIdWithLending[lender].add(_tokenId);
        }
        nftAddress.safeTransferFrom(lender, address(this), _tokenId);
        emit Lend(lender, _tokenId, _maxDuration, _rentPrice);
    }

    function _cancelLendingToken(uint256 _tokenId) private {

        address lender = msg.sender;
        require(_tokenIdWithLending[lender].contains(_tokenId), "not lender");
        uint256[] storage rentingIds = _lendingInfo[_tokenId].rentingIds;

        uint256 length = rentingIds.length;
        for(uint256 i = 0; i < length; i++) {
            Renting memory renting = _rentingInfo[rentingIds[i]];
            if( block.timestamp > renting.rentedAt + renting.duration) {
                _rentingIdWithRenting[renting.renter].remove(rentingIds[i]);
                _removeElement(rentingIds, i);
            }
        }

        nftAddress.safeTransferFrom(address(this), lender, _tokenId);
        delete _lendingInfo[_tokenId];
        _tokenIdWithLending[lender].remove(_tokenId);
        emit CancelLending(lender, _tokenId);

    }

    //================================================== RENT FUNCTION =========================================================

    function _rentToken(uint256 _tokenId, uint256 duration) private {
        address renter = msg.sender;
        Lending memory lending = _lendingInfo[_tokenId];

        address lender = lending.lender;
        require(renter != lender, "lender can't rent himself");

        uint256[] storage rentingIds = _lendingInfo[_tokenId].rentingIds;

        uint256 length = rentingIds.length;
        for(uint256 i = 0; i < length; i++) {
            Renting memory renting = _rentingInfo[rentingIds[i]];
            if( block.timestamp > renting.rentedAt.add(renting.duration)) {
                _rentingIdWithRenting[renting.renter].remove(rentingIds[i]);
                _removeElement(rentingIds, i);
            }
        }
        require(duration <= lending.maxDuration, "exceeds time");

        uint256 amountPay = lending.price.mul(duration).div(SECOND_PER_HOUR);
        uint256 fees = amountPay.mul(_feeService).div(10000);
        require(msg.value >= amountPay, "exceeds balance");

        //send lender bnb
        payable(lender).transfer(amountPay.sub(fees));

        rentingIds.push(rentingId);

        _rentingInfo[rentingId] = Renting(renter, lender, _tokenId, duration, block.timestamp);
        
        emit Rent(renter, lender, rentingId, lending.price, duration, block.timestamp);
        
        //send overleft
        if(msg.value > amountPay) {
            payable(msg.sender).transfer(msg.value.sub(amountPay));
        }
        _rentingIdWithRenting[renter].add(rentingId);
        rentingId ++;

    }

    //==================================================RESTRICT FUNCTION=======================================================

    function setFee(uint256 _newFee) external onlyOwner {
        _feeService = _newFee;
    }
    
    //===================================================ACTION FUNCTION========================================================
    
    function _removeElement(uint256[] storage array , uint256 index) private {
        array[index] =  array[array.length - 1];
        array.pop();
    }
    
}