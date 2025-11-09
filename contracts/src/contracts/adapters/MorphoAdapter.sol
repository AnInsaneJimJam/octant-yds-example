// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {console2} from "forge-std/console2.sol";

/// @dev Morpho vault interface for yield generation
interface IMorphoVault {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    function balanceOf(address account) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function asset() external view returns (address);
    function maxDeposit(address receiver) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256);
}

/// @title MorphoAdapter
/// @notice Adapter for integrating with Morpho lending protocol for real yield generation
/// @dev This adapter deposits assets into a Morpho vault to earn real yield from lending markets
contract MorphoAdapter {
    using SafeERC20 for IERC20;

    address public immutable OWNER;
    address public immutable UNDERLYING;
    IMorphoVault public immutable MORPHO_VAULT;

    error NotOwner();
    error AssetMismatch();
    error InsufficientBalance();

    modifier onlyOwner() {
        if (msg.sender != OWNER) revert NotOwner();
        _;
    }

    /// @param _underlying ERC-20 asset to be deposited into Morpho
    /// @param _morphoVault Morpho vault address for yield generation
    /// @param _owner vault that controls this adapter
    constructor(address _underlying, address _morphoVault, address _owner) {
        OWNER = _owner;
        UNDERLYING = _underlying;
        MORPHO_VAULT = IMorphoVault(_morphoVault);

        // Validate that the Morpho vault uses the same underlying asset
        if (MORPHO_VAULT.asset() != _underlying) revert AssetMismatch();

        // Pre-approve the Morpho vault to pull unlimited underlying from this adapter
        IERC20(_underlying).approve(_morphoVault, type(uint256).max);
    }

    /// @notice Called by the vault to deposit assets into Morpho for yield generation
    /// @param amount Amount of underlying assets to deposit
    function deposit(uint256 amount) external onlyOwner {
        console2.log("=== MORPHO ADAPTER: INVESTING FOR REAL YIELD ===");
        console2.log("Transferring assets to Morpho for yield generation:", amount);
        
        // Pull underlying from the vault
        IERC20(UNDERLYING).safeTransferFrom(msg.sender, address(this), amount);
        console2.log("Assets received by adapter from vault");
        
        // Check available deposit capacity
        uint256 maxDepositAmount = MORPHO_VAULT.maxDeposit(address(this));
        if (amount > maxDepositAmount) {
            console2.log("Warning: Requested amount exceeds max deposit, depositing max available:", maxDepositAmount);
            amount = maxDepositAmount;
        }
        
        // Deposit into Morpho vault
        uint256 sharesMinted = MORPHO_VAULT.deposit(amount, address(this));
        
        console2.log("Assets supplied to Morpho vault - Now earning real yield!");
        console2.log("Shares minted:", sharesMinted);
        console2.log("Total shares balance:", MORPHO_VAULT.balanceOf(address(this)));
        console2.log("Total assets value:", MORPHO_VAULT.convertToAssets(MORPHO_VAULT.balanceOf(address(this))));
        console2.log("=== REAL YIELD GENERATION STARTED ===\n");
    }

    /// @notice Withdraws assets from Morpho back to the vault
    /// @param amount Amount of underlying assets to withdraw
    /// @return withdrawn Amount actually withdrawn from Morpho
    function withdraw(uint256 amount) external onlyOwner returns (uint256) {
        console2.log("=== MORPHO ADAPTER: WITHDRAWING ASSETS ===");
        console2.log("Requested withdrawal amount:", amount);
        
        uint256 currentShares = MORPHO_VAULT.balanceOf(address(this));
        uint256 totalAssetValue = MORPHO_VAULT.convertToAssets(currentShares);
        
        console2.log("Current share balance:", currentShares);
        console2.log("Total asset value before withdrawal:", totalAssetValue);
        
        // Ensure we don't try to withdraw more than we have
        if (amount > totalAssetValue) {
            console2.log("Warning: Requested amount exceeds available, withdrawing all:", totalAssetValue);
            amount = totalAssetValue;
        }
        
        // Check max withdrawable amount
        uint256 maxWithdrawAmount = MORPHO_VAULT.maxWithdraw(address(this));
        if (amount > maxWithdrawAmount) {
            console2.log("Warning: Requested amount exceeds max withdraw, withdrawing max available:", maxWithdrawAmount);
            amount = maxWithdrawAmount;
        }
        
        uint256 balanceBefore = IERC20(UNDERLYING).balanceOf(OWNER);
        
        // Withdraw from Morpho vault directly to the owner (vault)
        uint256 sharesRedeemed = MORPHO_VAULT.withdraw(amount, OWNER, address(this));
        
        uint256 balanceAfter = IERC20(UNDERLYING).balanceOf(OWNER);
        uint256 actualWithdrawn = balanceAfter - balanceBefore;
        
        console2.log("Shares redeemed:", sharesRedeemed);
        console2.log("Assets withdrawn from Morpho:", actualWithdrawn);
        console2.log("Remaining share balance:", MORPHO_VAULT.balanceOf(address(this)));
        console2.log("=== WITHDRAWAL FROM MORPHO COMPLETE ===\n");
        
        return actualWithdrawn;
    }

    /// @notice Total underlying assets attributed to this adapter via Morpho shares
    /// @return Total assets under management in the Morpho vault
    function totalAssets() external view returns (uint256) {
        uint256 shares = MORPHO_VAULT.balanceOf(address(this));
        return MORPHO_VAULT.convertToAssets(shares);
    }

    /// @notice Exposes the underlying asset address to the vault
    /// @return Address of the underlying asset
    function asset() external view returns (address) {
        return UNDERLYING;
    }

    /// @notice Get current share balance in Morpho vault
    /// @return Number of shares held in the Morpho vault
    function shareBalance() external view returns (uint256) {
        return MORPHO_VAULT.balanceOf(address(this));
    }

    /// @notice Get maximum deposit amount allowed by Morpho vault
    /// @return Maximum amount that can be deposited
    function maxDeposit() external view returns (uint256) {
        return MORPHO_VAULT.maxDeposit(address(this));
    }

    /// @notice Get maximum withdrawal amount allowed by Morpho vault
    /// @return Maximum amount that can be withdrawn
    function maxWithdraw() external view returns (uint256) {
        return MORPHO_VAULT.maxWithdraw(address(this));
    }
}
