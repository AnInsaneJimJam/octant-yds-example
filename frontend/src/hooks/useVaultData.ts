import { useReadContract, useAccount } from 'wagmi'
import { formatUnits } from 'viem'
import { CONTRACTS } from '../lib/wagmi'
import { YDS_VAULT_ABI, ERC20_ABI } from '../lib/abis'

export function useVaultData() {
  const { address } = useAccount()

  // Read vault total assets
  const { data: totalAssets } = useReadContract({
    address: CONTRACTS.YDS_VAULT,
    abi: YDS_VAULT_ABI,
    functionName: 'totalAssets',
  })

  // Read vault total supply
  const { data: totalSupply } = useReadContract({
    address: CONTRACTS.YDS_VAULT,
    abi: YDS_VAULT_ABI,
    functionName: 'totalSupply',
  })

  // Read last recorded assets (watermark)
  const { data: lastRecordedAssets } = useReadContract({
    address: CONTRACTS.YDS_VAULT,
    abi: YDS_VAULT_ABI,
    functionName: 'lastRecordedAssets',
  })

  // Read user USDC balance
  const { data: userUsdcBalance } = useReadContract({
    address: CONTRACTS.USDC,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
  })

  // Read user vault shares
  const { data: userShares } = useReadContract({
    address: CONTRACTS.YDS_VAULT,
    abi: YDS_VAULT_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
  })

  // Read USDC allowance
  const { data: usdcAllowance } = useReadContract({
    address: CONTRACTS.USDC,
    abi: ERC20_ABI,
    functionName: 'allowance',
    args: address ? [address, CONTRACTS.YDS_VAULT] : undefined,
  })

  // Calculate metrics
  const totalAssetsFormatted = totalAssets ? parseFloat(formatUnits(totalAssets, 6)) : 0
  const lastRecordedFormatted = lastRecordedAssets ? parseFloat(formatUnits(lastRecordedAssets, 6)) : 0
  const availableYield = Math.max(0, totalAssetsFormatted - lastRecordedFormatted)
  
  const userUsdcFormatted = userUsdcBalance ? parseFloat(formatUnits(userUsdcBalance, 6)) : 0
  const userSharesFormatted = userShares ? parseFloat(formatUnits(userShares, 18)) : 0
  const allowanceFormatted = usdcAllowance ? parseFloat(formatUnits(usdcAllowance, 6)) : 0

  // Calculate share price (assets per share)
  const sharePrice = totalSupply && totalAssets && totalSupply > 0n
    ? parseFloat(formatUnits(totalAssets, 6)) / parseFloat(formatUnits(totalSupply, 18))
    : 1.0

  return {
    totalAssets: totalAssetsFormatted,
    availableYield,
    sharePrice,
    userUsdcBalance: userUsdcFormatted,
    userShares: userSharesFormatted,
    userAssetValue: userSharesFormatted * sharePrice,
    allowance: allowanceFormatted,
    isConnected: !!address,
  }
}
