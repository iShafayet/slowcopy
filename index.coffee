
fslib = require 'fs'

EventEmitter = require 'events'

class Slowcopy extends EventEmitter

  constructor: (@inputFilePath, @outputFilePath, @bytesPerSecond)->
    @bytesPerSecond = Math.floor @bytesPerSecond

  _gatherInputFileStats: (cbfn)->
    fslib.stat @inputFilePath, (err, stats)=>
      return @emit err if err
      @totalFileSizeInBytes = stats.size
      return cbfn()

  _calculateUpperLimits: ->
    @bytesPerHundredMilisecond = Math.floor (@bytesPerSecond / 10)
    @carryBytes = @bytesPerSecond - (10 * @bytesPerHundredMilisecond)

  _generateReadStream: ->
    @readStream = fslib.createReadStream @inputFilePath

    @readStream.on 'error', (err)=>
      @emit 'error', err

    @readStream.on 'end', =>
      @writeStream.end()
      @emit 'end'

  copy: ->
    @_gatherInputFileStats =>
      @_calculateUpperLimits()

      @_generateReadStream()


@Slowcopy = Slowcopy  
