import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

export function WalletConnect() {
  const { address, isConnected } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected && address) {
    return (
      <div className="flex items-center space-x-3">
        <Badge variant="secondary" className="bg-green-500/20 text-green-300 border-green-500/30">
          Connected
        </Badge>
        <span className="text-white font-mono text-sm">
          {address.slice(0, 6)}...{address.slice(-4)}
        </span>
        <Button 
          onClick={() => disconnect()}
          variant="outline"
          size="sm"
          className="border-red-500/50 text-red-300 hover:bg-red-500/10"
        >
          Disconnect
        </Button>
      </div>
    )
  }

  return (
    <Button 
      onClick={() => connect({ connector: connectors[0] })}
      className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white border-0"
    >
      Connect Wallet
    </Button>
  )
}
