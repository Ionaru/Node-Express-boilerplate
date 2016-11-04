###
  Small helper function so we can get a proper timestamp on our logs
###
getLogTimeStamp = ->
  now = new Date
  year = now.getFullYear()
  month = ('0' + (now.getMonth() + 1)).slice(-2)
  day = ('0' + now.getDate()).slice(-2)
  hour = ('0' + now.getHours()).slice(-2)
  minute = ('0' + now.getMinutes()).slice(-2)
  second = ('0' + now.getSeconds()).slice(-2)
  date = [year, month, day].join('-')
  time = [hour, minute, second].join(':')
  return [date, time].join(' ')

###
  Define locations of the log directories
###
logDirs =
  debug: './logs/debug/'
  info: './logs/info/'
  warn: './logs/warning/'
  error: './logs/error/'

###
  Define the place the log files should go, and the file suffix
###
debugFilePath = logDirs.debug + '_plain.txt'
logFilePath = logDirs.info + '_plain.txt'
warnFilePath = logDirs.warn + '_plain.txt'
errFilePath = logDirs.error + '_plain.txt'
debugFileJSONPath = logDirs.debug + '_json.txt'
logFileJSONPath = logDirs.info + '_json.txt'
warnFileJSONPath = logDirs.warn + '_json.txt'
errFileJSONPath = logDirs.error + '_json.txt'

###
  Create log directories if they don't exist
###
mkdirp = require('mkdirp')
for name, logDir of logDirs
  mkdirp(logDir)

###
  Set normal console log level, increase to 'debug' when application is in DEV mode
###
consoleLogLevel = 'info'
# Can't use 'DEVMODE' constant because configuration isn't loaded yet
if process.env.ENV is 'DEV'
  consoleLogLevel = 'debug'

###
  Define all the different log transports
###
winston = require 'winston'
consoleLog = new (winston.transports.Console)({
  level: consoleLogLevel
  timestamp: ->
    return getLogTimeStamp()
  colorize: true
})

fileDebug = new (require('winston-daily-rotate-file'))({
  name: 'file#Debug'
  datePattern: 'log_yyyy-MM-dd'
  level: 'debug'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: debugFilePath
  json: false
})

fileLog = new (require('winston-daily-rotate-file'))({
  name: 'file#log'
  datePattern: 'log_yyyy-MM-dd'
  level: 'debug'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: logFilePath
  json: false
})

fileWarn = new (require('winston-daily-rotate-file'))({
  name: 'file#warn'
  datePattern: 'log_yyyy-MM-dd'
  level: 'warn'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: warnFilePath
  json: false
})

fileError = new (require('winston-daily-rotate-file'))({
  name: 'file#error'
  datePattern: 'log_yyyy-MM-dd'
  level: 'error'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: errFilePath
  json: false
})

JsonDebug = new (require('winston-daily-rotate-file'))({
  name: 'file#JsonDebug'
  datePattern: 'log_yyyy-MM-dd'
  level: 'debug'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: debugFileJSONPath
})

JsonLog = new (require('winston-daily-rotate-file'))({
  name: 'file#JsonLog'
  datePattern: 'log_yyyy-MM-dd'
  level: 'info'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: logFileJSONPath
})

JsonWarn = new (require('winston-daily-rotate-file'))({
  name: 'file#JsonWarn'
  datePattern: 'log_yyyy-MM-dd'
  level: 'warn'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: warnFileJSONPath
})

JsonError = new (require('winston-daily-rotate-file'))({
  name: 'file#JsonError'
  datePattern: 'log_yyyy-MM-dd'
  level: 'error'
  prepend: true
  timestamp: ->
    return getLogTimeStamp()
  filename: errFileJSONPath
})

transports = []
if not process.env.SILENT
  transports = [
    consoleLog
    fileDebug, fileLog, fileWarn, fileError
    JsonDebug, JsonLog, JsonWarn, JsonError
  ]
###
  Finally set the logger as a global so we can use it anywhere
###
global.logger = new (winston.Logger)(transports: transports)
logger.info('Logger enabled')