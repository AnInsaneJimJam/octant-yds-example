// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {YDSVault} from "../src/contracts/YDSStrategy.sol";
import {MorphoAdapter} from "../src/contracts/adapters/MorphoAdapter.sol";
import {DonationRouter} from "../src/contracts/utils/DonationRouter.sol";

/// @title Deploy Morpho Fork Script
/// @notice Deployment script for YDS with real Morpho integration on mainnet fork
contract DeployMorphoFork is Script {
    // Mainnet addresses
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant MORPHO_USDC_VAULT = 0x8eB67A509616cd6A7c1B3c8C21D48FF57df3d458; // Steakhouse USDC vault
    
    // Deployment addresses (will be populated from environment or defaults)
    address public deployer;
    address public charity1;
    address public charity2;
    
    function setUp() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.addr(privateKey);
        charity1 = vm.envOr("CHARITY_1", makeAddr("charity1"));
        charity2 = vm.envOr("CHARITY_2", makeAddr("charity2"));
    }
    
    function run() public {
        vm.startBroadcast();
        
        console2.log("=== DEPLOYING YDS WITH MORPHO INTEGRATION ===");
        console2.log("Deployer:", deployer);
        console2.log("USDC:", USDC);
        console2.log("Morpho Vault:", MORPHO_USDC_VAULT);
        console2.log("Charity 1:", charity1);
        console2.log("Charity 2:", charity2);
        
        // 1. Deploy DonationRouter
        DonationRouter.Receiver[] memory recipients = new DonationRouter.Receiver[](2);
        recipients[0] = DonationRouter.Receiver({account: charity1, bps: 5000}); // 50%
        recipients[1] = DonationRouter.Receiver({account: charity2, bps: 5000}); // 50%
        
        DonationRouter router = new DonationRouter(recipients);
        console2.log("DonationRouter deployed at:", address(router));
        
        // 2. Deploy MorphoAdapter first (with temporary vault address)
        MorphoAdapter adapter = new MorphoAdapter(
            USDC,
            MORPHO_USDC_VAULT,
            deployer // Temporary owner
        );
        console2.log("MorphoAdapter deployed at:", address(adapter));
        
        // 3. Deploy YDSVault with the adapter
        YDSVault vault = new YDSVault(
            IERC20(USDC),
            "Octant Morpho USDC Vault",
            "omUSDC",
            address(adapter),
            address(router)
        );
        console2.log("YDSVault deployed at:", address(vault));
        
        // 4. Transfer adapter ownership to vault
        // Note: MorphoAdapter doesn't have transferOwnership, so we deploy a new one
        MorphoAdapter finalAdapter = new MorphoAdapter(
            USDC,
            MORPHO_USDC_VAULT,
            address(vault)
        );
        console2.log("Final MorphoAdapter deployed at:", address(finalAdapter));
        
        // 5. Update vault to use the final adapter
        vault.setAdapter(address(finalAdapter));
        console2.log("Vault adapter updated to:", address(finalAdapter));
        
        vm.stopBroadcast();
        
        console2.log("\n=== DEPLOYMENT COMPLETE ===");
        console2.log("Summary:");
        console2.log("- YDSVault:", address(vault));
        console2.log("- MorphoAdapter:", address(finalAdapter));
        console2.log("- DonationRouter:", address(router));
        console2.log("- Underlying Asset (USDC):", USDC);
        console2.log("- Morpho Vault:", MORPHO_USDC_VAULT);
        
        // Verify deployment
        _verifyDeployment(vault, finalAdapter, router);
    }
    
    function _verifyDeployment(
        YDSVault vault,
        MorphoAdapter adapter,
        DonationRouter router
    ) internal view {
        console2.log("\n=== VERIFYING DEPLOYMENT ===");
        
        // Verify vault configuration
        require(address(vault.asset()) == USDC, "Vault asset mismatch");
        require(address(vault.adapter()) == address(adapter), "Vault adapter mismatch");
        require(address(vault.router()) == address(router), "Vault router mismatch");
        
        // Verify adapter configuration
        require(adapter.asset() == USDC, "Adapter asset mismatch");
        
        // Verify Morpho integration
        require(adapter.maxDeposit() > 0, "Morpho vault not accepting deposits");
        
        console2.log("All verifications passed!");
        console2.log("Vault is ready for real yield generation via Morpho");
        console2.log("Donations will be split 50/50 between charities");
    }
}
