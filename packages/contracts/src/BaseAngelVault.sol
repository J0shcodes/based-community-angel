// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title BasedAngelVault
/// @author Based Angel Team
/// @notice Reputation-gated micro-disbursement vault for Base builders
/// @dev Implements cooldowns, caps, and role-based access control
contract BasedAngelVault is Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Events
    event DisbursementExecuted(address indexed recipient, address indexed token, uint256 amount, uint256 timestamp);
    event DisbursementRejected(address indexed recipient, string reason, uint256 timestamp);
    event DonationReceived(address indexed donor, address indexed token, uint256 amount, uint256 timestamp);
    event TokenAdded(address indexed token, uint256 timestamp);
    event TokenRemoved(address indexed token, uint256 timestamp);
    event OperatorUpdated(address indexed oldOperator, address indexed newOperator);
    event CapUpdated(string capType, uint256 oldValue, uint256 newValue);
    event EmergencyPaused(uint256 timestamp);
    event EmergencyUnpaused(uint256 timestamp);

    // State variables
    // address public s_owner; // multisig wallet address
    address public s_operator; // Agentic wallet address
    uint256 public s_dailySpent;
    uint256 public s_lastResetTimestamp;

    // Configurable caps
    uint256 public s_maxPerRequest;
    uint256 public s_userCooldown;
    uint256 public s_dailyGlobalCap;

    mapping(address => uint256) public s_lastRequestTime;
    mapping(address => uint256) public s_totalReceived;
    mapping(address => uint256) public s_totalDonated;
    mapping(address => bool) public s_hasReceivedFunds;
    mapping(address => bool) public s_supportedTokens;

    error UnauthorizedOperator();
    error InvalidToken();
    error ExceedsPerRequestCap();
    error ExceedsDailyGlobalCap();
    error CooldownNotExpired();
    error ZeroAddress();
    error TransferFailed();
    error InvalidAmount();
    error InsufficientVaultBalance();

    modifier onlyOperator() {
        if (msg.sender != s_operator) revert UnauthorizedOperator();
        _;
    }

    constructor(address owner, address operator, uint256 maxPerRequest, uint256 dailyGlobalCap, uint256 userCooldown) Ownable(owner) {
        if (operator == address(0)) revert ZeroAddress();

        s_operator = operator;
        s_maxPerRequest = maxPerRequest;
        s_userCooldown = userCooldown;
        s_dailyGlobalCap = dailyGlobalCap;
        s_lastResetTimestamp = block.timestamp;
        s_supportedTokens[address(0)] = true;
    }

