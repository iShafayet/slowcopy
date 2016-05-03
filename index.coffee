
fslib = require 'fs'

EventEmitter = require 'events'

class Slowcopy extends EventEmitter

  constructor: (@inputFilePath, @outputFilePath, @bytesPerSecond)->
    @bytesPerSecond = Math.floor @bytesPerSecond



@Slowcopy = Slowcopy  
