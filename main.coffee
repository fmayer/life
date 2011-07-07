require(['life', 'utils/underscore', 'utils/jquery'],
(li) ->
  X = 30
  Y = 30
  life = new li.Life(new li.Field(X, Y))
  canvas = null
  alive = 0.2
  running = false
  interval = null

  $(document).ready(->
    canvas = document.getElementById("gol")
    ctx = canvas.getContext('2d')
    sq = _.min([canvas.height, canvas.width]) / _.max([life.field.ysize, life.field.xsize])
    drawGrid = ->
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
    drawGrid()

    animate = ->
      if running
        li.draw(life, canvas)

    $("#random").click(->
      newfield = life.Field(life.field.xsize, life.field.ysize)
      for x in [0...life.field.xsize]
        for y in [0...life.field.ysize]
          newfield.set(x, y) if Math.random() <= alive
      life.field = newfield
    )
    $("#pause").click(->
      running = false
      window.clearInterval(interval)
      $("#pause").attr('disabled','disabled')
      $("#resume").removeAttr('disabled')
    )
    $("#resume").click(->
      running = true
      interval = window.setInterval(animate, 500)
      $("#resume").attr('disabled','disabled')
      $("#pause").removeAttr('disabled')
    )
  )
)


