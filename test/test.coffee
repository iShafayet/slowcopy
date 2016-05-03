
{ expect } = require('chai')

{ Slowcopy } = require './../index.coffee'

{ makeFileOfSizeInMBytes, makeFileOfSizeInMBytesUnlessFileExists, verifyTwoFilesAreTheSame } = require './lib/test-utils.coffee'

showProgressOnConsole = true

doSlowCopyAndVerify = (inputFilePath, outputFilePath, rate, cbfn)->

  sc = new Slowcopy inputFilePath, outputFilePath, rate

  if showProgressOnConsole

    startTimeStamp = (new Date).getTime()

    timeStamp = (new Date).getTime()

    console.log 'Time(s)\tInterval(s)\tSize(MBytes)\tRate(MB/s)'

    sc.on 'progress', (bytesReadSoFar)->

      round = (num)-> (Math.round (100*num))/100

      interval = ((new Date).getTime() - timeStamp)/1000

      timediff = ((new Date).getTime() - startTimeStamp)/1000

      rate = bytesReadSoFar / timediff

      timeStamp = (new Date).getTime()

      console.log (round timediff) + '\t' + (round interval) + '\t\t' + (round (bytesReadSoFar / 1024 / 1024)) + '\t\t' + (round (rate / 1024 / 1024))

  sc.on 'end', ->
    verifyTwoFilesAreTheSame inputFilePath, outputFilePath, (areTheySame)->
      expect(areTheySame).to.equal.true
      cbfn()

  sc.copy()

describe 'Slowcopy', ->

  it '30 mb file', (done)->

    @timeout 50000

    inputFilePath = './test/sample-files/dummy_autogenerated_1_30mb.file'

    outputFilePath = './test/sample-files/dummy_autogenerated_1_30mb_output.file'

    bytesPerSecond = (4 * 1024 * 1024)

    sizeInMBytes = 30

    makeFileOfSizeInMBytesUnlessFileExists inputFilePath, sizeInMBytes, ->

      doSlowCopyAndVerify inputFilePath, outputFilePath, bytesPerSecond, ->

        done()

  it '2 mb file', (done)->

    @timeout 50000

    inputFilePath = './test/sample-files/dummy_autogenerated_2_2mb.file'

    outputFilePath = './test/sample-files/dummy_autogenerated_2_2mb_output.file'

    bytesPerSecond = (1 * 1024 * 1024) / 10

    sizeInMBytes = 2

    makeFileOfSizeInMBytesUnlessFileExists inputFilePath, sizeInMBytes, ->

      doSlowCopyAndVerify inputFilePath, outputFilePath, bytesPerSecond, ->

        done()

  it '2 mb file @ 4mbps', (done)->

    @timeout 50000

    inputFilePath = './test/sample-files/dummy_autogenerated_2_2mb.file'

    outputFilePath = './test/sample-files/dummy_autogenerated_2_2mb_output.file'

    bytesPerSecond = (4 * 1024 * 1024)

    sizeInMBytes = 2

    makeFileOfSizeInMBytesUnlessFileExists inputFilePath, sizeInMBytes, ->

      doSlowCopyAndVerify inputFilePath, outputFilePath, bytesPerSecond, ->

        done()



