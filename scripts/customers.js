//0x16A23fDdB613D9beFD0560F67b02f9BF86aD710C

const { ethers } = require('hardhat')

const main = async () => {
	const Customers = await ethers.getContractFactory('Customers')
	const customers = await Customers.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', // admin
		'0x864bDAD7e2f0e1557F9A7FF311EAbeb2cdEB95Ae', // productCode
		'0x57b43fBBC504Ac591ce13c93eFa7BC22d5a42feb', // retailer
	)

	console.log(customers.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
