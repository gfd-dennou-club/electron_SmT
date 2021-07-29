const { spawn } = require('child_process');
const div = document.getElementById('box11');
const p = document.createElement('p');
const ret = spawn('bash', ['app/clean.bat'] ,{ shell: true}); 
ret.stderr.on('data', (err) => {
    console.log(err); 
    p.textContent += err;
    p.textContent += "<br>";
    div.innerHTML = p.textContent;  
})
ret.stdout.on('data', (data) => {
    p.textContent += data;
    p.textContent += "<br>";
    div.innerHTML = p.textContent;         
})

