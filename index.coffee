
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

  copy: ->
    @_gatherInputFileStats =>
      @_calculateUpperLimits()


@Slowcopy = Slowcopy  
