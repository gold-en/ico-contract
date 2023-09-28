// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract CryptoX_ICO{

    address payable public deposit;
    uint tokenPrice = 0.001 ether;  // 1 ETH = 1000 CRPTX, 1 CRPTX = 0.001
    uint public hardCap = 300 ether;
    uint public raisedAmount; 
    uint public ico_start_time = block.timestamp;
    uint public ico_end_time = block.timestamp + 86400; //24 hours in seconds
    
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;
    
    enum State { beforeStart, running, afterEnd, halted} // ICO states 
    State public icoState;

    address public admin; // the address holding our ERC20 token

    mapping(address => bool) public registered_addresses;
    mapping(address => bool) public claimed_addresses;

    IERC20 public token;
    constructor(address payable _deposit, address _CryptoXAddress){
        token = IERC20(_CryptoXAddress);

        deposit = _deposit; 
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        
        _;
    }
    
    
    // emergency stop
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
    
    
    function resume() public onlyAdmin{
        icoState = State.running;
    }
    
    
    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }
    
    
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < ico_start_time){
            return State.beforeStart;
        }else if(block.timestamp >= ico_start_time && block.timestamp <= ico_end_time){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }

    
    function register() payable public returns(bool){

        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        registered_addresses[msg.sender] = true;
        
        uint256 tokens = msg.value / tokenPrice;

        token.transferFrom(admin, msg.sender, tokens);

        deposit.transfer(msg.value); // transfering the ETH sent to the ICO to the deposit address
        
        
        return true;
    }
   
   function claim(address _address) public returns(bool){
        require(_address != address(0), "address can't be a zero address");
        //checking that the address has registered
        require(registered_addresses[_address], "this address is not yet registered");
    
        claimed_addresses[_address] = true;
        return true;
   }
   
   // this function is called automatically when someone sends ETH to the contract's address
   receive () payable external{
        register();
    }
    
}
