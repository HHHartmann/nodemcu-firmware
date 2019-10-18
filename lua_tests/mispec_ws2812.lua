require 'mispec'

local buffer, buffer1, buffer2

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

    it:should('replace correctly failing #2921', function()
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
--        failwith("index out of range", function() buffer:set(2,1,2,3,4,5) end)
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

    it:should('mix correctly', function()
        buffer1 = ws2812.newBuffer(1, 3) 
        buffer2 = ws2812.newBuffer(1, 3) 
        buffer1:fill(10,22,54)
        buffer2:fill(10,27,55)
        buffer1:mix(256/2,buffer1,-256,buffer2)
        ok(eq({buffer1:get(1)}, {0,0,0}))
    end)




--[[
ws2812.buffer:mix()	This is a general method that loads data into a buffer that is a linear combination of data from other buffers.
ws2812.buffer:power()	Computes the total energy requirement for the buffer.
ws2812.buffer:shift()	Shift the content of (a piece of) the buffer in positive or negative direction.
ws2812.buffer:sub()	This implements the extraction function like string.
ws2812.buffer:__concat()
--]]

end)

mispec.run()
