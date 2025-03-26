async function main() {
    // 1. Desplegar implementaciones
    const CoreImpl = await ethers.getContractFactory("SavingGroupsCore");
    const coreImpl = await CoreImpl.deploy();
    
    const PaymentsImpl = await ethers.getContractFactory("SavingGroupsPayments");
    const paymentsImpl = await PaymentsImpl.deploy();
    
    // 2. Desplegar proxies
    const CoreProxy = await ethers.getContractFactory("SavingGroupsCoreProxy");
    const coreProxy = await CoreProxy.deploy(
        coreImpl.address,
        proxyAdmin.address,
        coreImpl.interface.encodeFunctionData("initialize", [/* params */])
    );
    
    // ... desplegar otros proxies
} 