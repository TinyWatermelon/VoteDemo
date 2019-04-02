const router = require('koa-router')()
const IndexController = require('./../controllers/index')

router.get('/',IndexController.indexPage)
    .get('/voteUserUser', IndexController.voteUser)
	.get('/getUserVote',IndexController.getUserVote)

module.exports = router