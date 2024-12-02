import {ethers} from "hardhat"

async function main(){
    var factory = await ethers.getContractFactory("hospitalDeviceManagement");
    var hospitalDeviceManagement = await factory.deploy();

    console.log("Address: ", hospitalDeviceManagement.getAddress());
}

main();
