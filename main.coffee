require(['life', 'utils/underscore', 'utils/jquery'],
(li) ->
  X = 30
  Y = 30
  life = new li.Life(new li.Field(X, Y))
  canvas = null
  alive = 0.2
  running = false
  interval = null

  # DEBUG
  os = 5
  life.field.set(os + 1, os + 0)
  life.field.set(os + 2, os + 1)
  life.field.set(os + 0, os + 2)
  life.field.set(os + 1, os + 2)
  life.field.set(os + 2, os + 2)


  clearCanvas = (ctx, cv) ->
    ctx.clearRect(0, 0, cv.width, cv.height)
    w = cv.width
    cv.width = 1
    cv.width = w

  $(document).ready(->
    canvas = document.getElementById("gol")
    ctx = canvas.getContext('2d')
    sq = _.min([canvas.height, canvas.width]) / _.max([life.field.ysize, life.field.xsize])
    drawGrid = (ctx) ->
      for i in [0..life.field.xsize]
        ctx.beginPath()
        ctx.moveTo(i * sq, 0)
        ctx.lineTo(i * sq, life.field.xsize * sq)
        ctx.stroke()

      for i in [0..life.field.ysize]
        ctx.beginPath()
        ctx.moveTo(0, i * sq)
        ctx.lineTo(life.field.ysize * sq, i * sq)
        ctx.stroke()
    drawGrid(ctx)
    li.draw(life, canvas)

    animate = ->
      if running
        clearCanvas(ctx, canvas)
        life.tick()
        li.draw(life, canvas)
        drawGrid(ctx)

    $("#random").click(->
      newfield = life.Field(life.field.xsize, life.field.ysize)
      for x in [0...life.field.xsize]
        for y in [0...life.field.ysize]
          newfield.set(x, y) if Math.random() <= alive
      life.field = newfield
    )
    $("#toggle").click(->
      if running
        running = false
        window.clearInterval(interval)
        $("#toggle").attr('value','Play')
      else
        running = true
        interval = window.setInterval(animate, 500)
        $("#toggle").attr('value','Pause')
    )
  )
)


