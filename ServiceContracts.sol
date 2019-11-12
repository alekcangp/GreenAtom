pragma solidity 0.4.24;

//Используется децантрализованная сеть оракулов ChainLink

import "https://github.com/smartcontractkit/chainlink/evm/contracts/Chainlinked.sol"; // 
import "https://github.com/smartcontractkit/chainlink/evm/contracts/vendor/Ownable.sol";


// Контракт получает показания счётчика и выставляет счёт клиенту (Rinkeby 0x38011EA2a9B77179D764792322487A5e41008639)
// Стоимость одного запроса 1 LINK токен

contract CreditContract is Chainlinked, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;
  string private jobId = "b00ed7210563488cbe5a3b7729c0ec72";//Задача для оракула: random api - httpGet - JSONparse - uint256 - sendTx
  uint256 public currentMeter;
  uint256 public tarif; // тариф, на который умножается показание счётчика
  address public client; // адрес (идентификатор клиента)
  address private oracle = 0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e;// Контракт Оракула, использует API random.org
  address private token = 0x3716BaE97c0f67374D2c9931f152138578D1fccf; //Адрес токена CREDIT (Rinkeby)
  
  
  event RequestCoord(
    bytes32 indexed requestId,
    uint256 indexed coord
  );

  constructor() public {
    setPublicChainlinkToken();
  }
  
  //Отправляет запрос оракулу на получение показаний счетчика (для эмуляции используется API random.org, случайное число от 0 до 100)

  function updateMeter(address _client, uint256 _tarif) public {
    client = _client;
    tarif = _tarif;
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(jobId), this, this.report.selector);
    req.addUint("min", 0);
    req.addUint("max", 100);
    sendChainlinkRequestTo(oracle, req, ORACLE_PAYMENT);
  }
  
  //Получает ответ и выставляет счет (отправляет CREDIT на адрес клинта)
  
  function report(bytes32 _requestId, uint256 _coord)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestCoord(_requestId, _coord);
    currentMeter = _coord;
    Credit(token).transfer(client, currentMeter*LINK*tarif);
  }
  
  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { 
      result := mload(add(source, 32))
    }
  }
  
  
   function withdrawLink() public  onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
   }
    function withdrawCREDIT() public  onlyOwner {
    LinkTokenInterface credit = LinkTokenInterface(token);
    require(credit.transfer(msg.sender, credit.balanceOf(address(this))), "Unable to transfer");
  }
  
  function destroy()
    external
    onlyOwner
  {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    LinkTokenInterface credit = LinkTokenInterface(token);
    require(credit.transfer(msg.sender, credit.balanceOf(address(this))), "Unable to transfer");
    selfdestruct(owner);
  }
  

}

// Контракт получает данные об оплате клиентом из банка и вносит изменения в блокчейн (Rinkeby 0xf9Ea7D1A14541511A1803754fb71B5F09957a63c)
// Стоимость одного запроса 1 LINK токен

contract DebitContract is Chainlinked, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;
  string private jobId = "367c3cb39ab34bccad27deea5e37f365";//Задача для оракула: httpGet - JSONparse - uint256 - sendTx (https://docs.chain.link/docs/addresses-and-job-ids)
  uint256 public currentPayment;

  address public client; // адрес (идентификатор клиента)
  address private oracle = 0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e;// Контракт Оракула
  address private token = 0x08994ca1901359705C62969bfd5b09Ea24232e3B; //Адрес токена DEBIT (Rinkeby)
  
  
  event RequestCoord(
    bytes32 indexed requestId,
    uint256 indexed coord
  );

  constructor() public {
    setPublicChainlinkToken();
  }
  
  //Отправляет запрос оракулу на получение данных об оплате (для эмуляции используется текущий курс BTC/USD API cryptocompare.com)

  function updatePayment(address _client) public {
    client = _client;
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(jobId), this, this.report.selector);
    req.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD");
    req.add("path", "RAW.BTC.USD.PRICE");
    sendChainlinkRequestTo(oracle, req, ORACLE_PAYMENT);
  }
  
  //Получает ответ и отправляет соответствующее количество токенов DEBIT на адрес клиента
  
  function report(bytes32 _requestId, uint256 _coord)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestCoord(_requestId, _coord);
    currentPayment = _coord;
    Debit(token).transfer(client, currentPayment*LINK);
  }
  
  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { 
      result := mload(add(source, 32))
    }
  }
  
  
   function withdrawLink() public  onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
   }
    function withdrawDEBIT() public  onlyOwner {
    LinkTokenInterface debit = LinkTokenInterface(token);
    require(debit.transfer(msg.sender, debit.balanceOf(address(this))), "Unable to transfer");
  }
  
  function destroy()
    external
    onlyOwner
  {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    LinkTokenInterface debit = LinkTokenInterface(token);
    require(debit.transfer(msg.sender, debit.balanceOf(address(this))), "Unable to transfer");
    selfdestruct(owner);
  }
  

}



//Контракт токена CREDIT (Rinkeby 0x3716BaE97c0f67374D2c9931f152138578D1fccf)

contract Credit {
 
    uint256 totalSupply_; 
    string public constant name = "CREDIT";
    string public constant symbol = "CREDIT";
    uint8 public constant decimals = 18;
    uint256 public constant initialSupply = 3141592653*(10**uint256(decimals));
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowed;
    
    function totalSupply() public view returns (uint256){
        return totalSupply_;
    }
 
    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
  }
 
    function transfer(address _to, uint256 _value) public returns (bool ) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value); 
        balances[msg.sender] = balances[msg.sender] - _value; 
        balances[_to] = balances[_to] + _value; 
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
 
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]); 
        balances[_from] = balances[_from] - _value; 
        balances[_to] = balances[_to] + _value; 
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value; 
        emit Transfer(_from, _to, _value); 
        return true; 
        } 
 
     function increaseApproval(address _spender, uint _addedValue) public returns (bool) { 
     allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue; 
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
     return true; 
     } 
 
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) { 
    uint oldValue = allowed[msg.sender][_spender]; 
    if (_subtractedValue > oldValue) {
 
        allowed[msg.sender][_spender] = 0;
    } 
        else {
        allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
    }
 
    function Credit() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(0x0, msg.sender, initialSupply);
    }
}


//Контракт токена DEBIT (Rinkeby 0x08994ca1901359705C62969bfd5b09Ea24232e3B)

contract Debit {
 
    uint256 totalSupply_; 
    string public constant name = "DEBIT";
    string public constant symbol = "DEBIT";
    uint8 public constant decimals = 18;
    uint256 public constant initialSupply = 3141592653*(10**uint256(decimals));
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowed;
    
    function totalSupply() public view returns (uint256){
        return totalSupply_;
    }
 
    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
  }
 
    function transfer(address _to, uint256 _value) public returns (bool ) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value); 
        balances[msg.sender] = balances[msg.sender] - _value; 
        balances[_to] = balances[_to] + _value; 
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
 
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]); 
        balances[_from] = balances[_from] - _value; 
        balances[_to] = balances[_to] + _value; 
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value; 
        emit Transfer(_from, _to, _value); 
        return true; 
        } 
 
     function increaseApproval(address _spender, uint _addedValue) public returns (bool) { 
     allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue; 
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
     return true; 
     } 
 
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) { 
    uint oldValue = allowed[msg.sender][_spender]; 
    if (_subtractedValue > oldValue) {
 
        allowed[msg.sender][_spender] = 0;
    } 
        else {
        allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
    }
 
    function Debit() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(0x0, msg.sender, initialSupply);
    }
}