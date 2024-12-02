pragma solidity 0.8.21;

contract hospitalDeviceManagement{

    address public headOfDepartment;
    string[] public class;
    uint256[] public devices;
    address[] public administrators;
    //uint32 usage;

     struct Class{
        uint256 classId;
        string className;
    }

    struct Device{
        bool InUse; // 0
        //address ad_administratorsAddress; // 1
        bool isActive;
        uint256 deviceId;
        string deviceName; // 2
        uint256 classId;
        uint32 usage;
        bool inMaintenance;
    }

   //

    struct Administrator{
        bool isActive;
        address administratorAddress;
        string administratorsName;
        uint32 Id;
    }

    enum Type{
        ADMINISTRATOR,
        DEVICE
    }

    constructor(){
        headOfDepartment = msg.sender;
        
    }

     uint classId;
     //uint usage;
    mapping (uint256 => Class) public classIdToClass; // deviceType
    mapping (uint256 => Device) public IdToDevice; //serialId
    mapping (address => Administrator) public addressToAdministrator;

    event StatusChanged(address _address, bool _isActive);
    event StatusUsage(uint256 _DeviceId, bool _InUse, uint256 _Usage);

    function generateRandomId() internal view returns (uint32) {
        uint32 randomId = uint32(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 900000 + 100000);
        return randomId;
    }

    function registerAdministrator(string calldata _name, Type _type, address _address) onlyHOD external{
        uint32 randomId = generateRandomId();
        
        if(_type == Type.ADMINISTRATOR){
            Administrator memory newAdministrator = Administrator(false, _address, _name, randomId);
            administrators.push(_address);
            addressToAdministrator[_address] = newAdministrator;
        }
        /*else if(_type == Type.DEVICE){
            Device memory newDevice = Device(false, Id, _name, 0);
            devices.push(Id);
            IdToDevice[Id] = newDevice;
        }*/
    }

    function registerDevice(string calldata _name, Type _type, uint serialId) onlyHOD onlyAdministrator external{

        if(_type == Type.DEVICE){
            Device memory newDevice = Device(false, false, serialId, _name, 0, 0, false);
            devices.push(serialId);
            IdToDevice[serialId] = newDevice;
        }
    }

    function createMedicalType(string calldata _class) onlyHOD external{
        class.push(_class);
        classId++;
        Class memory newClass = Class(classId, _class);
        classIdToClass[classId] = newClass;
    }

    function assignMedicalDevice(uint256 _DeviceId, uint256 _classId) onlyAdministrator classExist(_classId) external{
        require(IdToDevice[_DeviceId].isActive, "Medical Device is not active.");
        IdToDevice[_DeviceId].classId = _classId;
    }

    function Maintenance(uint256 _DeviceId) onlyAdministrator external{
        require(IdToDevice[_DeviceId].InUse == false, "Medical Device is in use.");
        IdToDevice[_DeviceId].inMaintenance = !IdToDevice[_DeviceId].inMaintenance;

        if(IdToDevice[_DeviceId].inMaintenance == true){
            IdToDevice[_DeviceId].usage = 0;
        }

        emit StatusUsage(_DeviceId, IdToDevice[_DeviceId].InUse, IdToDevice[_DeviceId].usage);
    }

    function changeAdministratorStatus(address _administrators) onlyHOD external{
        addressToAdministrator[_administrators].isActive = !addressToAdministrator[_administrators].isActive;
        emit StatusChanged(_administrators, addressToAdministrator[_administrators].isActive);
    }

    function changeDeviceStatus(uint256 DeviceId) onlyAdministrator onlyHOD external{
        IdToDevice[DeviceId].isActive = !IdToDevice[DeviceId].isActive;
        emit StatusUsage(DeviceId, IdToDevice[DeviceId].isActive, 0);
    }

    function changeDeviceUsage(uint256 DeviceId) onlyAdministrator onlyHOD external{
        require(IdToDevice[DeviceId].isActive == true, "device need to be activated");
        require(IdToDevice[DeviceId].inMaintenance == false, "device undergo maintenances");
        //uint32 Usage = 0;
        //Device memory usageDevice = Device(true, false, serialId,_name, usage);
        //if (IdToDevice[DeviceId].isActive == true){    
        IdToDevice[DeviceId].InUse = !IdToDevice[DeviceId].InUse;
        if(IdToDevice[DeviceId].InUse == true){
          IdToDevice[DeviceId].usage += 1;
        }
        
        emit StatusUsage(DeviceId, IdToDevice[DeviceId].InUse, IdToDevice[DeviceId].usage);
        //}

    }

    modifier onlyHOD{
        require(msg.sender == headOfDepartment, "Only Head of Department can execute function.");
        _;
    }

    modifier onlyAdministrator{
        require(addressToAdministrator[msg.sender].isActive, "Only administrator can execute function.");
        _;
    }

    modifier classExist(uint256 _classId) {
        require(class.length > 0 && classIdToClass[_classId].classId != 0, "No classes to assign.");
        _;
    }


}