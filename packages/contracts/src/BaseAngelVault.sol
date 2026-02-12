// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.32;

contract BasedAngelVault {
    event DisbursementExecuted(address indexed recipient, address indexed token, uint256 amount, uint256 timestamp);
    event DisbursementRejected(address indexed recipient, string reason, uint256 timestamp);
    event DonationReceived(address indexed donor, address indexed token, uint256 amount, uint256 timestamp);
    event tokenAdded(address indexed token, uint256 timestamp);
    event tokenRemoved(address indexed token, uint256 timestamp);
    event OperatorUpdated(address indexed oldOperator, address indexed newOperator);
    event CapUpdated(string capType, uint256 oldValue, uint256 newValue);
    event EmergencyPaused(uint256 timestamp);
    event EmergencyUnpaused(uint256 timestamp);

    address public s_owner; // multisig wallet address
    address public s_operator; // Agentic wallet address
    uint256 public s_dailySpent;
    uint256 public lastResetTimestamp;

    uint256 internal constant MAX_PER_REQUEST = 0.002 ether;
    uint256 internal constant USER_COOLDOWN = 30 days;
    uint256 internal constant DAILY_GLOBAL_CAP = 0.1 ether;

    mapping(address => uint256) public s_lastRequestTime;
    mapping(address => uint256) public s_totalReceived;
    mapping(address => bool) public s_hasReceivedFunds;

    mapping(address => bool) public s_supportedTokens

    modifier onlyOperator() {
        require(msg.sender == s_operator);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }


}
