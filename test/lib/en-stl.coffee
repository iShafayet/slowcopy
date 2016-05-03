###
  this file should go into evolvenode
###

class Collectible

  constructor: (@totalToCollect, @finallyFn = null)->
    @count = 0
    @collection = {}

  done: (key, value)->
    unless @totalToCollect is @count
      @collection[key] = value
      @count += 1

    if @totalToCollect is @count
      setImmediate @finallyFn, @collection if @finallyFn
      finallyFn = null

  finally: (@finallyFn)-> @

@Collectible = Collectible


###
  @class Iterator
  @purpose Asynchronous iterator for a list with flow control.
###

class Iterator

  constructor: (@list, @forEachFn)->
    @index = 0
    @hasIterationEnded = false
    @next()

  next: ()=>
    if @index == @list.length
      @hasIterationEnded = true
      if @finalFn and @hasIterationEnded
        cb = @finalFn
        @finalFn = null
        cb()
    else
      oldIndex = @index
      @index++
      @forEachFn @next, oldIndex, @list[oldIndex]

  then: (@finalFn)=>
    if @finalFn and @hasIterationEnded
      cb = @finalFn
      @finalFn = null
      cb()

@Iterator = Iterator

###
  @iterate
###

iterate = (list, forEachFn) ->
  new Iterator list, forEachFn

@iterate = iterate
