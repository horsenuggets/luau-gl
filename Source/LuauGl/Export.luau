--[[

Export

File export utilities for framebuffers. Supports saving to PNG format using png-luau.

--]]

const t = require("@packages/t")

const PngLuau = require("@packages/PngLuau")

const Framebuffer = require("./Framebuffer")

type Framebuffer = Framebuffer.Framebuffer

const Export = {}

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
