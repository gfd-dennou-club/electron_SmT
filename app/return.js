const exec = require('child_process').exec;
exec('cd app & submit.bat', (err, stdout, stderr) => {
    if (err) { console.log(err); }
    const div = document.getElementById('box11');
    const p = document.createElement('p');
    p.textContent = stdout;
    p.textContent = stderr;
    div.innerHTML = p.textContent;          
});
