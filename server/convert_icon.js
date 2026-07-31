const Jimp = require('jimp');
const pngToIco = require('png-to-ico');
const fs = require('fs');

async function convert() {
  try {
    const image = await Jimp.read('icon.jpg');
    image.resize(256, 256);
    await image.writeAsync('icon.png');
    console.log('Converted to PNG');
    
    const buf = await pngToIco('icon.png');
    fs.writeFileSync('icon.ico', buf);
    console.log('Converted to ICO');
  } catch (err) {
    console.error(err);
  }
}

convert();
