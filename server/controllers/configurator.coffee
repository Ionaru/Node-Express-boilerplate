fs = require('fs')
ini = require('ini')

loadConfig = (configName, allowedMissing) ->
  try
    if process.env.TESTMODE
      ini.parse(fs.readFileSync("./config/#{configName}_test.ini", 'utf-8'))
    else
      ini.parse(fs.readFileSync("./config/#{configName}.ini", 'utf-8'))
  catch
    if allowedMissing
      logger.warn("#{configName}.ini not found in config folder root,
                   server might misbehave and some functions might be disabled.")
      return null
    else
      error = "#{configName}.ini not found in config folder root! Server cannot start."
      logger.error(error)
      throw error

###
  Load configuration from config files
###
global.mainConfig = loadConfig('config', false)
global.dbConfig = loadConfig('database', false)

###
  Set a few global constants (not really constants but close enough)
###
global.DEVMODE = process.env.ENV is 'DEV'
global.PRODMODE = process.env.ENV is 'PROD'

logger.info('Configuration loaded')
