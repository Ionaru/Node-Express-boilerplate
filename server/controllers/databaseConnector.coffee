fs = require('fs')
mysql = require('mysql')

state = {
  pool: null
  mode: null
}

exports.connect = (done) ->
  # Only use SSL if the 3 SSL fields in the config are filled
  if dbConfig['db_ca_f'] and dbConfig['db_cc_f'] and dbConfig['db_ck_f']
    dbOptions = {
      host: dbConfig['db_host']
      port: dbConfig['db_port'] or 3306
      user: dbConfig['db_user']
      password: dbConfig['db_pass']
      database: dbConfig['db_name']
      ssl:
        ca: fs.readFileSync('./config/' + dbConfig['db_ca_f'])
        cert: fs.readFileSync('./config/' + dbConfig['db_cc_f'])
        key: fs.readFileSync('./config/' + dbConfig['db_ck_f'])
        rejectUnauthorized: dbConfig['db_reject']
    }
    if not dbConfig['db_reject']
      logger.warn("SSL connection to Database is not secure, 'db_reject' should be 'true'")
  else
    dbOptions = {
      host: dbConfig['db_host']
      port: dbConfig['db_port'] or 3306
      user: dbConfig['db_user']
      password: dbConfig['db_pass']
      database: dbConfig['db_name']
    }
    if dbConfig['db_host'] not in ['localhost', '0.0.0.0', '127.0.0.1']
      logger.warn('Unsecured connection to external Database, this is unadvised')
  state.pool = mysql.createPool(dbOptions)
  return done()

exports.get = ->
  return state.pool
