nano contracts/AgentERC20.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

/// @title Agent-Optimized ERC20 (AIS-20)
/// @author The Architect Cartridge
/// @notice A deterministic, gas-efficient token standard for AI Agents.
contract AgentERC20 is ERC20, Ownable {

    /// @dev Thrown when a simulation detects a failure.
    error SimulationFailed(uint256 code);
    
    string internal _name;
    string internal _symbol;

    constructor(string memory name_, string memory symbol_, uint256 initialSupply) {
        _initializeOwner(msg.sender);
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, initialSupply);
    }

    function name() public view override returns (string memory) { return _name; }
    function symbol() public view override returns (string memory) { return _symbol; }

    /// @notice Broadcasts capabilities to AI Agents (ERC-165 style).
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x2a5e2020; 
    }

    /// @notice Deterministic simulation for token transfers.
    function previewTransfer(address from, address to, uint256 amount) 
        external 
        view 
        returns (bool success, uint256 gasEstimate) 
    {
        if (balanceOf(from) < amount) return (false, 0);
        if (from != msg.sender && allowance(from, msg.sender) < amount) return (false, 0);

        assembly {
            success := 1
            gasEstimate := 2600 
        }
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
