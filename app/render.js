const div = document.getElementById('box11');
const p = document.createElement('p');

// チャンネル 'exec-finish' で非同期メッセージの受信を待機
window.ipc.on('exec-finish', (arg) => {
  // 受信時のコールバック関数
  let result = arg.replace(/\n/g,"<br>");
  p.textContent += result;
  p.textContent += "<br>";
  div.innerHTML = p.textContent; 
  //console.log("ELECTRON") 
});