pragma solidity ^0.4.24;

interface receiptToken{ 
    function receiveApproval(address _from, uint256 _value, address _token, bytes32 _extraData) external;
}

contract OwnerContract{
    address public owner;

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) public onlyOwner{
        owner = newOwner;
    }
}


contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20_Token is SafeMath,OwnerContract{
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    
        
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address _spender, uint256 value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address=>uint256)) public allowance;
    
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol) public
        {
        totalSupply = initialSupply*10 **uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        }
   
      
    function _transfer(address _from, address _to, uint256 _value) internal{
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(safeAdd(balanceOf[_to], _value) >= balanceOf[_to]);
        
        uint256 initial_Balance = safeAdd(balanceOf[_from], balanceOf[_to]);
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from,_to,_value);
        assert(safeAdd(balanceOf[_from],balanceOf[_to])==initial_Balance);
    }
    
    
    function transfer(address _to, uint256 _value) public returns(bool success){
        _transfer(msg.sender, _to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public{
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to,_value);
        
    }
    
     function approve(address _spender, uint256 _value) public returns(bool success){
        
        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender,_value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes32 _extraData) public returns(bool success){
        receiptToken spender = receiptToken(_spender);
        
        if(approve(_spender,_value)){
            spender.receiveApproval(msg.sender,_value,this, _extraData);
            return true; 
        }
    }
    
    function mintNewToken(address target, uint256 mintedToken ) public onlyOwner{
        balanceOf[target] += mintedToken;
        totalSupply += mintedToken;
    }
    
    
    
    function burn(uint256 _value) public onlyOwner returns(bool success){
        require(balanceOf[msg.sender] >=_value);
        
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender,_value);
        return true;
    }
    
    function burnFrom(address _from,uint256 _value) public returns(bool success){
        require(_value>=allowance[_from][msg.sender]);
        require(balanceOf[_from]>=_value);
        
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        
        emit Burn(msg.sender,_value);

        return true;
        
    }
    
    
}
