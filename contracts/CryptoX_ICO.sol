// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract CryptoX_ICO{

    address payable public deposit;
    uint tokenPrice = 0.001 ether;  // 1 ETH = 1000 CRPTX, 1 CRPTX = 0.001
    uint public hardCap = 300 ether;
    uint public raisedAmount; 
    uint public ico_start_time = block.timestamp;
    uint public ico_end_time = block.timestamp + 86400; //one week
    
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;
    
    enum State { beforeStart, running, afterEnd, halted} // ICO states 
    State public icoState;

    address public icoAdmin;

    mapping(address => bool) public registered_addresses;
    mapping(address => bool) public claimed_addresses;

    IERC20 public token;
    constructor(address payable _deposit, address _CryptoXAddress){
        token = IERC20(_CryptoXAddress);

        deposit = _deposit; 
        icoAdmin = msg.sender;
        icoState = State.beforeStart;
    }

    
    modifier onlyAdmin(){
        require(msg.sender == icoAdmin);
        
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


    event Invest(address investor, uint value, uint tokens);
    
    // function called when sending eth to the contract
    function register() payable public returns(bool){

        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        registered_addresses[msg.sender] = true;
        
        uint tokens = msg.value / tokenPrice;

        // adding tokens to the inverstor's balance from the tokenAdmin's balance
        //WHERE MY PROBLEM STARTED--TRYING TO CALL THE FUNCTIONS FROM THE token(CRYPTOX) CONTRACT
        token.balances[msg.sender] += tokens;
        token.balance[token.admin] -= tokens; 
        token.transfer(msg.sender, tokens);

        deposit.transfer(msg.value); // transfering the value sent to the ICO to the deposit address
        
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }
   
   function claim(address _address) public returns(bool){
        require(_address != address(0), "address can't be a zero address");
        //checking that the address has registered
        require(registered_addresses[_address], "this address is not yet registered");
    
        claimed_addresses[_address] = true;
   }
   
   // this function is called automatically when someone sends ETH to the contract's address
   receive () payable external{
        register();
    }
  
    
    // burning unsold tokens
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        token.balances[token.admin] = 0;
        return true;
        
    }
    
}
