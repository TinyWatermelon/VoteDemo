const router = require('koa-router')()
const IndexController = require('./../controllers/index')

router.get('/',IndexController.indexPage)
        .get('/voteUser', IndexController.voteUser)
        .get('/getUserVote',IndexController.getUserVote)
        .get('/getUserVoteById',IndexController.getUserVoteById)

module.exports = router
