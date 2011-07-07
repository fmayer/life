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

define(['utils/underscore', 'utils/utils'],
(_, utils) ->
  neigh = [
    [0, 0], [0, 1], [0, -1], [1, 0], [1, 1],
    [1, -1], [-1, 0], [-1, 1], [-1, -1]
  ]

  class Field
    constructor: (@xsize, @ysize) ->
      @field = ((0 for i in ysize) for i in xsize)
    getOrElse: (x, y, def=null) ->
      if x < 0 or x >= @size or y < 0 or y >= @ysize
        def
      else
        @field[x][y]
    get: (x, y) -> @field[x][y]
    set: (x, y, v=1) -> @field[x][y] = v
    unset: (x, y) -> @set(x, y, 0)

  class Life
    constructor: (@field) ->
    neighbours: (x, y) ->
      utils.sum(
        @field.getOrElse(x + dx, y + dy, 0) for dx, dy in neigh
      )
    tick: ->
      newfield = new Field(@field.xsize, @field.ysize)
      for x in @field.xsize
        for y in @field.ysize
          if @field.get(x, y)
            n = @neighbours(x, y)
            if n == 2 or n == 3
              newfield.set(x, y)
          else if @neighbours(x, y) == 3
            newfield.set(x, y)
)