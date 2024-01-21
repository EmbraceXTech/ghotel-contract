// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./interfaces/IPBM.sol";
import "./interfaces/ITravelLogic.sol";
import "./interfaces/ITravelPBMManager.sol";

contract TravelPBM is ERC1155, IPBM {
    address public sovToken;
    uint256 public expiry;
    address public pmbLogic;
    address public pbmTokenManager;

    address private _owner;
    bool private _initialized;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner");
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "Initialized");
        _;
    }

    constructor(string memory uri_) ERC1155(uri_) {
        _owner = msg.sender;
    }

    function initialise(
        address _sovToken,
        uint256 _expiry,
        address _pbmLogic,
        address _pbmTokenManager
    ) external override onlyOwner notInitialized {
        // Sanity check
        IERC20(_sovToken).totalSupply();
        ITravelLogic(_pbmLogic).isMerchant(0, address(0));
        ITravelPBMManager(_pbmTokenManager).getTokenDetails(0);
        require(block.timestamp < _expiry, "Expired");

        sovToken = _sovToken;
        expiry = _expiry;
        pmbLogic = _pbmLogic;
        pbmTokenManager = _pbmTokenManager;
        _initialized = true;
    }

    function uri(uint256 tokenId) public view override(ERC1155, IPBM) returns (string memory) {
        return ITravelPBMManager(pbmTokenManager).getTokenDetails(tokenId).uri;
    }

    function safeMint(
        address receiver,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public override {
        require(
            !ITravelLogic(pmbLogic).isBlacklisted(receiver),
            "The receiver is on blacklist"
        );

        uint _mintAmount = ITravelPBMManager(pbmTokenManager).sovToPBM(tokenId, amount);

        IERC20(sovToken).transferFrom(msg.sender, address(this), amount);
        _mint(receiver, tokenId, _mintAmount, data);
        ITravelPBMManager(pbmTokenManager).increaseTotalSupply(tokenId, _mintAmount);

        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);

        emit TokenWrap(msg.sender, tokenIds, amounts, sovToken, amount);
    }

    function safeMintBatch(
        address receiver,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override {
        require(tokenIds.length == amounts.length, "Length mismatch");

        for (uint i = 0; i < tokenIds.length; i++) {
            safeMint(receiver, tokenIds[i], amounts[i], data);
        }
    }

    function burn(
        address from,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override onlyOwner {
        ITravelPBMManager _manager = ITravelPBMManager(pbmTokenManager);
        require(
            block.timestamp >= _manager.getTokenDetails(tokenId).expiry, "Not expired"
        );
        uint _sovAmount = _manager.pbmToSov(tokenId, amount);
        _burn(from, tokenId, amount);
        IERC20(sovToken).transfer(_owner, _sovAmount);
        ITravelPBMManager(pbmTokenManager).decreaseTotalSupply(tokenId, amount);

        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);

        tokenIds[0] = tokenId;
        amounts[0] = amount;

        emit TokenUnwrapForPBMBurn(from, _owner, tokenIds, amounts, sovToken, _sovAmount);
    }

    function burnBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) public override {
        require(tokenIds.length == amounts.length, "Length mismatch");

        for (uint i = 0; i < tokenIds.length; i++) {
            burn(from, tokenIds[i], amounts[i], data);
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override(ERC1155, IPBM) {
        ITravelLogic _logic = ITravelLogic(pmbLogic);
        ITravelPBMManager _manager = ITravelPBMManager(pbmTokenManager);
        require(
            !_logic.isBlacklisted(to),
            "The receiver is on blacklist"
        );
        require(
            block.timestamp < _manager.getTokenDetails(id).expiry, "Expired"
        );
        // Check is unwrappable
        // unwrap

        // Otherwise transfer
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override(ERC1155, IPBM) {
        for (uint i = 0; i < ids.length; i++) {
            safeTransferFrom(from, to, ids[i], amounts[i], data);
        }
    }

    function unwrap(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external override {
        // Add unwrap conditions
        uint sovAmount = ITravelPBMManager(pbmTokenManager).pbmToSov(tokenId, amount);
        burn(from, tokenId, amount, data);
        IERC20(sovToken).transfer(to, sovAmount);

        uint256[] memory tokenIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);

        tokenIds[0] = tokenId;
        amounts[0] = amount;

        emit TokenUnwrapForPBMBurn(from, to, tokenIds, amounts, sovToken, sovAmount);
    }

    function revokePBM(uint256 tokenId) external override onlyOwner {
        ITravelPBMManager _manager = ITravelPBMManager(pbmTokenManager);
        require(
            block.timestamp >= _manager.getTokenDetails(tokenId).expiry, "Not expired"
        );
        uint _totalSupply = _manager.getTokenDetails(tokenId).totalSupply;
        uint _sovAmount = _manager.pbmToSov(tokenId, _totalSupply);
        _manager.decreaseTotalSupply(tokenId, _totalSupply);
        IERC20(sovToken).transfer(_owner, _sovAmount);

        emit PBMrevokeWithdraw(_owner, tokenId, sovToken, _sovAmount);
    }

    function transferOwnership(address _newOwner) external override {
        _owner = _newOwner;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        uint _totalSupply =  ITravelPBMManager(pbmTokenManager).getTokenDetails(id).totalSupply;
        if (_totalSupply == 0) return 0;
        return super.balanceOf(account, id);
    }

    function owner() external view override returns (address) {
        return _owner;
    }
}
