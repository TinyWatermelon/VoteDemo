const { FileSystemWallet, Gateway } = require('fabric-network');

const fs = require('fs');

const path = require('path');



const ccpPath = path.resolve(__dirname, '..','..', 'network', 'connection.json');

const ccpJSON = fs.readFileSync(ccpPath, 'utf8');

const ccp = JSON.parse(ccpJSON);



module.exports = {

    async initPage ( ctx ) {

        const title = 'Query Page'
        await ctx.render('query', {
            title
        })

    }

}
