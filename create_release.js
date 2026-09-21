const fs = require('fs');
const path = require('path');
const https = require('https');

const TOKEN = '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';
const OWNER = 'Satbhai444';
const REPO = 'WINDECK';
const TAG = 'v2.3.8';
const TITLE = 'Release v2.3.8';
const BODY = "### What's New\\n- **Anti-Brute Force Lockout**: Protects your PC by locking Windows automatically if 5 incorrect pairing pins are entered.\\n- **Network Stability**: Fixed issues with duplicate PCs appearing during network discovery on VirtualBox/WSL setups.\\n- **Global Media Controls**: Play/Pause and media keys now work seamlessly even when YouTube or Spotify is minimized.\\n- **Instant Reconnect**: Resolved the background disconnection loop. App reconnects instantly when returning from sleep.\\n\\nMake sure to update both your PC Server and your Mobile App to v2.3.8 to connect successfully.";

const exePath = 'D:\\\\WINDECK\\\\server\\\\dist-final\\\\WinDeck Server Setup 2.3.8.exe';
const apkPath = 'D:\\\\WINDECK\\\\android\\\\build\\\\app\\\\outputs\\\\flutter-apk\\\\app-release.apk';

async function request(url, options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(JSON.parse(body || '{}'));
          } else {
            reject(new Error(`API Error ${res.statusCode}: ${body}`));
          }
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on('error', reject);
    if (data) {
      if (Buffer.isBuffer(data)) req.write(data);
      else req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function uploadAsset(uploadUrl, filePath, name, contentType) {
  const url = new URL(uploadUrl.replace('{?name,label}', `?name=${name}`));
  const fileStats = fs.statSync(filePath);
  
  const options = {
    method: 'POST',
    headers: {
      'Authorization': `token ${TOKEN}`,
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': contentType,
      'Content-Length': fileStats.size,
      'User-Agent': 'Node.js'
    }
  };

  console.log(`Uploading ${name} (${fileStats.size} bytes)...`);
  
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`Upload successful: ${name}`);
          resolve();
        } else {
          reject(new Error(`Upload failed ${res.statusCode}: ${body}`));
        }
      });
    });
    
    req.on('error', reject);
    
    const readStream = fs.createReadStream(filePath);
    readStream.pipe(req);
  });
}

async function createRelease() {
  try {
    console.log('Creating release on GitHub...');
    const releaseData = await request(`https://api.github.com/repos/${OWNER}/${REPO}/releases`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${TOKEN}`,
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Node.js',
        'Content-Type': 'application/json'
      }
    }, {
      tag_name: TAG,
      name: TITLE,
      body: BODY,
      draft: false,
      prerelease: false
    });

    console.log(`Release created! ID: ${releaseData.id}`);

    await uploadAsset(releaseData.upload_url, exePath, 'WinDeck.Server.Setup.2.3.8.exe', 'application/x-msdownload');
    await uploadAsset(releaseData.upload_url, apkPath, 'windeck-v2.3.8.apk', 'application/vnd.android.package-archive');

    console.log('All assets uploaded successfully!');
  } catch (error) {
    console.error('Failed:', error.message);
  }
}

createRelease();
