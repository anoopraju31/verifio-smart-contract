// require('@nomicfoundation/hardhat-toolbox')
require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')

module.exports = {
	defaultNetwork: 'sepolia',
	networks: {
		hardhat: {},
		sepolia: {
			url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	solidity: {
		version: '0.8.0',
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
}
