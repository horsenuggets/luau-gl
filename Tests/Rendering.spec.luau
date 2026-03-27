--[[

Rendering

Integration tests that render every primitive and gradient type to real PNG files,
then verify the output by decoding and spot-checking pixel values. Output files are
written to "Output/Tests/" for manual inspection.

--]]

local fs = require("@lune/fs")

local PngLuau = require("@packages/PngLuau")

local Color = require("../Source/LuauGl/Color")
local Draw = require("../Source/LuauGl/Draw")
local Export = require("../Source/LuauGl/Export")
local Framebuffer = require("../Source/LuauGl/Framebuffer")
local Gradient = require("../Source/LuauGl/Gradient")

local OUTPUT_DIR = "Output/Tests"

local function ensureOutputDir()
    if not fs.isDir("Output") then
        fs.writeDir("Output")
    end
    if not fs.isDir(OUTPUT_DIR) then
        fs.writeDir(OUTPUT_DIR)
    end
end

local function savePng(fb: Framebuffer.Framebuffer, name: string): string
    local path = `{OUTPUT_DIR}/{name}.png`
    fs.writeFile(path, Export.toPngString(fb))
    return path
end

local function decodePng(path: string)
    local data = fs.readFile(path)
    return PngLuau.decode(buffer.fromstring(data))
end

local function assertPixelApproxEqual(decoded: any, x: number, y: number, expected: Color.Color, tolerance: number?)
    local tol = tolerance or 1
    local r, g, b, a = decoded.readPixel(x, y)
    local dr = math.abs(r - expected.r)
    local dg = math.abs(g - expected.g)
    local db = math.abs(b - expected.b)
    local da = math.abs(a - expected.a)
    assert(
        dr <= tol and dg <= tol and db <= tol and da <= tol,
        `Pixel ({x}, {y}) expected ({expected.r}, {expected.g}, {expected.b}, {expected.a}) `
            .. `but got ({r}, {g}, {b}, {a}) with tolerance {tol}`
    )
end

