require 'mispec'

local buffer, buffer1, buffer2

local function initBuffer(buffer, ...)
  local i,v
  for i,v in ipairs({...}) do
    buffer:set(i, v, v*2, v*3, v*4)
  end
  return buffer
end

local function equalsBuffer(buffer1, buffer2)
  return eq(buffer1:dump(), buffer2:dump())
end


describe('WS2812 buffers', function(it)

    it:should('initialize a buffer', function()
        buffer = ws2812.newBuffer(9, 3)
        ko(buffer == nil)
        ok(eq(buffer:size(), 9), "check size")
        ok(eq(buffer:dump(), string.char(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)), "initialize with 0")

        failwith("should be a positive integer", ws2812.newBuffer, 9, 0)
        failwith("should be a positive integer", ws2812.newBuffer, 9, -1)
        failwith("should be a positive integer", ws2812.newBuffer, 0, 3)
        failwith("should be a positive integer", ws2812.newBuffer, -1, 3)
    end)

    it:should('have correct size', function()
        buffer = ws2812.newBuffer(9, 3)
        ok(eq(buffer:size(), 9), "check size")
        buffer = ws2812.newBuffer(9, 22)
        ok(eq(buffer:size(), 9), "check size")
        buffer = ws2812.newBuffer(13, 1)
        ok(eq(buffer:size(), 13), "check size")
    end)

    it:should('fill a buffer with one color', function()
        buffer = ws2812.newBuffer(3, 3)
        buffer:fill(1,222,55)
        ok(eq(buffer:dump(), string.char(1,222,55,1,222,55,1,222,55)), "RGB")
        buffer = ws2812.newBuffer(3, 4)
        buffer:fill(1,222,55, 77)
        ok(eq(buffer:dump(), string.char(1,222,55,77,1,222,55,77,1,222,55,77)), "RGBW")
    end)

    it:should('replace correctly', function()
        buffer = ws2812.newBuffer(5, 3)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255))
        ok(eq(buffer:dump(), string.char(3,255,165,33,0,244,12,87,255,0,0,0,0,0,0)), "RGBW")

        buffer = ws2812.newBuffer(5, 3)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255), 2)
        ok(eq(buffer:dump(), string.char(0,0,0,3,255,165,33,0,244,12,87,255,0,0,0)), "RGBW")

        buffer = ws2812.newBuffer(5, 3)
        buffer:replace(string.char(3,255,165,33,0,244,12,87,255), -5)
        ok(eq(buffer:dump(), string.char(3,255,165,33,0,244,12,87,255,0,0,0,0,0,0)), "RGBW")

        failwith("Does not fit into destination", function() buffer:replace(string.char(3,255,165,33,0,244,12,87,255), 4) end)
        fail(function() buffer:replace(string.char(3,255,165,33,0,244,12,87,255), 4) end)
    end)

    it:should('replace correctly issue #2921', function()
        local buffer = ws2812.newBuffer(5, 3)
        failwith("Does not fit into destination", function() buffer:replace(string.char(3,255,165,33,0,244,12,87,255), -7) end)
    end)

    it:should('get/set correctly', function()
        buffer = ws2812.newBuffer(3, 4)
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
        buffer = ws2812.newBuffer(1, 3)
        buffer:fill(1,222,55)
        buffer:fade(2)
        ok(buffer:dump() == string.char(0,111,27), "RGB")
        buffer:fill(1,222,55)
        buffer:fade(3, ws2812.FADE_OUT)
        ok(buffer:dump() == string.char(0,222/3,55/3), "RGB")
        buffer:fill(1,222,55)
        buffer:fade(3, ws2812.FADE_IN)
        ok(buffer:dump() == string.char(3,255,165), "RGB")
        buffer = ws2812.newBuffer(1, 4)
        buffer:fill(1,222,55, 77)
        buffer:fade(2, ws2812.FADE_OUT)
        ok(eq(buffer:dump(), string.char(0,111,27,38)), "RGBW")
    end)

    it:should('mix correctly issue #1736', function()
        buffer1 = ws2812.newBuffer(1, 3) 
        buffer2 = ws2812.newBuffer(1, 3)
        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(256/8*7,buffer1,256/8,buffer2)
        ok(eq({buffer1:get(1)}, {10,23,54}))
    end)

    it:should('mix saturation correctly ', function()
        buffer1 = ws2812.newBuffer(1, 3) 
        buffer2 = ws2812.newBuffer(1, 3) 

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
        print(buffer1:get(1))
        ok(eq({buffer1:get(1)}, {0,5,1}))
    end)

    it:should('power', function()
        buffer = ws2812.newBuffer(2, 4)
        buffer:fill(10,22,54,234)
        ok(eq(buffer:power(), 2*(10+22+54+234)))
    end)

    it:should('shift LOGICAL', function()

        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(4, 4)

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,7,8)
        buffer1:shift(2)
        ok(equalsBuffer(buffer1, buffer2), "shift right")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,0,0)
        buffer1:shift(-2)
        ok(equalsBuffer(buffer1, buffer2), "shift left")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,0,8,12)
        buffer1:shift(1, nil, 2,3)
        ok(equalsBuffer(buffer1, buffer2), "shift middle right")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,0,12)
        buffer1:shift(-1, nil, 2,3)
        ok(equalsBuffer(buffer1, buffer2), "shift middle left")

        -- bounds checks, handle gracefully as string:sub does
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,8,9,12,0)
        buffer1:shift(-1, ws2812.SHIFT_LOGICAL, 0,5)
        ok(equalsBuffer(buffer1, buffer2), "shift left out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,7,8,9)
        buffer1:shift(1, ws2812.SHIFT_LOGICAL, 0,5)
        ok(equalsBuffer(buffer1, buffer2), "shift right out of bound")

    end)

    it:should('shift LOGICAL issue #2946', function()
        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(4, 4)
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,0,0)
        buffer1:shift(10)
        ok(equalsBuffer(buffer1, buffer2), "shift all right")
          
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,0,0,0,0)
        -- will reboot, so commented for now
        buffer1:shift(-6)
        ok(equalsBuffer(buffer1, buffer2), "shift all left")
    end)

    it:should('shift CIRCULAR', function()
        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(4, 4)

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,7,8)
        buffer1:shift(2, ws2812.SHIFT_CIRCULAR)
        ok(equalsBuffer(buffer1, buffer2), "shift right")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12,7,8)
        buffer1:shift(-2, ws2812.SHIFT_CIRCULAR)
        ok(equalsBuffer(buffer1, buffer2), "shift left")
        
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,8,12)
        buffer1:shift(1, ws2812.SHIFT_CIRCULAR, 2,3)
        ok(equalsBuffer(buffer1, buffer2), "shift middle right")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,9,8,12)
        buffer1:shift(-1, ws2812.SHIFT_CIRCULAR, 2,3)
        ok(equalsBuffer(buffer1, buffer2), "shift middle left")

        -- bounds checks, handle gracefully as string:sub does
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,8,9,12,7)
        buffer1:shift(-1, ws2812.SHIFT_CIRCULAR, 0,5)
        ok(equalsBuffer(buffer1, buffer2), "shift left out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,12,7,8,9)
        buffer1:shift(1, ws2812.SHIFT_CIRCULAR, 0,5)
        ok(equalsBuffer(buffer1, buffer2), "shift right out of bound")

        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,12,7,8,9)
        buffer1:shift(1, ws2812.SHIFT_CIRCULAR, -12,12)
        ok(equalsBuffer(buffer1, buffer2), "shift right way out of bound")

    end)

    it:should('sub', function()
        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(4, 4)
        initBuffer(buffer1,7,8,9,12)
        buffer1 = buffer1:sub(4,3)
        ok(eq(buffer1:size(), 0), "sub empty")

        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(2, 4)
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,9,12)
        buffer1 = buffer1:sub(3,4)
        ok(equalsBuffer(buffer1, buffer2), "sub")

        buffer1 = ws2812.newBuffer(4, 4)
        buffer2 = ws2812.newBuffer(4, 4)
        initBuffer(buffer1,7,8,9,12)
        initBuffer(buffer2,7,8,9,12)
        buffer1 = buffer1:sub(-12,33)
        ok(equalsBuffer(buffer1, buffer2), "out of bounds")
    end)




--[[
ws2812.buffer:__concat()
--]]

end)

mispec.run()
