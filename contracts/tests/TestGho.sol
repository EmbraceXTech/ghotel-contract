// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IGhoToken} from './interfaces/IGhoToken.sol';

import "hardhat/console.sol";

/**
 * @title ERC20
 * @notice Gas Efficient ERC20 + EIP-2612 implementation
 * @dev Modified version of Solmate ERC20 (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol),
 * implementing the basic IERC20
 */
abstract contract ERC20Permit is IERC20 {
  /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

  string public name;

  string public symbol;

  uint8 public immutable decimals;

  /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

  uint256 public totalSupply;

  mapping(address => uint256) public balanceOf;

  mapping(address => mapping(address => uint256)) public allowance;

  /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

  bytes32 public constant PERMIT_TYPEHASH =
    keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');

  uint256 internal immutable INITIAL_CHAIN_ID;

  bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

  mapping(address => uint256) public nonces;

  /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

  constructor(string memory _name, string memory _symbol, uint8 _decimals) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;

    INITIAL_CHAIN_ID = block.chainid;
    INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
  }

  /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

  function approve(address spender, uint256 amount) public virtual returns (bool) {
    allowance[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);

    return true;
  }

  function transfer(address to, uint256 amount) public virtual returns (bool) {
    balanceOf[msg.sender] -= amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
      balanceOf[to] += amount;
    }

    emit Transfer(msg.sender, to, amount);

    return true;
  }

  function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
    uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

    if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

    balanceOf[from] -= amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
      balanceOf[to] += amount;
    }

    emit Transfer(from, to, amount);

    return true;
  }

  /*///////////////////////////////////////////////////////////////
                              EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual {
    require(deadline >= block.timestamp, 'PERMIT_DEADLINE_EXPIRED');

    // Unchecked because the only math done is incrementing
    // the owner's nonce which cannot realistically overflow.
    unchecked {
      bytes32 digest = keccak256(
        abi.encodePacked(
          '\x19\x01',
          DOMAIN_SEPARATOR(),
          keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
        )
      );

      address recoveredAddress = ecrecover(digest, v, r, s);

      console.log("Recover: ", recoveredAddress);

      require(recoveredAddress != address(0) && recoveredAddress == owner, 'INVALID_SIGNER');

      allowance[recoveredAddress][spender] = value;
    }

    emit Approval(owner, spender, value);
  }

  function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
    return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
  }

  function computeDomainSeparator() internal view virtual returns (bytes32) {
    return
      keccak256(
        abi.encode(
          keccak256(
            'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
          ),
          keccak256(bytes(name)),
          keccak256('1'),
          block.chainid,
          address(this)
        )
      );
  }

  /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

  function _mint(address to, uint256 amount) internal virtual {
    totalSupply += amount;

    // Cannot overflow because the sum of all user
    // balances can't exceed the max uint256 value.
    unchecked {
      balanceOf[to] += amount;
    }

    emit Transfer(address(0), to, amount);
  }

  function _burn(address from, uint256 amount) internal virtual {
    balanceOf[from] -= amount;

    // Cannot underflow because a user's balance
    // will never be larger than the total supply.
    unchecked {
      totalSupply -= amount;
    }

    emit Transfer(from, address(0), amount);
  }
}

/**
 * @title GHO Token
 * @author Aave
 */
