--[[

Export

File export utilities for framebuffers. Supports saving to PNG format using png-luau.

--]]

local t = require("@packages/t")

local PngLuau = require("@packages/PngLuau")

local Framebuffer = require("./Framebuffer")

type Framebuffer = Framebuffer.Framebuffer

local Export = {}

function Export.toPngBuffer(fb: Framebuffer): buffer
    assert(t.table(fb))

    return PngLuau.encode(fb.Data, {
        width = fb.Width,
        height = fb.Height,
    })
end

function Export.toPngString(fb: Framebuffer): string
    return buffer.tostring(Export.toPngBuffer(fb))
end

return Export
