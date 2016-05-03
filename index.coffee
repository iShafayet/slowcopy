
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

  _generateWriteStream: ->
    @writeStream = fslib.createWriteStream @outputFilePath

    @writeStream.on 'error', (err)=>
      @emit 'error', err

    @writeStream.on 'end', =>
      @emit 'write-end'

  _readExpectedBytesOrRemainingBytes: (bytesToRead, cbfn)->
    bytesLeftToRead = bytesToRead
    bytes = null

    readIfReadable = =>
      chunk = @readStream.read bytesLeftToRead
      chunk = @readStream.read() if chunk is null
      if chunk is null
        return cbfn bytes

      @writeStream.write chunk

      bytesLeftToRead -= chunk.length
      if bytes is null
        bytes = chunk
      else
        bytes = Buffer.concat [ bytes, chunk ]

      if bytesLeftToRead is 0
        return cbfn bytes
      else
        @readStream.once 'readable', => 
          readIfReadable()

    readIfReadable()

  _readingLoopStep: ->    
    bytesToRead = @bytesPerHundredMilisecond
    if @nonCarryReadCount is 9
      @nonCarryReadCount = 0
      bytesToRead += @carryBytes
    else
      @nonCarryReadCount += 1

    timeStampBeforeReading = (new Date).getTime()
    @_readExpectedBytesOrRemainingBytes bytesToRead, (bytes)=>
      if bytes is null
        'pass'
      else
        @bytesReadTotal += bytes.length
        if @nonCarryReadCount is 9
          @emit 'progress', @bytesReadTotal

        timeStampAfterReading = (new Date).getTime()
        timeDiff = timeStampAfterReading - timeStampBeforeReading
        timeToWait = (if timeDiff > 100 then 0 else (100 - timeDiff))
        
        fn = =>
          @_readingLoopStep()
        setTimeout fn, timeToWait

  copy: ->
    @_gatherInputFileStats =>
      @_calculateUpperLimits()

      @_generateReadStream()
      @_generateWriteStream()


@Slowcopy = Slowcopy  
