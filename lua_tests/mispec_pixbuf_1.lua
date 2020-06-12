require 'mispec'

local buffer, buffer1, buffer2

local function initBuffer(buffer, ...)
  local i,v
  for i,v in ipairs({...}) do
    buffer:set(i, v, v*2, v*3, v*4)
  end
  return buffer
end

describe('pixbuf tests part 1', function(it)

    it:should('initialize a buffer', function()
        buffer = pixbuf.newBuffer(9, pixbuf.TYPE_GRB)
        ko(buffer == nil)
        ok(eq(buffer:size(), 9), "check size")
        ok(eq(buffer:dump(), string.char(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)), "initialize with 0")

        failwith("must be a valid pixbuf type", pixbuf.newBuffer, 9, -1)
        failwith("should be a positive integer", pixbuf.newBuffer, 0, pixbuf.TYPE_GRB)
        failwith("should be a positive integer", pixbuf.newBuffer, -1, pixbuf.TYPE_GRB)
    end)

    it:should('have correct size', function()
        buffer = pixbuf.newBuffer(9, pixbuf.TYPE_GRB)
        ok(eq(buffer:size(), 9), "check size")
        buffer = pixbuf.newBuffer(9, pixbuf.TYPE_RGBW)
        ok(eq(buffer:size(), 9), "check size")
        buffer = pixbuf.newBuffer(13, pixbuf.TYPE_IBGR)
        ok(eq(buffer:size(), 13), "check size")
    end)

    it:should('fill a buffer with one color', function()
        buffer = pixbuf.newBuffer(3, pixbuf.TYPE_GRB)
        buffer:fill(1,222,55)
        ok(eq(buffer:dump(), string.char(1,222,55,1,222,55,1,222,55)), "RGB")
        buffer = pixbuf.newBuffer(3, pixbuf.TYPE_GRBW)
        buffer:fill(1,222,55, 77)
        ok(eq(buffer:dump(), string.char(1,222,55,77,1,222,55,77,1,222,55,77)), "RGBW")
    end)

    it:should('replace correctly', function()
        buffer = pixbuf.newBuffer(5, pixbuf.TYPE_GRB)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255))
        ok(eq(buffer:dump(), string.char(3,255,165,33,0,244,12,87,255,0,0,0,0,0,0)), "RGBW")

        buffer = pixbuf.newBuffer(5, pixbuf.TYPE_GRB)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255), 2)
        ok(eq(buffer:dump(), string.char(0,0,0,3,255,165,33,0,244,12,87,255,0,0,0)), "RGBW")

        buffer = pixbuf.newBuffer(5, pixbuf.TYPE_GRB)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255), -5)
        ok(eq(buffer:dump(), string.char(3,255,165,33,0,244,12,87,255,0,0,0,0,0,0)), "RGBW")

        failwith("does not fit into destination", function() buffer:replace(string.char(3,255,165,33,0,244,12,87,255), 4) end)
    end)

    it:should('replace correctly issue #2921', function()
        local buffer = pixbuf.newBuffer(5, pixbuf.TYPE_GRB)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255), -7)
        ok(eq(buffer:dump(), string.char(3,255,165,33,0,244,12,87,255,0,0,0,0,0,0)), "RGBW")
    end)

    it:should('get/set correctly', function()
        buffer = pixbuf.newBuffer(3, pixbuf.TYPE_GRBW)
        buffer:fill(1,222,55,13)
        ok(eq({buffer:get(2)},{1,222,55,13}))
        buffer:set(2, 4,53,99,0)
        ok(eq({buffer:get(1)},{1,222,55,13}))
        ok(eq({buffer:get(2)},{4,53,99,0}))
        ok(eq(buffer:dump(), string.char(1,222,55,13,4,53,99,0,1,222,55,13)), "RGBW")

        failwith("index out of range", function() buffer:get(0) end)
        failwith("index out of range", function() buffer:get(4) end)
        failwith("index out of range", function() buffer:set(0,1,2,3,4) end)
        failwith("index out of range", function() buffer:set(4,1,2,3,4) end)
        failwith("number expected, got no value", function() buffer:set(2,1,2,3) end)
--        failwith("extra values given", function() buffer:set(2,1,2,3,4,5) end)
    end)

    it:should('fade correctly', function()
        buffer = pixbuf.newBuffer(1, pixbuf.TYPE_RGB)
        buffer:fill(1,222,55)
        buffer:fade(2)
        ok(buffer:dump() == string.char(0,111,27), "RGB")
        buffer:fill(1,222,55)
        buffer:fade(3, pixbuf.FADE_OUT)
        ok(buffer:dump() == string.char(0,math.floor(222/3),math.floor(55/3)), "RGB")
        buffer:fill(1,222,55)
        buffer:fade(3, pixbuf.FADE_IN)
        ok(buffer:dump() == string.char(3,255,165), "RGB")
        buffer = pixbuf.newBuffer(1, pixbuf.TYPE_RGBW)
        buffer:fill(1,222,55, 77)
        buffer:fade(2, pixbuf.FADE_OUT)
        ok(eq(buffer:dump(), string.char(0,111,27,38)), "RGBW")
    end)

    it:should('mix correctly issue #1736', function()
        buffer1 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)
        buffer2 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)
        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(256/8*7,buffer1,256/8,buffer2)
        ok(eq({buffer1:get(1)}, {10,23,54}))
    end)

    it:should('mix saturation correctly ', function()
        buffer1 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)
        buffer2 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)

        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(256/2,buffer1,-256,buffer2)
        ok(eq({buffer1:get(1)}, {0,0,0}))

        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(25600,buffer1,256/8,buffer2)
        ok(eq({buffer1:get(1)}, {255,255,255}))

        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(-257,buffer1,255,buffer2)
        ok(eq({buffer1:get(1)}, {0,5,1}))
    end)

    it:should('mix with strings correctly ', function()
        buffer1 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)
        buffer2 = pixbuf.newBuffer(1, pixbuf.TYPE_GRB)

        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(-257,buffer1,255,buffer2)
        ok(eq({buffer1:get(1)}, {0,5,1}))
    end)

    it:should('power', function()
        buffer = pixbuf.newBuffer(2, pixbuf.TYPE_GRBW)
        buffer:fill(10,22,54,234)
        ok(eq(buffer:power(), 2*(10+22+54+234)))
    end)

end)

mispec.run()