contract TestGho is ERC20Permit, AccessControl, IGhoToken {
  using EnumerableSet for EnumerableSet.AddressSet;

  mapping(address => Facilitator) internal _facilitators;
  EnumerableSet.AddressSet internal _facilitatorsList;

  /// @inheritdoc IGhoToken
  bytes32 public constant FACILITATOR_MANAGER_ROLE = keccak256('FACILITATOR_MANAGER_ROLE');

  /// @inheritdoc IGhoToken
  bytes32 public constant BUCKET_MANAGER_ROLE = keccak256('BUCKET_MANAGER_ROLE');

  /**
   * @dev Constructor
   * @param admin This is the initial holder of the default admin role
   */
  constructor(address admin) ERC20Permit('Gho Token', 'GHO', 18) {
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IGhoToken
  function mint(address account, uint256 amount) external {
    require(amount > 0, 'INVALID_MINT_AMOUNT');
    // Facilitator storage f = _facilitators[msg.sender];

    // uint256 currentBucketLevel = f.bucketLevel;
    // uint256 newBucketLevel = currentBucketLevel + amount;
    // require(f.bucketCapacity >= newBucketLevel, 'FACILITATOR_BUCKET_CAPACITY_EXCEEDED');
    // f.bucketLevel = uint128(newBucketLevel);

    _mint(account, amount);

    // emit FacilitatorBucketLevelUpdated(msg.sender, currentBucketLevel, newBucketLevel);
  }

  /// @inheritdoc IGhoToken
  function burn(uint256 amount) external {
    require(amount > 0, 'INVALID_BURN_AMOUNT');

    Facilitator storage f = _facilitators[msg.sender];
    uint256 currentBucketLevel = f.bucketLevel;
    uint256 newBucketLevel = currentBucketLevel - amount;
    f.bucketLevel = uint128(newBucketLevel);

    _burn(msg.sender, amount);

    emit FacilitatorBucketLevelUpdated(msg.sender, currentBucketLevel, newBucketLevel);
  }

  /// @inheritdoc IGhoToken
  function addFacilitator(
    address facilitatorAddress,
    string calldata facilitatorLabel,
    uint128 bucketCapacity
  ) external onlyRole(FACILITATOR_MANAGER_ROLE) {
    Facilitator storage facilitator = _facilitators[facilitatorAddress];
    require(bytes(facilitator.label).length == 0, 'FACILITATOR_ALREADY_EXISTS');
    require(bytes(facilitatorLabel).length > 0, 'INVALID_LABEL');

    facilitator.label = facilitatorLabel;
    facilitator.bucketCapacity = bucketCapacity;

    _facilitatorsList.add(facilitatorAddress);

    emit FacilitatorAdded(
      facilitatorAddress,
      keccak256(abi.encodePacked(facilitatorLabel)),
      bucketCapacity
    );
  }

  /// @inheritdoc IGhoToken
  function removeFacilitator(
    address facilitatorAddress
  ) external onlyRole(FACILITATOR_MANAGER_ROLE) {
    require(
      bytes(_facilitators[facilitatorAddress].label).length > 0,
      'FACILITATOR_DOES_NOT_EXIST'
    );
    require(
      _facilitators[facilitatorAddress].bucketLevel == 0,
      'FACILITATOR_BUCKET_LEVEL_NOT_ZERO'
    );

    delete _facilitators[facilitatorAddress];
    _facilitatorsList.remove(facilitatorAddress);

    emit FacilitatorRemoved(facilitatorAddress);
  }

  /// @inheritdoc IGhoToken
  function setFacilitatorBucketCapacity(
    address facilitator,
    uint128 newCapacity
  ) external onlyRole(BUCKET_MANAGER_ROLE) {
    require(bytes(_facilitators[facilitator].label).length > 0, 'FACILITATOR_DOES_NOT_EXIST');

    uint256 oldCapacity = _facilitators[facilitator].bucketCapacity;
    _facilitators[facilitator].bucketCapacity = newCapacity;

    emit FacilitatorBucketCapacityUpdated(facilitator, oldCapacity, newCapacity);
  }

  /// @inheritdoc IGhoToken
  function getFacilitator(address facilitator) external view returns (Facilitator memory) {
    return _facilitators[facilitator];
  }

  /// @inheritdoc IGhoToken
  function getFacilitatorBucket(address facilitator) external view returns (uint256, uint256) {
    return (_facilitators[facilitator].bucketCapacity, _facilitators[facilitator].bucketLevel);
  }

  /// @inheritdoc IGhoToken
  function getFacilitatorsList() external view returns (address[] memory) {
    return _facilitatorsList.values();
  }
}