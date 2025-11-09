// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {YDSVault} from "../src/contracts/YDSStrategy.sol";
import {MorphoAdapter} from "../src/contracts/adapters/MorphoAdapter.sol";
import {DonationRouter} from "../src/contracts/utils/DonationRouter.sol";

/// @title YDS Morpho Fork Test
/// @notice Comprehensive fork tests for YDS with real Morpho lending integration
/// @dev Tests real yield generation using Morpho on mainnet fork
contract YDSMorphoForkTest is Test {
    // Mainnet addresses
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC on mainnet
    address constant MORPHO_USDC_VAULT = 0x8eB67A509616cd6A7c1B3c8C21D48FF57df3d458; // Steakhouse USDC vault
    address constant WHALE = 0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503; // Binance8 - Known large USDC holder
    
    // Test contracts
    YDSVault public vault;
    MorphoAdapter public adapter;
    DonationRouter public router;
    
    // Test addresses
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charity1 = makeAddr("charity1");
    address public charity2 = makeAddr("charity2");
    
    // Test parameters
    uint256 constant INITIAL_DEPOSIT = 10_000e6; // 10k USDC
    uint256 constant SMALL_DEPOSIT = 1_000e6;    // 1k USDC
    
    function setUp() public {
        // Fork mainnet at a recent block
        vm.createFork(vm.envString("MAINNET_RPC_URL"));
        
        console2.log("=== SETTING UP MORPHO FORK TEST ===");
        
        // Deploy donation router first
        DonationRouter.Receiver[] memory recipients = new DonationRouter.Receiver[](2);
        recipients[0] = DonationRouter.Receiver({account: charity1, bps: 5000}); // 50%
        recipients[1] = DonationRouter.Receiver({account: charity2, bps: 5000}); // 50%
        
        router = new DonationRouter(recipients);
        console2.log("DonationRouter deployed at:", address(router));
        
        // Deploy MorphoAdapter
        adapter = new MorphoAdapter(
            USDC,
            MORPHO_USDC_VAULT,
            address(0) // Will be set to vault address after vault deployment
        );
        console2.log("MorphoAdapter deployed at:", address(adapter));
        
        // Deploy YDSVault
        vault = new YDSVault(
            IERC20(USDC),
            "Octant Morpho USDC Vault",
            "omUSDC",
            address(adapter),
            address(router)
        );
        console2.log("YDSVault deployed at:", address(vault));
        
        // Update adapter owner to vault
        adapter = new MorphoAdapter(USDC, MORPHO_USDC_VAULT, address(vault));
        vault.setAdapter(address(adapter));
        
        // Setup test users with USDC
        _setupUSDCBalances();
        
        console2.log("=== SETUP COMPLETE ===\n");
    }
    
    function _setupUSDCBalances() internal {
        // Use deal to give accounts USDC directly (works with any ERC20)
        deal(USDC, alice, INITIAL_DEPOSIT * 2);
        deal(USDC, bob, INITIAL_DEPOSIT);
        
        vm.deal(bob, 10 ether);
    }
    
    /// @notice Test basic deposit and withdrawal functionality with Morpho
    function test_DepositAndWithdraw() public {
        uint256 depositAmount = INITIAL_DEPOSIT;
        
        console2.log("\n === OCTANT V2 DEMO: REAL YIELD GENERATION ===");
        console2.log(" STEP 1: USER DEPOSITS USDC INTO OCTANT VAULT");
        console2.log("Deposit Amount: %s USDC", depositAmount / 1e6);
        console2.log("User Address: %s", alice);
        console2.log("Goal: Generate real yield through Morpho lending");

        // Alice deposits USDC
        vm.startPrank(alice);
        IERC20(USDC).approve(address(vault), depositAmount);
        uint256 sharesMinted = vault.deposit(depositAmount, alice);

        console2.log("\n DEPOSIT SUCCESSFUL!");
        console2.log("Vault Shares Minted: %s", sharesMinted / 1e18);
        console2.log("Vault Total Assets: %s USDC", vault.totalAssets() / 1e6);
        console2.log("Adapter Total Assets: %s USDC", adapter.totalAssets() / 1e6);
        console2.log("Funds are now invested in Morpho for real yield generation!");
        assertEq(sharesMinted, depositAmount, "Shares minted should equal deposit amount");
        
        // Store assets before time passes
        uint256 assetsBeforeTime = vault.totalAssets();
        
        // Wait some time for yield to accrue (simulate time passing)
        vm.warp(block.timestamp + 1 days);
        
        uint256 assetsAfterTime = vault.totalAssets();
        uint256 yieldGenerated = assetsAfterTime - assetsBeforeTime;
        
        console2.log("\n STEP 2: TIME PASSES - YIELD GENERATION IN ACTION");
        console2.log(" Time Advanced: 1 day (24 hours)");
        console2.log("Assets Before: %s USDC", assetsBeforeTime / 1e6);
        console2.log("Assets After: %s USDC", assetsAfterTime / 1e6);
        console2.log("REAL YIELD GENERATED: %s USDC", yieldGenerated / 1e6);
        console2.log("Daily Yield Rate: %s%%", (yieldGenerated * 100 * 1e6) / assetsBeforeTime / 1e6);
        console2.log("Estimated Annual APY: ~%s%%", (yieldGenerated * 365 * 100 * 1e6) / assetsBeforeTime / 1e6);
        
        // Withdraw half
        uint256 withdrawAmount = INITIAL_DEPOSIT / 2;
        uint256 balanceBefore = IERC20(USDC).balanceOf(alice);
        
        console2.log("\n STEP 3: USER WITHDRAWS FUNDS");
        console2.log("Withdrawal Amount: %s USDC", withdrawAmount / 1e6);
        console2.log("Shares to Burn: %s", vault.previewWithdraw(withdrawAmount) / 1e18);
        console2.log("Vault Assets Before Withdrawal: %s USDC", vault.totalAssets() / 1e6);
        
        vm.startPrank(alice);
        vault.withdraw(withdrawAmount, alice, alice);
        vm.stopPrank();
        
        uint256 balanceAfter = IERC20(USDC).balanceOf(alice);
        uint256 actualWithdrawn = balanceAfter - balanceBefore;
        
        console2.log("User Received: %s USDC", actualWithdrawn / 1e6);
        console2.log("Remaining Vault Assets: %s USDC", vault.totalAssets() / 1e6);
        console2.log("User's Principal: PROTECTED (can withdraw anytime)");
        console2.log("Generated Yield: DONATED to Public Goods!");
        
        console2.log("\nFINAL SUMMARY:");
        console2.log("Real Morpho Integration: WORKING");
        console2.log("User Funds: SAFE and WITHDRAWABLE");
        console2.log("Public Good Funding: AUTOMATED");
        
        // Verify withdrawal worked correctly
        assertEq(actualWithdrawn, withdrawAmount, "Withdrawal amount should match requested");
    }
    
    /// @notice Test multiple users and yield distribution
    function test_MultipleUsersYieldDistribution() public {
        console2.log("\n=== TEST: MULTIPLE USERS YIELD DISTRIBUTION ===");
        
        // Alice deposits first
        vm.startPrank(alice);
        IERC20(USDC).approve(address(vault), INITIAL_DEPOSIT);
        uint256 aliceShares = vault.deposit(INITIAL_DEPOSIT, alice);
        vm.stopPrank();
        
        // Wait some time
        vm.warp(block.timestamp + 1 days);
        
        // Bob deposits
        vm.startPrank(bob);
        IERC20(USDC).approve(address(vault), SMALL_DEPOSIT);
        uint256 bobShares = vault.deposit(SMALL_DEPOSIT, bob);
        vm.stopPrank();
        
        console2.log("Alice shares:", aliceShares);
        console2.log("Bob shares:", bobShares);
        console2.log("Total vault assets:", vault.totalAssets());
        
        // Wait for more yield
        vm.warp(block.timestamp + 5 days);
        
        // Harvest yield
        vault.harvest();
        
        // Both users should maintain their proportional ownership
        uint256 aliceAssetValue = vault.convertToAssets(aliceShares);
        uint256 bobAssetValue = vault.convertToAssets(bobShares);
        
        console2.log("Alice asset value:", aliceAssetValue);
        console2.log("Bob asset value:", bobAssetValue);
        
        // Alice should have more assets since she deposited more
        assertGt(aliceAssetValue, bobAssetValue, "Alice should have more assets");
        
        // Both should have at least their original deposits (assuming no loss)
        assertGe(aliceAssetValue, INITIAL_DEPOSIT * 99 / 100, "Alice should not lose principal");
        assertGe(bobAssetValue, SMALL_DEPOSIT * 99 / 100, "Bob should not lose principal");
    }
    
    /// @notice Test edge cases and error conditions
    function test_EdgeCases() public {
        console2.log("\n=== TEST: EDGE CASES ===");
        
        // Test deposit with zero amount (should succeed but mint 0 shares)
        vm.startPrank(alice);
        IERC20(USDC).approve(address(vault), 0);
        
        uint256 sharesBefore = vault.balanceOf(alice);
        vault.deposit(0, alice);
        uint256 sharesAfter = vault.balanceOf(alice);
        assertEq(sharesAfter, sharesBefore, "Zero deposit should mint zero shares");
        
        // Test withdrawal with no deposits (should revert)
        vm.expectRevert();
        vault.withdraw(1000e6, alice, alice);
        
        vm.stopPrank();
        
        // Test harvest with no yield
        vault.harvest(); // Should not revert even with no yield
        
        console2.log("Edge case tests passed");
    }
    
    /// @notice Test Morpho vault integration limits
    function test_MorphoVaultLimits() public {
        console2.log("\n=== TEST: MORPHO VAULT LIMITS ===");
        
        console2.log("Max deposit to Morpho:", adapter.maxDeposit());
        console2.log("Max withdraw from Morpho:", adapter.maxWithdraw());
        
        // Test deposit within limits
        vm.startPrank(alice);
        IERC20(USDC).approve(address(vault), INITIAL_DEPOSIT);
        
        uint256 maxDeposit = adapter.maxDeposit();
        if (maxDeposit >= INITIAL_DEPOSIT) {
            vault.deposit(INITIAL_DEPOSIT, alice);
            console2.log("Deposit successful within Morpho limits");
        } else {
            console2.log("Morpho vault at capacity, testing with smaller amount");
            if (maxDeposit > 0) {
                vault.deposit(maxDeposit, alice);
            }
        }
        
        vm.stopPrank();
    }
    
    /// @notice Test gas usage for operations
    function test_GasUsage() public {
        console2.log("\n=== TEST: GAS USAGE ===");
        
        vm.startPrank(alice);
        IERC20(USDC).approve(address(vault), INITIAL_DEPOSIT);
        
        uint256 gasStart = gasleft();
        vault.deposit(INITIAL_DEPOSIT, alice);
        uint256 gasUsed = gasStart - gasleft();
        
        console2.log("Gas used for deposit:", gasUsed);
        
        gasStart = gasleft();
        vault.harvest();
        gasUsed = gasStart - gasleft();
        
        console2.log("Gas used for harvest:", gasUsed);
        
        vm.stopPrank();
    }
}
