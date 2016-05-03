
commander = require 'commander'
fslib = require 'fs'
pathlib = require 'path'

{ Slowcopy } = require './index'

writeInfo = (msg)->
  console.log msg

writeError = (msg, exitCode)->
  console.log 'Error: ' + msg
  process.exit exitCode

## Options

commander.version '0.0.1'

commander.arguments '<source> <destination> <speed-limit>'

commander.description 'A command line utility to copy a file at a limited speed.'

commander.option '-f, --force', 'Force over-write if destination already exists'

commander.option '-q, --quiet', 'No non-error output'

## Process Options

commander.parse process.argv

forceOption = commander.force or false

quietOption = commander.quiet or false

## Arguments

if commander.args.length < 3
  writeError 'Insufficient Argument(s)', 1

[ source, destination, speedString ] = commander.args

source = pathlib.normalize source
destination = pathlib.normalize destination

## Same file check
if source is destination
  writeError 'source can not be same as destination', 2

## Process 'source'
try
  stats = fslib.statSync source
catch ex
  if ex.code is 'ENOENT'
    writeError "No such file '#{source}'.", 3
  else
    throw ex
unless stats.isFile()
  writeError "'#{source}' is not a file.", 4

## Process 'destination'
try
  stats = fslib.statSync destination
  unless forceOption
    writeError "File already exists '#{destination}'. Use --force option to enable over-write", 5
catch ex
  if ex.code is 'ENOENT'
    'pass'
  else
    throw ex

## Process speedString
speed = parseInt speedString, 10
modifier = speedString.replace (''+speed), ''
unless (modifier in ['', 'B/s', 'KB/s', 'MB/s' ]) or speed <= 0 or speed is NaN
  writeError "speed needs to be in one of these formats. 'x' or 'xB/s' or 'xKB/s' or 'xMB/s'. Where x indicates any integer" 
if modifier is 'MB/s'
  speed = speed * 1024 * 1024
else if modifier is 'KB/s'
  speed = speed * 1024

## Execute

startTimeStamp = (new Date).getTime()

sc = new Slowcopy source, destination, speed

outputUpdate = (bytesReadSoFar)->

    round = (num)-> (Math.round (100*num))/100

    timediff = ((new Date).getTime() - startTimeStamp)/1000

    interval = (Math.round (bytesReadSoFar / sc.totalFileSizeInBytes) * 100 )

    rate = bytesReadSoFar / timediff

    console.log (round timediff) + '\t' + (interval) + '%\t\t' + (round (bytesReadSoFar / 1024 / 1024)) + '\t\t' + (round (rate / 1024 / 1024))

unless quietOption

  console.log 'Time(s)\tPercentage\tSize(MBytes)\tRate(MB/s)'

  sc.on 'progress', (bytesReadSoFar)-> 
    outputUpdate bytesReadSoFar

sc.on 'end', ->

  unless quietOption

    outputUpdate sc.totalFileSizeInBytes

    timediff = ((new Date).getTime() - startTimeStamp)/1000

    console.log 'File copying completed in ' + timediff + ' seconds.'

sc.copy()


