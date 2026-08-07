const { execSync } = require('child_process');
const https = require('https');
const fs = require('fs');
const path = require('path');

const OWNER = 'Satbhai444';
const REPO = 'WINDECK';
const TAG = 'v2.3.6';

const FILES_TO_UPLOAD = [
  'D:\\WINDECK\\Releases\\WinDeck_App_2.3.6.apk',
  'D:\\WINDECK\\Releases\\WinDeck_Server_Setup_2.3.6.exe',
  'D:\\WINDECK\\server\\dist-final\\latest.yml'
];

function getToken() {
  const result = execSync('git credential fill', {
    input: 'protocol=https\nhost=github.com\n\n',
    encoding: 'utf8'
  });
  const line = result.split('\n').find(l => l.startsWith('password='));
  return line ? line.replace('password=', '').trim() : null;
}

function apiRequest(method, urlPath, body, headers) {
  headers = headers || {};
  return new Promise(function(resolve, reject) {
    var options = {
      hostname: 'api.github.com',
      path: urlPath,
      method: method,
      headers: Object.assign({
        'User-Agent': 'WinDeck-Release-Script',
        'Accept': 'application/vnd.github.v3+json'
      }, headers)
    };
    var req = https.request(options, function(res) {
      var data = '';
      res.on('data', function(chunk) { data += chunk; });
      res.on('end', function() {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch(e) { resolve({ status: res.statusCode, data: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(typeof body === 'string' ? body : JSON.stringify(body));
    req.end();
  });
}

function uploadAsset(uploadUrl, filePath, token) {
  return new Promise(function(resolve, reject) {
    var fileName = path.basename(filePath);
    var fileBuffer = fs.readFileSync(filePath);
    var url = new URL(uploadUrl.replace('{?name,label}', '?name=' + fileName));
    var options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'User-Agent': 'WinDeck-Release-Script',
        'Authorization': 'token ' + token,
        'Content-Type': 'application/octet-stream',
        'Content-Length': fileBuffer.length
      }
    };
    var req = https.request(options, function(res) {
      var data = '';
      res.on('data', function(chunk) { data += chunk; });
      res.on('end', function() {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch(e) { resolve({ status: res.statusCode, data: data }); }
      });
    });
    req.on('error', reject);
    req.write(fileBuffer);
    req.end();
  });
}

async function main() {
  var token = getToken();
  if (!token) { console.error('ERROR: No GitHub token'); process.exit(1); }
  console.log('Got GitHub token');

  console.log('Checking if release ' + TAG + ' exists...');
  var existing = await apiRequest('GET', '/repos/' + OWNER + '/' + REPO + '/releases/tags/' + TAG, null, {
    'Authorization': 'token ' + token
  });

  if (existing.status === 200) {
    console.log('Release exists, deleting old one...');
    await apiRequest('DELETE', '/repos/' + OWNER + '/' + REPO + '/releases/' + existing.data.id, null, {
      'Authorization': 'token ' + token
    });
    console.log('Old release deleted.');
  }

  console.log('Creating release ' + TAG + '...');
  var createRes = await apiRequest('POST', '/repos/' + OWNER + '/' + REPO + '/releases', {
    tag_name: TAG,
    name: 'WinDeck ' + TAG,
    body: '## WinDeck v2.3.6 Release\n\n### Whats New:\n- **Clean and Fast UI**: Redesigned UI on PC and Mobile.\n- **Smaller Size**: App size reduced significantly for faster downloads and performance.\n- **OTA Updates**: Background silent OTA update integration for Windows and Mobile.\n- **Performance**: Various bug fixes and connection stability improvements.',
    draft: false,
    prerelease: false
  }, {
    'Authorization': 'token ' + token
  });

  if (createRes.status !== 201) {
    console.error('ERROR creating release:', JSON.stringify(createRes.data));
    process.exit(1);
  }

  console.log('Release created! ID: ' + createRes.data.id);

  for (const filePath of FILES_TO_UPLOAD) {
      if (!fs.existsSync(filePath)) {
          console.error("File not found: " + filePath);
          continue;
      }
      var sizeMB = (fs.statSync(filePath).size / 1024 / 1024).toFixed(1);
      console.log('Uploading ' + path.basename(filePath) + ' (' + sizeMB + ' MB)...');
      var uploadRes = await uploadAsset(createRes.data.upload_url, filePath, token);
      if (uploadRes.status === 201) {
        console.log('Uploaded successfully!');
      } else {
        console.error('ERROR uploading:', JSON.stringify(uploadRes.data));
      }
  }
  
  console.log('All done! Release URL: https://github.com/' + OWNER + '/' + REPO + '/releases/tag/' + TAG);
}

main().catch(function(err) { console.error('Fatal:', err); process.exit(1); });
