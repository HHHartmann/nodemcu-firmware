require 'mispec'

local buffer, buffer1, buffer2

local function initBuffer(buffer, ...)
  local i,v
  for i,v in ipairs({...}) do
    buffer:set(i, v, v*2, v*3, v*4)
  end
  return buffer
end

describe('pixbuf tests part 2', function(it)

    it:should('shift LOGICAL', function()

        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,7,8)
        ok(buffer1 ~= buffer2, "disequality pre shift")
        buffer1:shift(2)
        ok(buffer1 == buffer2, "shift right")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,0,0)
        buffer1:shift(-2)
        ok(buffer1 == buffer2, "shift left")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,0,8,12)
        buffer1:shift(1, nil, 2,3)
        ok(buffer1 == buffer2, "shift middle right")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,0,12)
        buffer1:shift(-1, nil, 2,3)
        ok(buffer1 == buffer2, "shift middle left")

        -- bounds checks, handle gracefully as string:sub does
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,8,9,12,0)
        buffer1:shift(-1, pixbuf.SHIFT_LOGICAL, 0,5)
        ok(buffer1 == buffer2, "shift left out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,7,8,9)
        buffer1:shift(1, pixbuf.SHIFT_LOGICAL, 0,5)
        ok(buffer1 == buffer2, "shift right out of bound")

    end)

    it:should('shift LOGICAL issue #2946', function()
        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,0,0)
        buffer1:shift(4)
        ok(buffer1 == buffer2, "shift all right")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,0,0)
        buffer1:shift(-4)
        ok(buffer1 == buffer2, "shift all left")

        failwith("shifting more elements than buffer size", function() buffer1:shift(10) end)
        failwith("shifting more elements than buffer size", function() buffer1:shift(-6) end)
    end)

    it:should('shift CIRCULAR', function()
        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,7,8)
        buffer1:shift(2, pixbuf.SHIFT_CIRCULAR)
        ok(buffer1 == buffer2, "shift right")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,7,8)
        buffer1:shift(-2, pixbuf.SHIFT_CIRCULAR)
        ok(buffer1 == buffer2, "shift left")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,8,12)
        buffer1:shift(1, pixbuf.SHIFT_CIRCULAR, 2,3)
        ok(buffer1 == buffer2, "shift middle right")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,8,12)
        buffer1:shift(-1, pixbuf.SHIFT_CIRCULAR, 2,3)
        ok(buffer1 == buffer2, "shift middle left")

        -- bounds checks, handle gracefully as string:sub does
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,8,9,12,7)
        buffer1:shift(-1, pixbuf.SHIFT_CIRCULAR, 0,5)
        ok(buffer1 == buffer2, "shift left out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,12,7,8,9)
        buffer1:shift(1, pixbuf.SHIFT_CIRCULAR, 0,5)
        ok(buffer1 == buffer2, "shift right out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,12,7,8,9)
        buffer1:shift(1, pixbuf.SHIFT_CIRCULAR, -12,12)
        ok(buffer1 == buffer2, "shift right way out of bound")

    end)

    it:should('sub', function()
        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        initBuffer(buffer1,7,8,9,12)
        buffer1 = buffer1:sub(4,3)
        ok(eq(buffer1:size(), 0), "sub empty")

        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(2, pixbuf.TYPE_RGBW)
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12)
        buffer1 = buffer1:sub(3,4)
        ok(buffer1 == buffer2, "sub")

        buffer1 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        buffer2 = pixbuf.newBuffer(4, pixbuf.TYPE_RGBW)
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,8,9,12)
        buffer1 = buffer1:sub(-12,33)
        ok(buffer1 == buffer2, "out of bounds")
    end)




--[[
pixbuf.buffer:__concat()
--]]

end)

mispec.run()
