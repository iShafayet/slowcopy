
fs = require 'fs'

{ iterate } = require './en-stl.coffee'

@makeFileOfSizeInMBytes = (inputFilePath, sizeInMBytes, cbfn)->

  stream = fs.createWriteStream inputFilePath

  oneKByteString = ('x' for _ in [0...1024]).join ''

  oneMByteString = (oneKByteString for _ in [0...1024]).join ''

  iterate [0...sizeInMBytes], (next)->
    stream.write oneMByteString
    next()
  .then ->
    stream.end()    

  stream.on 'finish', =>
    cbfn()

hashFiles = require 'hash-files'

@verifyTwoFilesAreTheSame = (file1, file2, cbfn)->

  options = {
    algorithm: 'sha1'
    noGlob: true
  }

  options.files = [ file1 ]
  hashFiles options, (err, hash1)->
    throw err if err

    options.files = [ file2 ]
    hashFiles options, (err, hash2)->
      throw err if err

      return hash1 is hash2


