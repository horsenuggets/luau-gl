--[[

Import

File import utilities for framebuffers. Decodes PNG image data into a Framebuffer using
png-luau.

--]]

const t = require("@packages/t")

const PngLuau = require("@packages/PngLuau")

const Framebuffer = require("./Framebuffer")

type Framebuffer = Framebuffer.Framebuffer

const Import = {}

function Import.fromPngBuffer(buf: buffer): Framebuffer
    assert(t.buffer(buf))

    const png = PngLuau.decode(buf)
    const fb = Framebuffer.new(png.width, png.height)
    buffer.copy(fb.Data, 0, png.pixels, 0, buffer.len(fb.Data))
    return fb
end

function Import.fromPngString(str: string): Framebuffer
    assert(t.string(str))

    return Import.fromPngBuffer(buffer.fromstring(str))
end

return Import
