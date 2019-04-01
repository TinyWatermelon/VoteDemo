const fs = require('fs');
const path = require('path');
const ccpPath = path.resolve(__dirname, '..', 'network', 'connection.json');
const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
const ccp = JSON.parse(ccpJSON);
console.log(`ccp path: ${ccp.toStiring()}`);
