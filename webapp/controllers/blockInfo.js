const { FileSystemWallet, Gateway } = require('fabric-network');
const fs = require('fs');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..','..', 'network', 'connection.json');
const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
const ccp = JSON.parse(ccpJSON);


module.exports = {
    async initPage ( ctx ) {
		const queryBody = ctx.request.query;
        const blockId = queryBody.blockId;
        const title = 'Block information page';

        let result = ''
		try {
			//const peer = new Peer("grpc://localhost:7051");
			
			const walletPath = path.join(process.cwd(), 'wallet');
			const wallet = new FileSystemWallet(walletPath);
			console.log(`Wallet path: ${walletPath}`);

			const userExists = await wallet.exists('louis');
			if (!userExists) {
				console.log('An identity for the user "louis" does not exist in the wallet');
				console.log('Run the registerUser.js application before retrying');
				return;
			}

			const gateway = new Gateway();
			await gateway.connect(ccp, { wallet, identity: 'louis', discovery: { enabled: false } });
			console.log('creating a new gateway');
			const network = await gateway.getNetwork('mychannel');

			console.log('getting the channel');
			const channel = network.getChannel();
			result = await channel.queryBlock(parseInt(blockId));
			result = JSON.stringify(result);
			console.log('Transaction has been evaluated');
			
	    } catch (error) {
		console.error(`Failed to evaluate transaction: ${error}`);
	    }

        await ctx.render('blockInfo', {
            title, result
        })
    }

}

