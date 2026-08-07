const { getStartMenuApps } = require('./modules/appDiscovery'); 
const { exec } = require('child_process'); 
const fs = require('fs'); 

const content = fs.readFileSync('./modules/appDiscovery.js', 'utf8'); 
const script = content.split('\`')[1]; 
const encoded = Buffer.from(script, 'utf16le').toString('base64'); 

exec('powershell -NoProfile -EncodedCommand ' + encoded, {maxBuffer: 1024*1024*20}, (err, stdout, stderr) => { 
    console.log('ERR:', err); 
    console.log('STDERR:', stderr); 
    console.log('STDOUT:', stdout ? stdout.substring(0, 100) : null); 
});
