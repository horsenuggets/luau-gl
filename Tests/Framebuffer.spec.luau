--[[

Framebuffer

Tests for the Framebuffer module.

--]]

local Color = require("../Source/LuauGl/Color")
local Framebuffer = require("../Source/LuauGl/Framebuffer")

return function()
    describe("new", function()
        it("should create a framebuffer with the given dimensions", function()
            local fb = Framebuffer.new(100, 50)
            expect(fb.Width).to.equal(100)
            expect(fb.Height).to.equal(50)
        end)

        it("should initialize all pixels to zero", function()
            local fb = Framebuffer.new(10, 10)
            local pixel = fb:GetPixel(0, 0)
            expect(pixel.r).to.equal(0)
            expect(pixel.g).to.equal(0)
            expect(pixel.b).to.equal(0)
            expect(pixel.a).to.equal(0)
        end)
    end)

    describe("SetPixel and GetPixel", function()
        it("should write and read back a pixel", function()
            local fb = Framebuffer.new(10, 10)
            local c = Color.new(255, 128, 64, 200)
            fb:SetPixel(5, 3, c)
            local result = fb:GetPixel(5, 3)
            expect(result.r).to.equal(255)
            expect(result.g).to.equal(128)
            expect(result.b).to.equal(64)
            expect(result.a).to.equal(200)
        end)

        it("should silently ignore out-of-bounds writes", function()
            local fb = Framebuffer.new(10, 10)
            fb:SetPixel(-1, 0, Color.Red)
            fb:SetPixel(10, 0, Color.Red)
            fb:SetPixel(0, -1, Color.Red)
            fb:SetPixel(0, 10, Color.Red)
        end)
    end)

    describe("IsInBounds", function()
        it("should return true for valid coordinates", function()
            local fb = Framebuffer.new(10, 10)
            expect(fb:IsInBounds(0, 0)).to.equal(true)
            expect(fb:IsInBounds(9, 9)).to.equal(true)
        end)

        it("should return false for invalid coordinates", function()
            local fb = Framebuffer.new(10, 10)
            expect(fb:IsInBounds(-1, 0)).to.equal(false)
            expect(fb:IsInBounds(10, 0)).to.equal(false)
        end)
    end)

    describe("Clear", function()
        it("should fill all pixels with the given color", function()
            local fb = Framebuffer.new(4, 4)
            fb:Clear(Color.Red)
            for y = 0, 3 do
                for x = 0, 3 do
                    local pixel = fb:GetPixel(x, y)
                    expect(pixel.r).to.equal(255)
                    expect(pixel.g).to.equal(0)
                    expect(pixel.b).to.equal(0)
                    expect(pixel.a).to.equal(255)
                end
            end
        end)
    end)

    describe("Fill", function()
        it("should fill a rectangular region", function()
            local fb = Framebuffer.new(10, 10)
            fb:Fill(2, 2, 3, 3, Color.Blue)
            expect(fb:GetPixel(2, 2).b).to.equal(255)
            expect(fb:GetPixel(4, 4).b).to.equal(255)
            expect(fb:GetPixel(1, 1).b).to.equal(0)
            expect(fb:GetPixel(5, 5).b).to.equal(0)
        end)
    end)

    describe("Clone", function()
        it("should create an independent copy", function()
            local fb = Framebuffer.new(4, 4)
            fb:SetPixel(0, 0, Color.Green)
            local clone = fb:Clone()
            clone:SetPixel(0, 0, Color.Red)
            expect(fb:GetPixel(0, 0).g).to.equal(255)
            expect(clone:GetPixel(0, 0).r).to.equal(255)
        end)
    end)

    describe("BlendPixel", function()
        it("should fully replace with opaque color", function()
            local fb = Framebuffer.new(4, 4)
            fb:Clear(Color.White)
            fb:BlendPixel(0, 0, Color.Red)
            local result = fb:GetPixel(0, 0)
            expect(result.r).to.equal(255)
            expect(result.g).to.equal(0)
        end)

        it("should not change pixel with transparent color", function()
            local fb = Framebuffer.new(4, 4)
            fb:Clear(Color.White)
            fb:BlendPixel(0, 0, Color.Transparent)
            local result = fb:GetPixel(0, 0)
            expect(result.r).to.equal(255)
            expect(result.g).to.equal(255)
            expect(result.b).to.equal(255)
        end)
    end)
end
