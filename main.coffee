# Copyright (C) 2011 by Florian Mayer <florian.mayer@bitsrc.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require(['life', 'utils/utils', 'utils/base64', 'utils/underscore', 'utils/jquery', 'utils/json2'],
(li, utils, b64) ->
  leftTop = (elem) ->
    x = 0
    y = 0
    while elem != null
      x += parseInt(elem.offsetLeft)
      y += parseInt(elem.offsetTop)
      elem = elem.offsetParent
    return [x, y]

  class Game
    constructor: (@canvas, @life, @brush, @gap) ->
      if not life?
        @life = new li.Life(new li.Field(30, 30))
      if not brush?
        @brush = [[0, 0]]
      if not gap?
        @gap = 0.5
      @ctx = canvas.getContext('2d')
      @down = null

      $(canvas).mousedown((evt) => @down = @getMousePos(evt))
      $(canvas).mouseup((evt) =>
        pos = @getMousePos(evt)
        if _.isEqual(@down, pos)
          [x, y] = pos
          @life.field.set(x, y, not @life.field.get(x, y))
          @redrawAll()
        @down = null
      )

      $(canvas).mousemove((evt) =>
        sq = @getBox()
        [x, y] = @getMousePos(evt)
        if @down != null
          @life.field.set(x, y)

        @clearCanvas()
        @drawLife()

        if @down == null
          @ctx.fillStroke = '#6D7B8D'
          for v in @brush
            @ctx.fillRect((v[0] + x) * sq, (v[1] + y) * sq, sq, sq)
          @ctx.fillStroke = '#000'

        @drawGrid()
      )

      $(canvas).mouseleave((evt) =>
        @redrawAll()
        @down = null
      )

    getMousePos: (evt) ->
      d = leftTop(@canvas)
      x = evt.pageX - d[0]
      y = evt.pageY - d[1]
      sq = @getBox()
      x = Math.floor(x / sq)
      y = Math.floor(y / sq)
      return [x, y]

    drawGrid: () ->
      @ctx.lineWidth = 0.2
      sq = @getBox()
      for i in [0..@life.field.xsize]
        @ctx.beginPath()
        @ctx.moveTo(i * sq, 0)
        @ctx.lineTo(i * sq, @life.field.xsize * sq)
        @ctx.stroke()

      for i in [0..@life.field.ysize]
        @ctx.beginPath()
        @ctx.moveTo(0, i * sq)
        @ctx.lineTo(@life.field.ysize * sq, i * sq)
        @ctx.stroke()

    getBox: () -> utils.min(@canvas.height, @canvas.width) / utils.max(@life.field.ysize, @life.field.xsize)

    drawLife: () ->
      sq = @getBox()
      for x in [0...@life.field.xsize]
        for y in [0...@life.field.ysize]
          if @life.field.get(x, y)
            @ctx.fillRect(x * sq + @gap, y * sq + @gap, sq - @gap, sq - @gap)

    drawAll: () ->
      @drawGrid()
      @drawLife()

    redrawAll: () ->
      @clearCanvas()
      @drawAll()

    clearCanvas: () ->
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      w = @canvas.width
      @canvas.width = 1
      @canvas.width = w


  class Scheduler
    constructor: (@interval, @tick) -> @intervalno = null
    start: -> @intervalno = window.setInterval(
      => @doTick(),
      @interval)
    doTick: -> if @intervalno != null then @tick()
    stop: ->
      window.clearInterval(@intervalno)
      @intervalno = null
    toggle: ->
      if @intervalno != null then @stop() else @start()
    running: -> @intervalno != null
    setInterval: (i) ->
      @interval = i
      if @intervalno != null
        @stop()
        @start()


  $(document).ready(->
    game = new Game(document.getElementById('gol'))
    sched = new Scheduler(500, =>
      game.life.tick()
      game.redrawAll()
    )

    if document.location.hash
      for v in JSON.parse(b64.decode(document.location.hash[1...]))
        game.life.field.set(v[0], v[1])
    game.drawAll()

    $("#toggle").click(->
      $("#toggle").attr('value', if sched.running() then 'Play' else 'Pause')
      sched.toggle()
    )
    $("#clear").click(->
      for x in [0...game.life.field.xsize]
        for y in [0...game.life.field.ysize]
          game.life.field.unset(x, y)
      game.redrawAll()
    )
    $("#freq").change(->
      sched.setInterval(1000 / parseFloat($(@).val()))
    )
    $("#perma").click((e) ->
      e.preventDefault()
      l = window.location
      $("#permap").val(
        l.protocol + '//' + l.host + l.pathname + l.search + "#" + b64.encode(JSON.stringify(game.life.field.getSet())).replace('\n', '')
      )
    )
  )
)
