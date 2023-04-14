//0x16A23fDdB613D9beFD0560F67b02f9BF86aD710C

const { ethers } = require('hardhat')

const main = async () => {
	const Manufacturers = await ethers.getContractFactory('Manufacturers')
	const manufacturers = await Manufacturers.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', // admin
		'0xd42E540fb29536c141b1dFEE9c83a414fB41046C', // product
		'0x864bDAD7e2f0e1557F9A7FF311EAbeb2cdEB95Ae', // productCode
	)

	console.log(manufacturers.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
