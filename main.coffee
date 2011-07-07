require(['life', 'utils/underscore', 'utils/jquery'],
(li) ->
  leftTop = (elem) ->
    x = 0
    y = 0
    while elem != null
      x += parseInt(elem.offsetLeft)
      y += parseInt(elem.offsetTop)
      elem = elem.offsetParent
    return [x, y]

  X = 30
  Y = 30
  life = new li.Life(new li.Field(X, Y))
  canvas = null
  alive = 0.2
  running = false
  interval = null
  brush = null

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
    $("#single").data([[0, 0], [1, 1]])
    $("#brush").change(->
      alert "Blub"
      brush = @val()
    )
    brush = $("#brush").val()
    if not brush?
      brush = [[0, 0]]

    canvas = document.getElementById("gol")
    ctx = canvas.getContext('2d')

    drawGrid = (ctx) ->
      ctx.lineWidth = 0.2
      sq = _.min([canvas.height, canvas.width]) / _.max([life.field.ysize, life.field.xsize])
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
    $(canvas).mousemove((evt) ->
      d = leftTop(@)
      x = evt.clientX - d[0]
      y = evt.clientY - d[1]
      sq = _.min([@height, @width]) / _.max([life.field.ysize, life.field.xsize])
      x = Math.floor(x / sq)
      y = Math.floor(y / sq)

      clearCanvas(ctx, canvas)
      li.draw(life, canvas)

      ctx.fillStroke = '#6D7B8D'
      for v in brush
        ctx.fillRect((v[0] + x) * sq, (v[1] + y) * sq, sq, sq)
      ctx.fillStroke = '#000'

      drawGrid(ctx)
    )
    $(canvas).click((evt) ->
      d = leftTop(@)
      x = evt.clientX - d[0]
      y = evt.clientY - d[1]
      sq = _.min([@height, @width]) / _.max([life.field.ysize, life.field.xsize])
      x = Math.floor(x / sq)
      y = Math.floor(y / sq)
      life.field.set(x, y, not life.field.get(x, y))
      clearCanvas(ctx, canvas)
      li.draw(life, canvas)
      drawGrid(ctx)
    )
  )
)


