// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract PolicyDetail {

    bool private checknumber;

    struct Details {
        
        string insname;
        string proname;
        uint policyno;
        uint expyear;
        string liability;
        bool empliability;
        uint amount;
        int totalupdates;
    }

    //we have to also add the update data log that this person has change this values from this to this.
    address private accountno;
    struct UpdateLog{
        address updateperson;
        uint blockno;
        string updatetype;
        string prevvalue;
        string updatevalue;
    }
    
    mapping(uint256 => Details) public getbypolicyno;
    mapping(uint => bool) public checkno;
    mapping(uint => UpdateLog[]) public logofpolicyno;
    event Logdata(address);

    function store(string memory _insname,string memory _proname,
    uint _policyno, uint _expyear,string memory _liability , bool _empliability , uint _amount) public {
   
        require(checkno[_policyno]==false,"The data is already used in blockchain pls verify");
        getbypolicyno[_policyno] = Details( _insname, _proname, _policyno, _expyear, _liability, _empliability, _amount,1);
        checkno[_policyno] = true;
        logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Contract Created", "0" , "0"));
    }

    function updateForm(string memory _insname,string memory _proname,
    uint _policyno, uint _expyear,string memory _liability , uint _amount) public {
   
        require(checkno[_policyno]==true,"The detials of this policy is already not stored in the blockchain ");
        if(keccak256(abi.encodePacked(_insname)) != keccak256(abi.encodePacked(getbypolicyno[_policyno].insname))){
            string memory prvvalue = getbypolicyno[_policyno].insname;
            getbypolicyno[_policyno].insname = _insname;
            logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Insurance name", prvvalue,_insname));
            getbypolicyno[_policyno].totalupdates++;
            emit Logdata(msg.sender);
        }
        if(keccak256(abi.encodePacked(_proname)) != keccak256(abi.encodePacked(getbypolicyno[_policyno].proname))){
            string memory prvvalue = getbypolicyno[_policyno].proname;
            getbypolicyno[_policyno].proname = _proname;
            logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Producer Name", prvvalue,_proname));
            getbypolicyno[_policyno].totalupdates++;
        }
        if(_expyear != getbypolicyno[_policyno].expyear){
            uint prvvalue = getbypolicyno[_policyno].expyear;
            getbypolicyno[_policyno].expyear = _expyear;
            logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Expiry year", Strings.toString(prvvalue),Strings.toString(_expyear)));
            getbypolicyno[_policyno].totalupdates++;
        }
        if(keccak256(abi.encodePacked(_liability)) != keccak256(abi.encodePacked(getbypolicyno[_policyno].liability))){
            string memory prvvalue = getbypolicyno[_policyno].liability;
            getbypolicyno[_policyno].liability = _liability;
            logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Liability", prvvalue,_proname));
            getbypolicyno[_policyno].totalupdates++;
        }
        if(_amount != getbypolicyno[_policyno].amount){
            string memory prvvalue = Strings.toString(getbypolicyno[_policyno].amount);
            getbypolicyno[_policyno].amount = _amount;
            logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Amount or Limit", prvvalue,_proname));
            getbypolicyno[_policyno].totalupdates++;
        }
    }
 }