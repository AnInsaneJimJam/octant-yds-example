#!/bin/bash

# Octant V2 - Morpho Integration Test Script
# This script runs comprehensive tests for the Morpho integration

echo "🌿 Octant V2 - Morpho Integration Tests"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "contracts/foundry.toml" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Check if .env file exists
if [ ! -f "contracts/.env" ]; then
    echo "❌ Please create contracts/.env file with MAINNET_RPC_URL"
    echo "   Copy from contracts/.env.example and add your RPC URL"
    exit 1
fi

cd contracts

# Load environment variables
source .env

# Check if MAINNET_RPC_URL is set
if [ -z "$MAINNET_RPC_URL" ]; then
    echo "❌ MAINNET_RPC_URL not set in .env file"
    exit 1
fi

echo "✅ Environment configured"
echo "🔗 RPC URL: ${MAINNET_RPC_URL:0:30}..."

echo ""
echo "🧪 Running Morpho Integration Tests..."
echo "====================================="

# Run the comprehensive Morpho fork tests
echo "1️⃣ Testing basic deposit and withdrawal..."
forge test --match-test test_DepositAndWithdraw --fork-url $MAINNET_RPC_URL -v

echo ""
echo "2️⃣ Testing yield generation and donation..."
forge test --match-test test_YieldGenerationAndDonation --fork-url $MAINNET_RPC_URL -v

echo ""
echo "3️⃣ Testing multiple users scenario..."
forge test --match-test test_MultipleUsersYieldDistribution --fork-url $MAINNET_RPC_URL -v

echo ""
echo "4️⃣ Testing edge cases..."
forge test --match-test test_EdgeCases --fork-url $MAINNET_RPC_URL -v

echo ""
echo "5️⃣ Testing Morpho vault limits..."
forge test --match-test test_MorphoVaultLimits --fork-url $MAINNET_RPC_URL -v

echo ""
echo "6️⃣ Testing gas usage..."
forge test --match-test test_GasUsage --fork-url $MAINNET_RPC_URL -v

echo ""
echo "🎉 All tests completed!"
echo ""
echo "📊 To run all tests with detailed output:"
echo "   forge test --match-contract YDSMorphoForkTest --fork-url \$MAINNET_RPC_URL -vvv"
echo ""
echo "🚀 To deploy on mainnet fork:"
echo "   forge script script/DeployMorphoFork.s.sol:DeployMorphoFork --fork-url \$MAINNET_RPC_URL --private-key \$PRIVATE_KEY --broadcast"
