const { spawn } = require('child_process');
const div = document.getElementById('box11');
const p = document.createElement('p');
const ret = spawn('bash', ['app/flash.bat'] ,{ shell: true}); 
ret.stderr.on('data', (err) => {
    console.log(err); 
    p.textContent += err;
    p.textContent += "<br>";
    div.innerHTML = p.textContent;  
    var elementHtml = document.documentElement;
    var bottom = elementHtml.scrollHeight - elementHtml.clientHeight;
    scrollby(0, 300);
})
ret.stdout.on('data', (data) => {
    p.textContent += data;
    p.textContent += "<br>";
    div.innerHTML = p.textContent;
    scrollby(0, 300);       
})

