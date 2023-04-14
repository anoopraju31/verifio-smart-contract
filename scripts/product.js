//0x6eD2Fc8e392BBCbDa30AD62E62FE0749141Cf1b7

const { ethers } = require('hardhat')

const main = async () => {
	const Product = await ethers.getContractFactory('Products')
	const product = await Product.deploy(
		'0x8776eAD4DBE83F2d04E056ea52E601fe5C998277', //admin
	)

	console.log(product.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
