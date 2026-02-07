// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

/// @title AgentERC20 V2 (The "Hive Mind" Edition)
/// @notice A hyper-optimized token for Autonomous Agent Swarms.
contract AgentERC20 is ERC20, Ownable {

    error SimulationFailed();
    error ArrayLengthMismatch();

    struct StateDelta {
        uint256 fromBalanceBefore;
        uint256 fromBalanceAfter;
        uint256 toBalanceBefore;
        uint256 toBalanceAfter;
        uint256 gasEstimate;
    }

    string internal _name;
    string internal _symbol;
    
    // Shape L2 Gasback Contract (Corrected Checksum: lowercase 'f')
    address constant GASBACK_CONTRACT = 0x42000000000000000000000000000000000000f6;

    constructor(string memory name_, string memory symbol_, uint256 initialSupply) {
        _initializeOwner(msg.sender);
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, initialSupply);
    }

    function name() public view override returns (string memory) { return _name; }
    function symbol() public view override returns (string memory) { return _symbol; }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return 
            interfaceId == 0x01ffc9a7 || // ERC-165
            interfaceId == 0x2a5e2020 || // AIS-20 (Agent Standard)
            interfaceId == 0x26122612;   // EIP-2612 (Permit)
    }

    function previewTransfer(address from, address to, uint256 amount) 
        external 
        view 
        returns (bool success, StateDelta memory delta) 
    {
        delta.fromBalanceBefore = balanceOf(from);
        delta.toBalanceBefore = balanceOf(to);

        if (delta.fromBalanceBefore < amount) return (false, delta);
        if (from != msg.sender && allowance(from, msg.sender) < amount) return (false, delta);

        delta.fromBalanceAfter = delta.fromBalanceBefore - amount;
        delta.toBalanceAfter = delta.toBalanceBefore + amount;
        success = true;

        uint256 size;
        assembly { size := extcodesize(to) }
        delta.gasEstimate = size > 0 ? 4500 : 2600; 
    }

    function transferBatch(address[] calldata recipients, uint256[] calldata amounts) 
        external 
        returns (bool) 
    {
        if (recipients.length != amounts.length) revert ArrayLengthMismatch();
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
        return true;
    }

    function registerGasback() external onlyOwner {
        (bool success, ) = GASBACK_CONTRACT.call(
            abi.encodeWithSignature("register(address)", address(this))
        );
        require(success, "Gasback Registration Failed"); 
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