/// @dev Internal helper to get vault balance for any token
    function _getVaultBalance(address token) internal view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    /// @notice Disburses tokens to eligible recipients
    /// @dev Enforces cooldown, caps, and supported token checks
    /// @param recipient Address to receive funds
    /// @param token Token address (address(0) for ETH)
    /// @param amount Amount to disburse
    /// @return success True if disbursement succeeded
    function disburse(address recipient, address token, uint256 amount) external onlyOperator whenNotPaused nonReentrant returns (bool) {
        
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert InvalidAmount();

        if (block.timestamp >= s_lastResetTimestamp + 1 days) {
            s_dailySpent = 0;
            s_lastResetTimestamp = block.timestamp;
        }

        uint256 currentDailySpent = s_dailySpent;

        if (!s_supportedTokens[token]) {
            emit DisbursementRejected(recipient, "Invalid token", block.timestamp);
            revert InvalidToken();
        }

        if (amount > s_maxPerRequest) {
            emit DisbursementRejected(recipient, "Exceeds per-request cap", block.timestamp);
            revert ExceedsPerRequestCap();
        }

        if (currentDailySpent + amount > s_dailyGlobalCap) {
            emit DisbursementRejected(recipient, "Exceeds daily global cap", block.timestamp);
            revert ExceedsDailyGlobalCap();
        }

        if (block.timestamp < s_lastRequestTime[recipient] + s_userCooldown) {
            emit DisbursementRejected(recipient, "Cooldown not expired", block.timestamp);
            revert CooldownNotExpired();
        }

        if (_getVaultBalance(token) < amount) {
            emit DisbursementRejected(recipient, "Insufficient vault balance", block.timestamp);
            revert InsufficientVaultBalance();
        }

        s_dailySpent = currentDailySpent + amount;
        s_lastRequestTime[recipient] = block.timestamp;
        s_totalReceived[recipient] += amount;
        s_hasReceivedFunds[recipient] = true;

        if (token == address(0)) {
            (bool success, ) = recipient.call{value: amount}("");
            if (!success) revert TransferFailed();
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit DisbursementExecuted(recipient, token, amount, block.timestamp);
        return true;
    }

    // Adminitrative functions

    /// @notice Adds a token to the supported tokens whitelist
    /// @param token Token address to add (address(0) for ETH)
    function addSupportedToken(address token) external onlyOwner  {
        s_supportedTokens[token] = true;
        emit TokenAdded(token, block.timestamp);
    }

    /// @notice Removes a token from the supported tokens whitelist
    /// @param token Token address to remove
    function removeSupportedToken(address token) external onlyOwner {
        s_supportedTokens[token] = false;
        emit TokenRemoved(token, block.timestamp);
    }

    function updateDailyCap(uint256 newCap) external onlyOwner {
        if (newCap == 0) revert InvalidAmount();
        uint256 oldCap = s_dailyGlobalCap;
        s_dailyGlobalCap = newCap;
        emit CapUpdated("Daily Global Cap", oldCap, newCap);
    }

    function updatePerRequestCap (uint256 newCap) external onlyOwner {
        if (newCap == 0) revert InvalidAmount(); 
        if (newCap > s_dailyGlobalCap) revert ExceedsPerRequestCap();
        uint256 oldCap = s_maxPerRequest;
        s_maxPerRequest = newCap;
        emit CapUpdated("Per Request Cap", oldCap, newCap);
    }

    function updateOperator(address newOperator) external onlyOwner {
        if (newOperator == address(0)) revert ZeroAddress();
        address oldOperator = s_operator;
        s_operator = newOperator;
        emit OperatorUpdated(oldOperator, newOperator);
    }

    function pause() external onlyOwner {
        _pause();
        emit EmergencyPaused(block.timestamp);
    }

    function unpause() external onlyOwner {
        _unpause();
        emit EmergencyUnpaused(block.timestamp);
    }

    // Funding functions
    receive() external payable {
        s_totalDonated[msg.sender] += msg.value;
        emit DonationReceived(msg.sender, address(0), msg.value, block.timestamp);
    }

    function donate(address token, uint256 amount) external {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();
        if (!s_supportedTokens[token]) revert InvalidToken();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        s_totalDonated[msg.sender] += amount;
        emit DonationReceived(msg.sender, token, amount, block.timestamp);
    }

    /// @notice Get current vault balance for a token
    /// @param token Token address (address(0) for ETH)
    /// @return balance Current balance
    function getVaultBalance(address token) external view returns (uint256) {
        return _getVaultBalance(token);
    }

    function getUserCooldownRemaining(address user) external view returns (uint256) {
        uint256 lastRequest = s_lastRequestTime[user];
        uint256 cooldownEnd = lastRequest + s_userCooldown;
    
        return block.timestamp >= cooldownEnd ? 0 : cooldownEnd - block.timestamp;
    }

    function getDailySpendingRemaining() external view returns (uint256) {
        uint256 dailyCap = s_dailyGlobalCap;
        uint256 spent = s_dailySpent;
        return dailyCap > spent ? dailyCap - spent : 0;
    }

    function isEligibleForRequest(address user) external view returns (bool) {
        return block.timestamp >= s_lastRequestTime[user] + s_userCooldown;
    }

    function getUserStats(address user) external view returns (uint256 totalReceived, uint256 lastRequestTime) {
        return (s_totalReceived[user], s_lastRequestTime[user]);
    }

    function getDonorStats(address donor) external view returns (uint256) {
        return s_totalDonated[donor];
    }

    function getIsSupportedToken(address token) external view returns (bool) {
        return s_supportedTokens[token];
    }

    function getUserFullStats(address user) external view returns (uint256 totalReceived, uint256 totalDonated, uint256 lastRequestTime, uint256 cooldownRemaining, bool hasReceived, bool isEligible) {
        uint256 cooldown = block.timestamp >= s_lastRequestTime[user] + s_userCooldown ? 0 : (s_lastRequestTime[user] + s_userCooldown) - block.timestamp;
        return (
            s_totalReceived[user], 
            s_totalDonated[user],
            s_lastRequestTime[user],
            cooldown,
            s_hasReceivedFunds[user],
            this.isEligibleForRequest(user);
        )
    }

}