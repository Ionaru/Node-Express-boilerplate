express = require('express')
app = module.exports = express()

###
  Setup Handlebars view engine
###
hbs = require('hbs')
path = require('path')
hbsHelpers = require('./controllers/hbsHelpers')
app.set('views', path.join(__dirname, '../client/views'))
app.set('view engine', 'hbs')
hbsHelpers.registerHelpers(hbs)
hbs.registerPartials(path.join(__dirname, '../client/views/partials'))
logger.info('View engine registered')

###
  Create connection to MySQL Database
###
db = require('./controllers/databaseConnector')
await db.connect (defer(err))
if err
  throw err
else
  logger.info("Connected to '#{dbConfig['db_name']}' MySQL database")

###
  Setup session storage, use the previously created connection pool to the MySQL Database
###
session = require('express-session')
MySQLStore = require('express-mysql-session')(session)
sessionOptions = {
  expiration: 30 * 24 * 60 * 60 * 1000, # 30 days,
  checkExpirationInterval: 15 * 60 * 1000, # 15 minutes
}

global.sessionStore = new MySQLStore(sessionOptions, db.get())
app.use session({
  key: mainConfig['session_key'],
  secret: mainConfig['session_secret'],
  store: sessionStore,
  resave: true,
  saveUninitialized: true
})
logger.info("MySQL session storage connected to '#{dbConfig['db_name']}'")

###
  Add the favicon
###
favicon = require('serve-favicon')
app.use favicon(path.join(__dirname, '../client/public/', 'favicon.png'))

###
  Setup bodyparser
###
bodyParser = require('body-parser')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)

###
  Setup public folders containing stylesheets, images, scripts, etc...
###
app.use express.static(path.join(__dirname, '../client/public'))
if DEVMODE
  app.use express.static(path.join(__dirname, '../client'))

###
  All requests should go through the global router first, this way we can keep track of sessions and permissions
  as well as doing things like login, logout and register through a POST or PUT on any page
###
app.all '/*', require('./routes/global')

###
  Register the rest of the routes the application should use
###
app.use '/', require('./routes/index')

###
  Register a 404 error page
###
app.use (req, res) ->
  res.status(404)
  res.render('status/404')
  return

###
  Register the error handler, only send the stacktrace to the client when the app is in DEV mode
###
app.use (err, req, res) ->
  res.status(err.status or 500)
  res.render('status/error',
    message: err.message
    error: if DEVMODE then err else {}
  )
  return

logger.info('Routes registered')