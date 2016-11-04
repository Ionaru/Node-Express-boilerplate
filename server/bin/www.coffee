require('../controllers/logger')

require('../controllers/configurator')

if DEVMODE
  logger.warn('Application is running in DEV mode!')

###
  Prepare stylesheets and scripts for client use
###
compiler = require('../controllers/compiler')
await compiler.compileStylesheets(defer())
await compiler.compileScripts(defer())

###
  Init application
###
logger.info('Starting application setup')
app = require('../app')
app.enable('trust proxy')
logger.info('Finished application setup')

###
  Get port from environment and store in Express.
###
port = process.env.PORT or '3000'
app.set('port', port)

###
  Event listener for HTTP server "error" event.
###
onError = (error) ->
  if error.syscall != 'listen'
    throw error
  bind = if typeof port == 'string' then 'Pipe ' + port else 'Port ' + port
  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      logger.error(bind + ' requires elevated privileges')
      process.exit(1)
    when 'EADDRINUSE'
      logger.error(bind + ' is already in use')
      process.exit(1)
    else
      throw error
  return

###
  Create HTTP server.
###
logger.info('Starting HTTP server')
http = require('http')
server = http.createServer(app)

###
 Event listener for HTTP server "listening" event.
###
onListening = ->
  addr = server.address()
  bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
  logger.info("HTTP server listening on #{bind}, ready for requests")
  return

###
  Listen on provided port, on all network interfaces.
###
server.listen(port)
server.on('error', onError)
server.on('listening', onListening)

###
  Exit handler for when the application quits
###
exitHandler = (options, err) ->
  if options.cleanup
    logger.warn('Got shutdown command, executing shutdown tasks.')
    cleanup = (done) ->
      db = require('../controllers/databaseConnector')
      db.get().end (err) ->
        if err
          logger.error('Error while closing Database connection!')
          throw err
        else
        logger.info('Database connection closed')
        sessionStore.close()
        logger.info('Session store closed')
        return done()
      return
    await cleanup(defer())
  if err
    logger.error(err.stack)
  logger.warn('Shutdown complete, goodbye!')
  return process.exit(0)

###
  When the application gets a shutdown signal, continue running and execute exit handler
###
process.stdin.resume()
#catches ctrl+c / stop event
process.on('SIGINT', exitHandler.bind(null, cleanup: true))
#catches uncaught exceptions
process.on('uncaughtException', exitHandler.bind(null, cleanup: true))
