fs = require('fs')
mkdirp = require('mkdirp')

exports.compileStylesheets = (done) ->
  startTime = Date.now()

  ###
    Input and output folders
  ###
  inputDirNameStyle = './client/style/'
  outputDirNameStyle = './client/public/stylesheets/'
  mkdirp(outputDirNameStyle)

  sass = require('node-sass')
  result = sass.renderSync(
    file: inputDirNameStyle + 'style.scss'
    outputStyle: 'compressed'
    outFile: outputDirNameStyle + 'style.css'
    sourceMap: DEVMODE
  )
  fs.writeFileSync(outputDirNameStyle + 'style.css', result.css)
  if DEVMODE
    fs.writeFileSync(outputDirNameStyle + 'style.css.map', result.map)

  logger.info("Client-side stylesheets ready, took #{(Date.now() - startTime) / 1000} seconds")
  return done()

exports.compileScripts = (done) ->
  startTime = Date.now()

  ###
    Input and output folders
  ###
  inputDirNameJS = './client/scripts/'
  outputDirNameJS = './client/public/javascript/'
  mkdirp(outputDirNameJS)

  Compiler = require('iced-coffee-script-3')
  coffeeFiles = fs.readdirSync(inputDirNameJS)
  if !fs.existsSync(outputDirNameJS)
    fs.mkdirSync(outputDirNameJS)
  fileContent = ''
  for file in coffeeFiles
    fileContent += fs.readFileSync(inputDirNameJS + file, 'utf-8') + '\n'
  fileContentJS = Compiler.compile(fileContent)
  fs.writeFileSync(outputDirNameJS + 'script.js', fileContentJS)

  if PRODMODE
    UglifyJS = require 'uglify-js'
    result = UglifyJS.minify(outputDirNameJS + 'script.js')
    fs.writeFileSync(outputDirNameJS + 'script.js', result.code)

  logger.info("Client-side javascript ready, took #{(Date.now() - startTime) / 1000} seconds")
  return done()
