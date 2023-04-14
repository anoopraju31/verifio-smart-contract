const { ethers } = require('hardhat')

const main = async () => {
	const Admin = await ethers.getContractFactory('Admin')
	const admin = await Admin.deploy()

	console.log(admin.address)
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
