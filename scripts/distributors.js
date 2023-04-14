//0x16A23fDdB613D9beFD0560F67b02f9BF86aD710C

const { ethers } = require('hardhat')

const main = async () => {
	const Distributors = await ethers.getContractFactory('Distributors')
	const distributors = await Distributors.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', // admin
		'0x864bDAD7e2f0e1557F9A7FF311EAbeb2cdEB95Ae', // productCode
		'0x7B48c0601E78BdBd050861f738Ac0BA01026DA8B', // manufacturer
	)

	console.log(distributors.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
