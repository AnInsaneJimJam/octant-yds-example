import { http, createConfig } from 'wagmi'
import { mainnet } from 'wagmi/chains'
import { injected, metaMask } from 'wagmi/connectors'

// Mainnet fork chain configuration for local testing
const mainnetFork = {
  ...mainnet,
  id: 1, // Keep mainnet chain ID for compatibility
  name: 'Mainnet Fork (Morpho)',
  nativeCurrency: {
    name: 'Ethereum',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['http://127.0.0.1:8545'], // Local fork URL
    },
    public: {
      http: ['http://127.0.0.1:8545'],
    },
  },
  blockExplorers: {
    default: {
      name: 'Etherscan',
      url: 'https://etherscan.io',
    },
  },
}

// Configuration for mainnet fork with Morpho integration
export const config = createConfig({
  chains: [mainnetFork],
  connectors: [
    injected(),
    metaMask(),
  ],
  transports: {
    [mainnetFork.id]: http('http://127.0.0.1:8545'),
  },
})

// Contract addresses for mainnet fork (real Morpho integration)
export const CONTRACTS = {
  USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48' as `0x${string}`,
  YDS_VAULT: '0x5AA3eeFaD57a9Ba261030Eed45C686eac8F41EA9' as `0x${string}`,
  DONATION_ROUTER: '0x4c4a14C94980E7212eA5B746fE397E55Cb7E4A07' as `0x${string}`,
  MORPHO_ADAPTER: '0xbC3fed4DA2de3dE337e3033c20F335765F35F2A7' as `0x${string}`,
  MORPHO_USDC_VAULT: '0x8eB67A509616cd6A7c1B3c8C21D48FF57df3d458' as `0x${string}`,
}

// Mainnet fork configuration
export const CHAIN_CONFIG = {
  chainId: 1, // Mainnet chain ID
  rpcUrl: 'http://127.0.0.1:8545', // Local fork
  blockExplorer: 'https://etherscan.io',
  name: 'Mainnet Fork (Morpho)',
}
