const router = require('koa-router')()
const IndexController = require('./../controllers/index')
const VoteController = require('./../controllers/vote')
const QueryController = require('./../controllers/query')

router.get('/',IndexController.indexPage)
	.get('/votePage',VoteController.initPage)
	.get('/queryPage',QueryController.initPage)
	.post('/voteUser', IndexController.voteUser)
	.get('/getUserVote',IndexController.getUserVote)
	.get('/getUserVoteById',IndexController.getUserVoteById)

module.exports = router
