assert = require('assert')
request = require('supertest')
db = require('../../controllers/databaseConnector')
request = request('http://localhost:3001')

db_suffix = '_test'

# coffeelint: disable=no_implicit_returns

describe 'Prologue', ->

  describe 'First test, ensure Mocha is working.', ->

    it 'should complete this regular test', ->
      assert.ok(true)

    it 'should complete this test with a callback', (done) ->
      assert.ok(true)
      done()

    it 'should complete this test with a promise', ->
      new Promise (resolve) ->
        assert.ok(true)
        resolve()

  describe 'Start server', ->

    it 'should start the application', ->
      this.timeout(5000)
      process.env['TESTMODE'] = process.env['SILENT'] = true
      process.env['PORT'] = 3001
      process.env['ENV'] = 'DEV'
      require('../../bin/www')

describe 'Preparing the Database', ->

  describe 'Create connection to test database', ->

    it 'should be able to get the current db session', (done) ->
      assert.notEqual(db.get(), null)
      done()

    it "should be connected to a test database (ending with \"#{db_suffix}\")", (done) ->
      db.get().query 'SELECT DATABASE()', (err, rows) ->
        result = rows[0]['DATABASE()']
        assert.equal(err, null)
        re = new RegExp("#{db_suffix}$")
        assert.ok(re.test(result))
        if not re.test(result)
          process.exit(1)
        else
          done()

    it 'should be able to clear the \'sessions\' table in the test database', (done) ->
      await db.get().query('TRUNCATE TABLE `sessions`;', defer(err, rows))
      assert.equal(err, null)
      done()

# coffeelint: enable=no_implicit_returns