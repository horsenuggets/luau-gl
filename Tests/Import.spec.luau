--[[

Import.spec

Tests for the Import module. Verifies PNG decoding produces a Framebuffer with the
expected dimensions and pixel data. Uses Export to round-trip a Framebuffer through
PNG and back.

--]]

local Color = require("../Source/LuauGl/Color")
local Export = require("../Source/LuauGl/Export")
local Framebuffer = require("../Source/LuauGl/Framebuffer")
local Import = require("../Source/LuauGl/Import")

return function()
    describe("fromPngBuffer", function()
        it("should round-trip a solid-color framebuffer", function()
            local original = Framebuffer.new(4, 4)
            original:Clear(Color.Red)

            local png = Export.toPngBuffer(original)
            local decoded = Import.fromPngBuffer(png)

            expect(decoded.Width).to.equal(4)
            expect(decoded.Height).to.equal(4)
            local pixel = decoded:GetPixel(0, 0)
            expect(pixel.r).to.equal(255)
            expect(pixel.g).to.equal(0)
            expect(pixel.b).to.equal(0)
            expect(pixel.a).to.equal(255)
        end)

        it("should preserve per-pixel colors", function()
            local original = Framebuffer.new(3, 2)
            original:SetPixel(0, 0, Color.new(255, 0, 0))
            original:SetPixel(1, 0, Color.new(0, 255, 0))
            original:SetPixel(2, 0, Color.new(0, 0, 255))
            original:SetPixel(0, 1, Color.new(255, 255, 255))
            original:SetPixel(1, 1, Color.new(0, 0, 0))
            original:SetPixel(2, 1, Color.new(128, 64, 32, 200))

            local decoded = Import.fromPngBuffer(Export.toPngBuffer(original))

            expect(decoded.Width).to.equal(3)
            expect(decoded.Height).to.equal(2)

            for y = 0, 1 do
                for x = 0, 2 do
                    local source = original:GetPixel(x, y)
                    local target = decoded:GetPixel(x, y)
                    expect(target.r).to.equal(source.r)
                    expect(target.g).to.equal(source.g)
                    expect(target.b).to.equal(source.b)
                    expect(target.a).to.equal(source.a)
                end
            end
        end)

        it("should error on non-PNG input", function()
            local bogus = buffer.fromstring("not a png")
            expect(function()
                Import.fromPngBuffer(bogus)
            end).to.throw()
        end)

        it("should error on non-buffer input", function()
            expect(function()
                Import.fromPngBuffer("string" :: any)
            end).to.throw()
        end)
    end)

    describe("fromPngString", function()
        it("should decode a PNG passed as a string", function()
            local original = Framebuffer.new(2, 2)
            original:Clear(Color.Green)

            local pngStr = Export.toPngString(original)
            local decoded = Import.fromPngString(pngStr)

            expect(decoded.Width).to.equal(2)
            expect(decoded.Height).to.equal(2)
            local pixel = decoded:GetPixel(1, 1)
            expect(pixel.g).to.equal(255)
        end)

        it("should error on non-string input", function()
            expect(function()
                Import.fromPngString(buffer.fromstring("x") :: any)
            end).to.throw()
        end)
    end)
end
