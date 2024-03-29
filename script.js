


var vm = new Vue({
    el: '#vmx',
    data: {
     // pass:'', 
      addr:'',
      tarif:10,
      met:0,
      txid:' ',
      priv:'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', //0x6dbAA3daD7F3F57E2f8b9ebA8eF7a29220dDB8ba
      privx:'',
      payment:0,
      credit:0,
      debit:0,
      linkcre:'',
      linkdeb:''
     
    }
  });
  


//tabs
var tabcontent = document.getElementsByClassName("tabcontent");
swtab(4);
function swtab(n) {

  for (var i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
  }
  tabcontent[n].style.display = "flex"; 
}


var web3 = new Web3('https://rinkeby.infura.io/v3/xxxxxxxxxxxxxxxxxxxxxxxxxx');

var ABI = [
  // balanceOf
  {
    "constant":true,
    "inputs":[{"name":"_owner","type":"address"}],
    "name":"balanceOf",
    "outputs":[{"name":"balance","type":"uint256"}],
    "type":"function"
  }
];
var cred = "0x3716BaE97c0f67374D2c9931f152138578D1fccf"; //адрес токена CREDIT
var debi = "0x08994ca1901359705C62969bfd5b09Ea24232e3B" //адрес токена DEBIT
var cocred = new web3.eth.Contract(ABI, cred);
var codebi = new web3.eth.Contract(ABI, debi);


updresp(1);  
setInterval(updresp,5000,0);

function crewal() {
  // if (vm.pass == '') alert('Введите пароль!')
     
         var wal = web3.eth.accounts.create(web3.utils.randomHex(32));
         vm.addr = wal.address;
         vm.privx = wal.privateKey;
         //vm.enpriv = web3.eth.accounts.encrypt(vm.priv, vm.pass);
 
   swtab(6)
 }

 async function logwal() {
  try {vm.addr =  web3.eth.accounts.privateKeyToAccount(vm.privx).address;}
  catch(e){alert('Неверный приватный ключ!');return}

  //updbal();
  //setInterval(updbal,30000);
  swtab(0) ; 
  
}

function logout() {
  vm.privx = '';
  swtab(4);
}

async function check() {
	var ch = await web3.utils.isAddress(vm.addr);
	if (!ch) alert('Неверный идентификатор клиента!');
	return ch;
}

async function meter() {
  vm.met = 0;
	if (vm.tarif > 10) {alert('Нереальный тариф (допустимо от 0 до 10)'); return}
	if (!await check(vm.addr)) return;
  try {
  var str = "00000000000000000000000000000000";
  var tar = web3.utils.toHex(vm.tarif).substr(2);
  tar = str.substr(0,str.length - tar.length) + tar;
  
  var rawTransaction ={
    // "from": vm.addr,
    // "nonce": "0x" + count.toString(16),
    // "gasPrice": "0x003B9ACA00",
     "gas": "0x250CA",
     "to": "0x38011EA2a9B77179D764792322487A5e41008639",
     "value": "0x0",
     "data": "0x4996a146000000000000000000000000"+vm.addr.substr(2)+"00000000000000000000000000000000"+tar,
    // "chainId": 0x03
   };

   var sign = await web3.eth.accounts.signTransaction(rawTransaction, vm.priv);
   web3.eth.sendSignedTransaction(sign.rawTransaction, function(er,resp){if (er == null) {
     alert('Транзакция успешно отправлена. Ожидайте ответа оракула ~60c.'); 
     document.getElementById('txid').innerHTML = "<a href = 'https://rinkeby.etherscan.io/tx/" + resp + "' target = '_blank'>Хэш: "+resp+"</a>"
     } 
     else {alert('Ошибка отправки транзакции '+ er)} });
    }catch(e){alert(e)}
    
}

async function pay() {
  vm.payment = 0;
  if (!await check(vm.addr)) return;
  
  try {
  
  var rawTransaction ={
    // "from": vm.addr,
    // "nonce": "0x" + count.toString(16),
    // "gasPrice": "0x003B9ACA00",
     "gas": "0x250CA",
     "to": "0xf9Ea7D1A14541511A1803754fb71B5F09957a63c",
     "value": "0x0",
     "data":"0x7c4bd7c4000000000000000000000000"+vm.addr.substr(2),
    // "chainId": 0x03
   };

   var sign = await web3.eth.accounts.signTransaction(rawTransaction, vm.priv);
   web3.eth.sendSignedTransaction(sign.rawTransaction, function(er,resp){if (er == null) {
     alert('Транзакция успешно отправлена. Ожидайте ответа оракула ~60c.'); 
     document.getElementById('txid2').innerHTML = "<a href = 'https://rinkeby.etherscan.io/tx/" + resp + "' target = '_blank'>Хэш: "+resp+"</a>"
     } 
     else {alert('Ошибка отправки транзакции '+ er)} });
    }catch(e){alert(e)}
    
}

var tem, tem2;
 async function updresp(t) {

web3.eth.getStorageAt("0x38011EA2a9B77179D764792322487A5e41008639",8).then(function(resp){
var temp = web3.utils.hexToNumberString(resp);
if (t == 1) {tem = temp}
if (temp != tem) {vm.met = temp; tem = temp; alert('Показания счётчика: '+temp+' кВт')}

})

web3.eth.getStorageAt("0xf9Ea7D1A14541511A1803754fb71B5F09957a63c",8).then(function(resp){
  var temp2 = Math.round(Number(web3.utils.hexToNumberString(resp))/10);
  if (t == 1) {tem2 = temp2}
  if (temp2 != tem2) {vm.payment = temp2; tem2 = temp2; alert('Сумма платёжа клиента: '+temp2+' руб.')}
  
  })
try{
 vm.credit = Math.round( await cocred.methods.balanceOf(vm.addr).call()*1e-18);
}catch(e){vm.credit = 'n/a'}
try{
 vm.debit = Math.round( await codebi.methods.balanceOf(vm.addr).call()*1e-19);
}catch(e){vm.debit = 'n/a'}

vm.linkcre = "<a href='https://rinkeby.etherscan.io/token/0x3716bae97c0f67374d2c9931f152138578d1fccf?a="+vm.addr+"' target = '_blank'> (etherscan)</a>";
vm.linkdeb = "<a href='https://rinkeby.etherscan.io/token/0x08994ca1901359705C62969bfd5b09Ea24232e3B?a="+vm.addr+"' target = '_blank'> (etherscan)</a>";


    

  

}
