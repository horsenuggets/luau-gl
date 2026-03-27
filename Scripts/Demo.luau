#!/usr/bin/env -S lune run

--[[

Demo

Generates sample PNG images demonstrating luau-gl capabilities. Outputs files to an
"Output" directory in the project root.

--]]

local fs = require("@lune/fs")

local Color = require("@luaugl/Color")
local Draw = require("@luaugl/Draw")
local Export = require("@luaugl/Export")
local Framebuffer = require("@luaugl/Framebuffer")
local Gradient = require("@luaugl/Gradient")

local OUTPUT_DIR = "Output"

local function ensureOutputDir()
    if not fs.isDir(OUTPUT_DIR) then
        fs.writeDir(OUTPUT_DIR)
    end
end

local function save(fb: Framebuffer.Framebuffer, name: string)
    local path = `{OUTPUT_DIR}/{name}.png`
    fs.writeFile(path, Export.toPngString(fb))
    print(`Saved "{path}"`)
end

local function demoHorizontalGradient()
    local fb = Framebuffer.new(256, 64)
    Gradient.linear(fb, 0, 0, 256, 64, Color.Red, Color.Blue)
    save(fb, "GradientHorizontal")
end

local function demoVerticalGradient()
    local fb = Framebuffer.new(64, 256)
    Gradient.linear(fb, 0, 0, 64, 256, Color.Green, Color.Magenta, false)
    save(fb, "GradientVertical")
end

local function demoCornerGradient()
    local fb = Framebuffer.new(256, 256)
    Gradient.corners(fb, 0, 0, 256, 256, Color.Red, Color.Green, Color.Blue, Color.Yellow)
    save(fb, "GradientCorners")
end

local function demoRadialGradient()
    local fb = Framebuffer.new(256, 256)
    fb:Clear(Color.Black)
    Gradient.radial(fb, 128, 128, 120, Color.White, Color.Black)
    save(fb, "GradientRadial")
end

local function demoShapes()
    local fb = Framebuffer.new(256, 256)
    fb:Clear(Color.new(30, 30, 30))

    Draw.fillRect(fb, 20, 20, 80, 60, Color.Red)
    Draw.rect(fb, 18, 18, 84, 64, Color.White)

    Draw.fillCircle(fb, 190, 50, 40, Color.Blue)
    Draw.circle(fb, 190, 50, 40, Color.Cyan)

    Draw.fillTriangle(fb, 128, 120, 60, 230, 196, 230, Color.Green)
    Draw.triangle(fb, 128, 120, 60, 230, 196, 230, Color.Yellow)

    Draw.line(fb, 0, 0, 255, 255, Color.Magenta)
    Draw.line(fb, 255, 0, 0, 255, Color.Cyan)

    save(fb, "Shapes")
end

local function demoNormalMap()
    local size = 256
    local fb = Framebuffer.new(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local r = math.floor(x / (size - 1) * 255)
            local g = math.floor(y / (size - 1) * 255)
            local b = 128
            fb:SetPixel(x, y, Color.new(r, g, b))
        end
    end

    save(fb, "NormalMap")
end

local function demoColorWheel()
    local size = 256
    local cx = size / 2
    local cy = size / 2
    local radius = size / 2 - 8
    local fb = Framebuffer.new(size, size)
    fb:Clear(Color.new(20, 20, 20))

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

    save(fb, "ColorWheel")
end

local function demoCheckerboard()
    local size = 256
    local tileSize = 16
    local fb = Framebuffer.new(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local tileX = math.floor(x / tileSize)
            local tileY = math.floor(y / tileSize)
            local isLight = (tileX + tileY) % 2 == 0
            fb:SetPixel(x, y, if isLight then Color.new(220, 220, 220) else Color.new(40, 40, 40))
        end
    end

    save(fb, "Checkerboard")
end

local function demo()
    ensureOutputDir()

    print("Generating demo images...")
    print("")

    demoHorizontalGradient()
    demoVerticalGradient()
    demoCornerGradient()
    demoRadialGradient()
    demoShapes()
    demoNormalMap()
    demoColorWheel()
    demoCheckerboard()

    print("")
    print(`Done. {8} images saved to "{OUTPUT_DIR}/"`)
end

demo()
