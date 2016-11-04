router = require('express').Router()

router.get '/', (req, res) ->
  return res.render('index', {
    username: req.session.user.username
  })

module.exports = router
