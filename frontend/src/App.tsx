import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Toaster } from '@/components/ui/sonner';
import { Web3Provider } from './components/Web3Provider';
import { WalletConnect } from './components/WalletConnect';
import { useVaultData } from './hooks/useVaultData';
import './App.css';

const OctantV2App = () => {
  const [activeTab, setActiveTab] = useState('deposit');
  const [depositAmount, setDepositAmount] = useState('');
  const [withdrawAmount, setWithdrawAmount] = useState('');
  
  const vaultData = useVaultData();

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      {/* Header */}
      <header className="border-b border-purple-500/20 bg-black/40 backdrop-blur-md">
        <div className="container mx-auto flex h-20 items-center justify-between px-6">
          <div className="flex items-center space-x-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-r from-purple-500 to-pink-500">
              <span className="text-lg font-bold text-white">O</span>
            </div>
            <div>
              <h1 className="text-2xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                Octant V2
              </h1>
              <Badge variant="secondary" className="text-xs bg-purple-500/20 text-purple-300 border-purple-500/30">
                Morpho Powered
              </Badge>
            </div>
          </div>
          <WalletConnect />
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-6 py-12">
        {/* Stats Section */}
        <div className="mb-12">
          <Card className="bg-black/40 border-purple-500/30 backdrop-blur-md">
            <CardHeader>
              <CardTitle className="text-2xl font-bold text-white">Vault Statistics</CardTitle>
              <CardDescription className="text-purple-300">Real-time data from Morpho lending protocol</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="text-center p-6 rounded-lg bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/20">
                  <p className="text-3xl font-bold bg-gradient-to-r from-green-400 to-emerald-400 bg-clip-text text-transparent">
                    ${vaultData.totalAssets.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </p>
                  <p className="text-sm text-green-300 font-medium">Total Assets</p>
                </div>
                <div className="text-center p-6 rounded-lg bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border border-blue-500/20">
                  <p className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">
                    {vaultData.isConnected ? '~5.2%' : '0.00%'}
                  </p>
                  <p className="text-sm text-blue-300 font-medium">Current APY</p>
                </div>
                <div className="text-center p-6 rounded-lg bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20">
                  <p className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                    ${vaultData.availableYield.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </p>
                  <p className="text-sm text-purple-300 font-medium">Available Yield</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* User Balance Section - Only show when connected */}
        {vaultData.isConnected && (
          <div className="mb-8">
            <Card className="bg-black/40 border-yellow-500/30 backdrop-blur-md">
              <CardHeader>
                <CardTitle className="text-xl font-bold text-white">Your Portfolio</CardTitle>
                <CardDescription className="text-yellow-300">Your current holdings and balances</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="text-center p-4 rounded-lg bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border border-yellow-500/20">
                    <p className="text-2xl font-bold bg-gradient-to-r from-yellow-400 to-orange-400 bg-clip-text text-transparent">
                      ${vaultData.userUsdcBalance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </p>
                    <p className="text-sm text-yellow-300 font-medium">USDC Balance</p>
                  </div>
                  <div className="text-center p-4 rounded-lg bg-gradient-to-br from-cyan-500/10 to-blue-500/10 border border-cyan-500/20">
                    <p className="text-2xl font-bold bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
                      ${vaultData.userAssetValue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </p>
                    <p className="text-sm text-cyan-300 font-medium">Vault Position</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Action Tabs */}
        <Card className="mx-auto max-w-2xl bg-black/40 border-purple-500/30 backdrop-blur-md">
          <CardHeader>
            <CardTitle className="text-2xl font-bold text-white">Yield-Driven Staking</CardTitle>
            <CardDescription className="text-purple-300">
              Deposit USDC to generate yield through Morpho lending. All yield is donated to public goods.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
              <TabsList className="grid w-full grid-cols-3 bg-purple-900/50 border border-purple-500/30">
                <TabsTrigger value="deposit" className="data-[state=active]:bg-purple-600 data-[state=active]:text-white text-purple-300">Deposit</TabsTrigger>
                <TabsTrigger value="withdraw" className="data-[state=active]:bg-purple-600 data-[state=active]:text-white text-purple-300">Withdraw</TabsTrigger>
                <TabsTrigger value="harvest" className="data-[state=active]:bg-purple-600 data-[state=active]:text-white text-purple-300">Harvest</TabsTrigger>
              </TabsList>
              
              <TabsContent value="deposit" className="mt-6">
                <div className="space-y-6">
                  <div className="space-y-3">
                    <Label htmlFor="deposit-amount" className="text-white font-medium">Amount (USDC)</Label>
                    <Input
                      id="deposit-amount"
                      placeholder="0.00"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      className="bg-purple-900/30 border-purple-500/50 text-white placeholder:text-purple-400 focus:border-purple-400"
                    />
                  </div>
                  <Button className="w-full bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white border-0 py-3 text-lg font-semibold" disabled>
                    Connect Wallet to Deposit
                  </Button>
                  <p className="text-sm text-purple-300 text-center">
                    💰 Your USDC will be invested in Morpho to generate real yield for public goods.
                  </p>
                </div>
              </TabsContent>
              
              <TabsContent value="withdraw" className="mt-6">
                <div className="space-y-6">
                  <div className="space-y-3">
                    <Label htmlFor="withdraw-amount" className="text-white font-medium">Amount (USDC)</Label>
                    <Input
                      id="withdraw-amount"
                      placeholder="0.00"
                      value={withdrawAmount}
                      onChange={(e) => setWithdrawAmount(e.target.value)}
                      className="bg-purple-900/30 border-purple-500/50 text-white placeholder:text-purple-400 focus:border-purple-400"
                    />
                  </div>
                  <Button className="w-full bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white border-0 py-3 text-lg font-semibold" disabled>
                    Connect Wallet to Withdraw
                  </Button>
                  <p className="text-sm text-purple-300 text-center">
                    🔄 Withdraw your principal at any time. Generated yield stays donated.
                  </p>
                </div>
              </TabsContent>
              
              <TabsContent value="harvest" className="mt-6">
                <div className="space-y-6">
                  <div className="text-center p-6 rounded-lg bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border border-yellow-500/20">
                    <p className="text-lg font-semibold text-white mb-2">Available Yield</p>
                    <p className="text-4xl font-bold bg-gradient-to-r from-yellow-400 to-orange-400 bg-clip-text text-transparent">
                      ${vaultData.availableYield.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    </p>
                    <p className="text-sm text-yellow-300 mt-2">Ready to donate to public goods</p>
                  </div>
                  <Button 
                    className="w-full bg-gradient-to-r from-yellow-600 to-orange-600 hover:from-yellow-700 hover:to-orange-700 text-white border-0 py-3 text-lg font-semibold" 
                    disabled={!vaultData.isConnected || vaultData.availableYield <= 0}
                  >
                    {!vaultData.isConnected 
                      ? 'Connect Wallet to Harvest' 
                      : vaultData.availableYield <= 0 
                        ? 'No Yield Available' 
                        : `Harvest $${vaultData.availableYield.toFixed(2)}`
                    }
                  </Button>
                  <p className="text-sm text-purple-300 text-center">
                    🌱 Harvest and automatically donate generated yield to public goods recipients.
                  </p>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>

        {/* How it Works */}
        <div className="mt-16">
          <h2 className="mb-8 text-center text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            How Octant V2 Works
          </h2>
          <div className="grid gap-8 md:grid-cols-3">
            <Card className="bg-black/40 border-blue-500/30 backdrop-blur-md hover:border-blue-400/50 transition-colors">
              <CardHeader>
                <CardTitle className="flex items-center space-x-3">
                  <span className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-r from-blue-500 to-cyan-500 text-lg font-bold text-white">
                    1
                  </span>
                  <span className="text-white">Deposit USDC</span>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-blue-300">
                  💳 Deposit your USDC into the vault to start generating yield through Morpho lending protocol.
                </p>
              </CardContent>
            </Card>
            <Card className="bg-black/40 border-green-500/30 backdrop-blur-md hover:border-green-400/50 transition-colors">
              <CardHeader>
                <CardTitle className="flex items-center space-x-3">
                  <span className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-r from-green-500 to-emerald-500 text-lg font-bold text-white">
                    2
                  </span>
                  <span className="text-white">Earn Real Yield</span>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-green-300">
                  📈 Your USDC generates real yield through Morpho's lending protocol. Your principal stays safe.
                </p>
              </CardContent>
            </Card>
            <Card className="bg-black/40 border-purple-500/30 backdrop-blur-md hover:border-purple-400/50 transition-colors">
              <CardHeader>
                <CardTitle className="flex items-center space-x-3">
                  <span className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-lg font-bold text-white">
                    3
                  </span>
                  <span className="text-white">Fund Public Goods</span>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-purple-300">
                  🌍 All generated yield is automatically donated to public goods. You keep your principal.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </main>
      
      {/* Footer */}
      <footer className="border-t border-purple-500/20 bg-black/40 backdrop-blur-md mt-20">
        <div className="container mx-auto px-6 py-8 text-center">
          <p className="text-purple-300 font-medium">
            ✨ Octant V2 - Yield-Driven Staking for Public Goods • Powered by Morpho ✨
          </p>
        </div>
      </footer>
      
      <Toaster />
    </div>
  );
};

function App() {
  return (
    <Web3Provider>
      <OctantV2App />
    </Web3Provider>
  );
}

export default App;
