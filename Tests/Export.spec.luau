--[[

Export

Tests for the Export module. Verifies PNG encoding produces valid output.

--]]

local Color = require("@luaugl/Color")
local Export = require("@luaugl/Export")
local Framebuffer = require("@luaugl/Framebuffer")

return function()
    describe("toPngBuffer", function()
        it("should produce a valid PNG buffer", function()
            local fb = Framebuffer.new(4, 4)
            fb:Clear(Color.Red)
            local png = Export.toPngBuffer(fb)
            expect(buffer.len(png)).to.be.ok()
            expect(buffer.len(png) > 0).to.equal(true)
        end)

        it("should start with PNG magic bytes", function()
            local fb = Framebuffer.new(2, 2)
            fb:Clear(Color.Blue)
            local png = Export.toPngBuffer(fb)
            expect(buffer.readu8(png, 0)).to.equal(137)
            expect(buffer.readu8(png, 1)).to.equal(80)
            expect(buffer.readu8(png, 2)).to.equal(78)
            expect(buffer.readu8(png, 3)).to.equal(71)
        end)
    end)

    describe("toPngString", function()
        it("should produce a string with PNG content", function()
            local fb = Framebuffer.new(2, 2)
            fb:Clear(Color.Green)
            local pngStr = Export.toPngString(fb)
            expect(type(pngStr)).to.equal("string")
            expect(#pngStr > 0).to.equal(true)
        end)
    end)
end
