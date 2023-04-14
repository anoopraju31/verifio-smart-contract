//0x16A23fDdB613D9beFD0560F67b02f9BF86aD710C

const { ethers } = require('hardhat')

const main = async () => {
	const Retailers = await ethers.getContractFactory('Retailers')
	const retailers = await Retailers.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', // admin
		'0x864bDAD7e2f0e1557F9A7FF311EAbeb2cdEB95Ae', // productCode
		'0x303bB2F517850cF24370ED958dd920A7b9270695', // wholesaler
	)

	console.log(retailers.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