return function()
    beforeAll(function()
        ensureOutputDir()
    end)

    describe("solid fills", function()
        it("should render a solid red image", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Red)
            local path = savePng(fb, "SolidRed")
            local decoded = decodePng(path)
            expect(decoded.width).to.equal(64)
            expect(decoded.height).to.equal(64)
            assertPixelApproxEqual(decoded, 1, 1, Color.Red)
            assertPixelApproxEqual(decoded, 32, 32, Color.Red)
            assertPixelApproxEqual(decoded, 64, 64, Color.Red)
        end)

        it("should render a solid white image", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.White)
            local path = savePng(fb, "SolidWhite")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.White)
            assertPixelApproxEqual(decoded, 64, 64, Color.White)
        end)

        it("should render a solid black image", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            local path = savePng(fb, "SolidBlack")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black)
        end)

        it("should render a transparent image", function()
            local fb = Framebuffer.new(64, 64)
            local path = savePng(fb, "SolidTransparent")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Transparent)
        end)

        it("should render a filled rectangle region", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            fb:Fill(10, 10, 20, 20, Color.Cyan)
            local path = savePng(fb, "SolidFillRegion")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 15, 15, Color.Cyan)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black)
            assertPixelApproxEqual(decoded, 40, 40, Color.Black)
        end)
    end)

    describe("lines", function()
        it("should render a horizontal line", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.line(fb, 0, 32, 63, 32, Color.White)
            local path = savePng(fb, "LineHorizontal")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 33, Color.White)
            assertPixelApproxEqual(decoded, 32, 33, Color.White)
            assertPixelApproxEqual(decoded, 64, 33, Color.White)
            assertPixelApproxEqual(decoded, 32, 1, Color.Black)
        end)

        it("should render a vertical line", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.line(fb, 32, 0, 32, 63, Color.Green)
            local path = savePng(fb, "LineVertical")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 33, 1, Color.Green)
            assertPixelApproxEqual(decoded, 33, 64, Color.Green)
            assertPixelApproxEqual(decoded, 1, 32, Color.Black)
        end)

        it("should render a diagonal line", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.line(fb, 0, 0, 63, 63, Color.Yellow)
            local path = savePng(fb, "LineDiagonal")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Yellow)
            assertPixelApproxEqual(decoded, 32, 32, Color.Yellow)
            assertPixelApproxEqual(decoded, 64, 64, Color.Yellow)
        end)

        it("should render crossing lines", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.line(fb, 0, 0, 63, 63, Color.Red)
            Draw.line(fb, 63, 0, 0, 63, Color.Blue)
            local path = savePng(fb, "LineCrossing")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Red)
            assertPixelApproxEqual(decoded, 64, 1, Color.Blue)
        end)
    end)

    describe("rectangles", function()
        it("should render a rectangle outline", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.rect(fb, 10, 10, 44, 44, Color.White)
            local path = savePng(fb, "RectOutline")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 11, 11, Color.White)
            assertPixelApproxEqual(decoded, 54, 11, Color.White)
            assertPixelApproxEqual(decoded, 32, 32, Color.Black)
        end)

        it("should render a filled rectangle", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.fillRect(fb, 10, 10, 44, 44, Color.Blue)
            local path = savePng(fb, "RectFilled")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 11, 11, Color.Blue)
            assertPixelApproxEqual(decoded, 32, 32, Color.Blue)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black)
        end)

        it("should render multiple rectangles", function()
            local fb = Framebuffer.new(128, 64)
            fb:Clear(Color.Black)
            Draw.fillRect(fb, 5, 5, 30, 30, Color.Red)
            Draw.fillRect(fb, 45, 5, 30, 30, Color.Green)
            Draw.fillRect(fb, 85, 5, 30, 30, Color.Blue)
            local path = savePng(fb, "RectMultiple")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 20, 20, Color.Red)
            assertPixelApproxEqual(decoded, 60, 20, Color.Green)
            assertPixelApproxEqual(decoded, 100, 20, Color.Blue)
        end)
    end)

    describe("circles", function()
        it("should render a circle outline", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.circle(fb, 32, 32, 20, Color.Magenta)
            local path = savePng(fb, "CircleOutline")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 53, 33, Color.Magenta)
            assertPixelApproxEqual(decoded, 33, 33, Color.Black)
        end)

        it("should render a filled circle", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.fillCircle(fb, 32, 32, 20, Color.Cyan)
            local path = savePng(fb, "CircleFilled")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 33, 33, Color.Cyan)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black)
        end)

        it("should render concentric circles", function()
            local fb = Framebuffer.new(128, 128)
            fb:Clear(Color.Black)
            Draw.fillCircle(fb, 64, 64, 50, Color.Red)
            Draw.fillCircle(fb, 64, 64, 35, Color.Green)
            Draw.fillCircle(fb, 64, 64, 20, Color.Blue)
            local path = savePng(fb, "CircleConcentric")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 65, 65, Color.Blue)
            assertPixelApproxEqual(decoded, 65, 40, Color.Green)
            assertPixelApproxEqual(decoded, 65, 20, Color.Red)
        end)
    end)

    describe("triangles", function()
        it("should render a triangle outline", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.triangle(fb, 32, 5, 5, 58, 58, 58, Color.Yellow)
            local path = savePng(fb, "TriangleOutline")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 33, 6, Color.Yellow)
        end)

        it("should render a filled triangle", function()
            local fb = Framebuffer.new(64, 64)
            fb:Clear(Color.Black)
            Draw.fillTriangle(fb, 32, 5, 5, 58, 58, 58, Color.Red)
            local path = savePng(fb, "TriangleFilled")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 32, 40, Color.Red)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black)
        end)
    end)

    describe("gradients", function()
        it("should render a horizontal linear gradient", function()
            local fb = Framebuffer.new(256, 64)
            Gradient.linear(fb, 0, 0, 256, 64, Color.Red, Color.Blue)
            local path = savePng(fb, "GradientLinearHorizontal")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Red, 2)
            assertPixelApproxEqual(decoded, 256, 1, Color.Blue, 2)
            local mr, _, mb, _ = decoded.readPixel(128, 1)
            expect(mr > 100 and mr < 160).to.equal(true)
            expect(mb > 100 and mb < 160).to.equal(true)
        end)

        it("should render a vertical linear gradient", function()
            local fb = Framebuffer.new(64, 256)
            Gradient.linear(fb, 0, 0, 64, 256, Color.Green, Color.Magenta, false)
            local path = savePng(fb, "GradientLinearVertical")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Green, 2)
            assertPixelApproxEqual(decoded, 1, 256, Color.Magenta, 2)
        end)

        it("should render a four-corner gradient", function()
            local fb = Framebuffer.new(256, 256)
            Gradient.corners(fb, 0, 0, 256, 256, Color.Red, Color.Green, Color.Blue, Color.Yellow)
            local path = savePng(fb, "GradientCorners")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.Red, 2)
            assertPixelApproxEqual(decoded, 256, 1, Color.Green, 2)
            assertPixelApproxEqual(decoded, 1, 256, Color.Blue, 2)
            assertPixelApproxEqual(decoded, 256, 256, Color.Yellow, 2)
        end)

        it("should render a radial gradient", function()
            local fb = Framebuffer.new(128, 128)
            fb:Clear(Color.Black)
            Gradient.radial(fb, 64, 64, 50, Color.White, Color.Black)
            local path = savePng(fb, "GradientRadial")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 65, 65, Color.White, 5)
            local r, g, b, _ = decoded.readPixel(65, 20)
            expect(r < 200).to.equal(true)
            expect(g < 200).to.equal(true)
            expect(b < 200).to.equal(true)
        end)
    end)

    describe("alpha blending", function()
        it("should render semi-transparent overlapping shapes", function()
            local fb = Framebuffer.new(128, 128)
            fb:Clear(Color.White)
            local semiRed = Color.new(255, 0, 0, 128)
            local semiBlue = Color.new(0, 0, 255, 128)
            for y = 20, 79 do
                for x = 20, 79 do
                    fb:BlendPixel(x, y, semiRed)
                end
            end
            for y = 48, 107 do
                for x = 48, 107 do
                    fb:BlendPixel(x, y, semiBlue)
                end
            end
            local path = savePng(fb, "AlphaBlending")
            local decoded = decodePng(path)
            local r1, _, _, _ = decoded.readPixel(30, 30)
            expect(r1 > 200).to.equal(true)
            local _, _, b2, _ = decoded.readPixel(90, 90)
            expect(b2 > 100).to.equal(true)
            local ro, _, bo, _ = decoded.readPixel(60, 60)
            expect(ro > 50).to.equal(true)
            expect(bo > 50).to.equal(true)
        end)
    end)

    describe("edge cases", function()
        it("should render a 1x1 image", function()
            local fb = Framebuffer.new(1, 1)
            fb:SetPixel(0, 0, Color.new(42, 128, 200, 255))
            local path = savePng(fb, "Edge1x1")
            local decoded = decodePng(path)
            expect(decoded.width).to.equal(1)
            expect(decoded.height).to.equal(1)
            assertPixelApproxEqual(decoded, 1, 1, Color.new(42, 128, 200))
        end)

        it("should render a wide image", function()
            local fb = Framebuffer.new(512, 1)
            Gradient.linear(fb, 0, 0, 512, 1, Color.Black, Color.White)
            local path = savePng(fb, "EdgeWide")
            local decoded = decodePng(path)
            expect(decoded.width).to.equal(512)
            expect(decoded.height).to.equal(1)
            assertPixelApproxEqual(decoded, 1, 1, Color.Black, 2)
            assertPixelApproxEqual(decoded, 512, 1, Color.White, 2)
        end)

        it("should render a tall image", function()
            local fb = Framebuffer.new(1, 512)
            Gradient.linear(fb, 0, 0, 1, 512, Color.Red, Color.Blue, false)
            local path = savePng(fb, "EdgeTall")
            local decoded = decodePng(path)
            expect(decoded.width).to.equal(1)
            expect(decoded.height).to.equal(512)
        end)
    end)

    describe("complex scenes", function()
        it("should render a normal map style gradient", function()
            local size = 128
            local fb = Framebuffer.new(size, size)
            for y = 0, size - 1 do
                for x = 0, size - 1 do
                    local r = math.floor(x / (size - 1) * 255)
                    local g = math.floor(y / (size - 1) * 255)
                    fb:SetPixel(x, y, Color.new(r, g, 128))
                end
            end
            local path = savePng(fb, "SceneNormalMap")
            local decoded = decodePng(path)
            local r1, g1, b1, _ = decoded.readPixel(1, 1)
            expect(r1).to.equal(0)
            expect(g1).to.equal(0)
            expect(b1).to.equal(128)
            local r2, g2, _, _ = decoded.readPixel(128, 128)
            expect(r2).to.equal(255)
            expect(g2).to.equal(255)
        end)

        it("should render a color wheel", function()
            local size = 128
            local cx = size / 2
            local cy = size / 2
            local radius = size / 2 - 4
            local fb = Framebuffer.new(size, size)
            fb:Clear(Color.Black)
            for y = 0, size - 1 do
                for x = 0, size - 1 do
                    local dx = x - cx
                    local dy = y - cy
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist <= radius then
                        local angle = math.deg(math.atan2(dy, dx)) + 180
                        local saturation = dist / radius
                        fb:SetPixel(x, y, Color.fromHSV(angle, saturation, 1))
                    end
                end
            end
            local path = savePng(fb, "SceneColorWheel")
            local decoded = decodePng(path)
            local cr, cg, cb, _ = decoded.readPixel(65, 65)
            expect(cr > 200).to.equal(true)
            expect(cg > 200).to.equal(true)
            expect(cb > 200).to.equal(true)
        end)

        it("should render a checkerboard", function()
            local size = 128
            local tileSize = 8
            local fb = Framebuffer.new(size, size)
            for y = 0, size - 1 do
                for x = 0, size - 1 do
                    local isLight = (math.floor(x / tileSize) + math.floor(y / tileSize)) % 2 == 0
                    fb:SetPixel(x, y, if isLight then Color.new(220, 220, 220) else Color.new(40, 40, 40))
                end
            end
            local path = savePng(fb, "SceneCheckerboard")
            local decoded = decodePng(path)
            assertPixelApproxEqual(decoded, 1, 1, Color.new(220, 220, 220))
            assertPixelApproxEqual(decoded, 9, 1, Color.new(40, 40, 40))
        end)

        it("should render a scene with all primitives", function()
            local fb = Framebuffer.new(256, 256)
            fb:Clear(Color.new(30, 30, 30))
            Gradient.corners(
                fb,
                0,
                0,
                256,
                256,
                Color.new(40, 0, 0),
                Color.new(0, 40, 0),
                Color.new(0, 0, 40),
                Color.new(40, 40, 0)
            )
            Draw.fillRect(fb, 20, 20, 60, 40, Color.Red)
            Draw.rect(fb, 18, 18, 64, 44, Color.White)
            Draw.fillCircle(fb, 180, 50, 35, Color.Blue)
            Draw.circle(fb, 180, 50, 35, Color.Cyan)
            Draw.fillTriangle(fb, 128, 100, 50, 200, 206, 200, Color.Green)
            Draw.triangle(fb, 128, 100, 50, 200, 206, 200, Color.Yellow)
            Draw.line(fb, 0, 0, 255, 255, Color.Magenta)
            Draw.line(fb, 255, 0, 0, 255, Color.White)
            Gradient.radial(fb, 200, 200, 40, Color.new(255, 255, 255, 128), Color.Transparent)
            local path = savePng(fb, "SceneAllPrimitives")
            local decoded = decodePng(path)
            expect(decoded.width).to.equal(256)
            expect(decoded.height).to.equal(256)
            local pngData = fs.readFile(path)
            expect(#pngData > 100).to.equal(true)
        end)
    end)
end
