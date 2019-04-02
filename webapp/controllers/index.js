const { FileSystemWallet, Gateway } = require('fabric-network');
const fs = require('fs');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..','..', 'network', 'connection.json');
const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
const ccp = JSON.parse(ccpJSON);

module.exports = {

    async indexPage ( ctx ) {
        const title = 'demo page'
        let result = ''
		try {

			// Create a new file system based wallet for managing identities.
			const walletPath = path.join(process.cwd(), 'wallet');
			const wallet = new FileSystemWallet(walletPath);
			console.log(`Wallet path: ${walletPath}`);

			// Check to see if we've already enrolled the user.
			const userExists = await wallet.exists('louis');
			if (!userExists) {
				console.log('An identity for the user "user1" does not exist in the wallet');
				console.log('Run the registerUser.js application before retrying');
				return;
			}

			// Create a new gateway for connecting to our peer node.
			const gateway = new Gateway();
			await gateway.connect(ccp, { wallet, identity: 'louis', discovery: { enabled: false } });
			console.log('creating a new gateway');
			// Get the network (channel) our contract is deployed to.
			const network = await gateway.getNetwork('mychannel');

			console.log('getting the contract');
			// Get the contract from the network.
			const contract = network.getContract('mycc');
			// Evaluate the specified transaction.
			// queryCar transaction - requires 1 argument, ex: ('queryCar', 'CAR4')
			// queryAllCars transaction - requires no arguments, ex: ('queryAllCars')
			result = await contract.evaluateTransaction('getUserVote');
			console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

		} catch (error) {
			console.error(`Failed to evaluate transaction: ${error}`);
		}
        

        await ctx.render('index', {
            title, result
        })
    },
	
	async getUserVote ( ctx ) {
        let result = ''
		try {

			const walletPath = path.join(process.cwd(), 'wallet');
			const wallet = new FileSystemWallet(walletPath);
			console.log(`Wallet path: ${walletPath}`);

			const userExists = await wallet.exists('louis');
			if (!userExists) {
				console.log('An identity for the user "user1" does not exist in the wallet');
				console.log('Run the registerUser.js application before retrying');
				return;
			}

			const gateway = new Gateway();
			await gateway.connect(ccp, { wallet, identity: 'louis', discovery: { enabled: false } });
			console.log('creating a new gateway');
			const network = await gateway.getNetwork('mychannel');

			console.log('getting the contract');
			const contract = network.getContract('mycc');
			result = await contract.evaluateTransaction('getUserVote');
			console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

	    } catch (error) {
		console.error(`Failed to evaluate transaction: ${error}`);
	    }

        await ctx.render('index', {
            result
        })
    },
	async getUserVoteById ( ctx ) {
		const queryBody = ctx.request.query;
        const username = queryBody.username;
        let result = ''
		try {

			const walletPath = path.join(process.cwd(), 'wallet');
			const wallet = new FileSystemWallet(walletPath);
			console.log(`Wallet path: ${walletPath}`);

			const userExists = await wallet.exists('louis');
			if (!userExists) {
				console.log('An identity for the user "user1" does not exist in the wallet');
				console.log('Run the registerUser.js application before retrying');
				return;
			}

			const gateway = new Gateway();
			await gateway.connect(ccp, { wallet, identity: 'louis', discovery: { enabled: false } });
			console.log('creating a new gateway');
			const network = await gateway.getNetwork('mychannel');

			console.log('getting the contract');
			const contract = network.getContract('mycc');
			result = await contract.evaluateTransaction('getUserVoteById',username);
			console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

	    } catch (error) {
		console.error(`Failed to evaluate transaction: ${error}`);
	    }

        await ctx.render('index', {
            result
        })
    },

    async voteUser (ctx) {
        const queryBody = ctx.request.query;
        const username = queryBody.username;
        console.log(`username.....${username}`)
	
		try {
			const walletPath = path.join(process.cwd(), 'wallet');
			const wallet = new FileSystemWallet(walletPath);
			console.log(`Wallet path: ${walletPath}`);

			const userExists = await wallet.exists('louis');
			if (!userExists) {
				console.log('An identity for the user "user1" does not exist in the wallet');
				console.log('Run the registerUser.js application before retrying');
				return;
			}

			const gateway = new Gateway();
			await gateway.connect(ccp, { wallet, identity: 'louis', discovery: { enabled: false } });

			const network = await gateway.getNetwork('mychannel');

			const contract = network.getContract('mycc');

			result = await contract.submitTransaction('voteUser', username);
			console.log('Transaction has been submitted');

			await gateway.disconnect();

    	} catch (error) {
        	console.error(`Failed to submit transaction: ${error}`);
    	}
		
        await ctx.render('index', {
            result
        })
    }

}