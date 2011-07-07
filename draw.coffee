define(['utils/underscore'],
(_) ->
  draw = (life, canvas) ->
    ctx = canvas.getContext('2d')
    sq = _.min([canvas.height, canvas.width]) / _.max([life.field.ysize, life.field.xsize])
    for x in [0...life.field.xsize]
      for y in [0...life.field.ysize]
        if life.field.get(x, y)
          ctx.fill(x * sq, y * sq, sq, sq)
