const { ethers } = require('hardhat')
const contractABI = require('../artifacts/contracts/Admin.sol/Admin.json').abi

const adminContractAddress = '0x8776eAD4DBE83F2d04E056ea52E601fe5C998277'
const productsContractAddress = '0xd42E540fb29536c141b1dFEE9c83a414fB41046C'
const productCodeContractAddress = '0x864bDAD7e2f0e1557F9A7FF311EAbeb2cdEB95Ae'
const manufacturerContractAddress = '0x7B48c0601E78BdBd050861f738Ac0BA01026DA8B'
const distributorsContractAddress = '0x7f38B3A980315B83938c765F102CEF2F7fe2767F'
const wholesalersContractAddress = '0x303bB2F517850cF24370ED958dd920A7b9270695'
const retailersContractAddress = '0x57b43fBBC504Ac591ce13c93eFa7BC22d5a42feb'
const customersContractAddress = '0x406d4440f759292E2B6C26fAC76507fa88d5F2ad'

const main = async () => {
	const Admin = await ethers.getContractFactory('Admin')
	const admin = await Admin.attach(adminContractAddress)

	// const adminAddress = await admin.getAdmin()
	// console.log(adminAddress === '0x19EA0f475B7653Ec108B62D363bcD2dAC3e937e6')

	const addCustomersContractAddressAdmin =
		await admin.addCustomersContractAddress(customersContractAddress)
	await addCustomersContractAddressAdmin.wait()

	const ProductCode = await ethers.getContractFactory('ProductCode')
	const productCode = await ProductCode.attach(productCodeContractAddress)

	const addManufacturerContractAddress =
		await productCode.addManufacturerContractAddress(
			manufacturerContractAddress,
		)
	await addManufacturerContractAddress.wait()

	const addDistributorContractAddress =
		await productCode.addDistributorContractAddress(distributorsContractAddress)
	await addDistributorContractAddress.wait()

	const addWholesalerContractAddress =
		await productCode.addWholesalerContractAddress(wholesalersContractAddress)
	await addWholesalerContractAddress.wait()

	const addRetailerContractAddress =
		await productCode.addRetailerContractAddress(retailersContractAddress)
	await addRetailerContractAddress.wait()

	const addCustomerContractAddress =
		await productCode.addCustomerContractAddress(customersContractAddress)
	await addCustomerContractAddress.wait()

	const Distributors = await ethers.getContractFactory('Distributors')
	const distributors = await Distributors.attach(distributorsContractAddress)

	const addWholesalersContractAddress =
		await distributors.addWholesalersContractAddress(wholesalersContractAddress)
	await addWholesalersContractAddress.wait()

	const Manufacturers = await ethers.getContractFactory('Manufacturers')
	const manufacturers = await Manufacturers.attach(manufacturerContractAddress)

	const addDistributorsContractAddress =
		await manufacturers.addDistributorsContractAddress(
			distributorsContractAddress,
		)
	await addDistributorsContractAddress.wait()

	const Wholesalers = await ethers.getContractFactory('Wholesalers')
	const wholesalers = await Wholesalers.attach(wholesalersContractAddress)

	const addRetailersContractAddress =
		await wholesalers.addRetailersContractAddress(retailersContractAddress)
	await addRetailersContractAddress.wait()

	const Retailers = await ethers.getContractFactory('Retailers')
	const retailers = await Retailers.attach(retailersContractAddress)

	const addCustomersContractAddress =
		await retailers.addCustomersContractAddress(customersContractAddress)
	await addCustomersContractAddress.wait()
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
