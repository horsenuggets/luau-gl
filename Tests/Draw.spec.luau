--[[

Draw.spec

Tests for the Draw module.

--]]

local Color = require("../Source/LuauGl/Color")
local Draw = require("../Source/LuauGl/Draw")
local Framebuffer = require("../Source/LuauGl/Framebuffer")

return function()
    describe("line", function()
        it("should draw a horizontal line", function()
            local fb = Framebuffer.new(10, 10)
            Draw.line(fb, 0, 5, 9, 5, Color.Red)
            for x = 0, 9 do
                expect(fb:GetPixel(x, 5).r).to.equal(255)
            end
            expect(fb:GetPixel(0, 0).r).to.equal(0)
        end)

        it("should draw a vertical line", function()
            local fb = Framebuffer.new(10, 10)
            Draw.line(fb, 3, 0, 3, 9, Color.Green)
            for y = 0, 9 do
                expect(fb:GetPixel(3, y).g).to.equal(255)
            end
        end)
    end)

    describe("rect", function()
        it("should draw a rectangle outline", function()
            local fb = Framebuffer.new(10, 10)
            Draw.rect(fb, 1, 1, 5, 5, Color.Blue)
            expect(fb:GetPixel(1, 1).b).to.equal(255)
            expect(fb:GetPixel(5, 1).b).to.equal(255)
            expect(fb:GetPixel(1, 5).b).to.equal(255)
            expect(fb:GetPixel(5, 5).b).to.equal(255)
            expect(fb:GetPixel(3, 3).b).to.equal(0)
        end)
    end)

    describe("fillRect", function()
        it("should draw a filled rectangle", function()
            local fb = Framebuffer.new(10, 10)
            Draw.fillRect(fb, 2, 2, 4, 4, Color.Yellow)
            expect(fb:GetPixel(3, 3).r).to.equal(255)
            expect(fb:GetPixel(3, 3).g).to.equal(255)
            expect(fb:GetPixel(0, 0).r).to.equal(0)
        end)
    end)

    describe("circle", function()
        it("should draw a circle outline", function()
            local fb = Framebuffer.new(20, 20)
            Draw.circle(fb, 10, 10, 5, Color.Cyan)
            expect(fb:GetPixel(15, 10).g).to.equal(255)
            expect(fb:GetPixel(5, 10).g).to.equal(255)
            expect(fb:GetPixel(10, 10).g).to.equal(0)
        end)
    end)

    describe("fillCircle", function()
        it("should fill the interior of a circle", function()
            local fb = Framebuffer.new(20, 20)
            Draw.fillCircle(fb, 10, 10, 5, Color.Magenta)
            expect(fb:GetPixel(10, 10).r).to.equal(255)
            expect(fb:GetPixel(10, 10).b).to.equal(255)
            expect(fb:GetPixel(0, 0).r).to.equal(0)
        end)
    end)

    describe("triangle", function()
        it("should draw a triangle outline", function()
            local fb = Framebuffer.new(20, 20)
            Draw.triangle(fb, 10, 2, 2, 18, 18, 18, Color.White)
            expect(fb:GetPixel(10, 2).r).to.equal(255)
        end)
    end)

    describe("fillTriangle", function()
        it("should fill the interior of a triangle", function()
            local fb = Framebuffer.new(20, 20)
            Draw.fillTriangle(fb, 10, 2, 2, 18, 18, 18, Color.Red)
            expect(fb:GetPixel(10, 10).r).to.equal(255)
            expect(fb:GetPixel(0, 0).r).to.equal(0)
        end)
    end)
end
