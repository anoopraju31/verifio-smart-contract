//0x16A23fDdB613D9beFD0560F67b02f9BF86aD710C

const { ethers } = require('hardhat')

const main = async () => {
	const ProductCode = await ethers.getContractFactory('ProductCode')
	const productCode = await ProductCode.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', //admin
	)

	console.log(productCode.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
