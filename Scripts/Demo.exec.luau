#!/usr/bin/env -S lune run

--[[

Demo.exec

Generates sample PNG images demonstrating luau-gl capabilities. Outputs files to an
"Output" directory in the project root.

[Usage] ./Scripts/Demo.exec.luau

--]]

const fs = require("@lune/fs")

const Color = require("@luaugl/Color")
const Draw = require("@luaugl/Draw")
const Export = require("@luaugl/Export")
const Framebuffer = require("@luaugl/Framebuffer")
const Gradient = require("@luaugl/Gradient")

const OUTPUT_DIR = "Output"

const function ensureOutputDir()
    if not fs.isDir(OUTPUT_DIR) then
        fs.writeDir(OUTPUT_DIR)
    end
end

const function save(fb: Framebuffer.Framebuffer, name: string)
    const path = `{OUTPUT_DIR}/{name}.png`
    fs.writeFile(path, Export.toPngString(fb))
    print(`Saved "{path}"`)
end

const function demoHorizontalGradient()
    const fb = Framebuffer.new(256, 64)
    Gradient.linear(fb, 0, 0, 256, 64, Color.Red, Color.Blue)
    save(fb, "GradientHorizontal")
end

const function demoVerticalGradient()
    const fb = Framebuffer.new(64, 256)
    Gradient.linear(fb, 0, 0, 64, 256, Color.Green, Color.Magenta, false)
    save(fb, "GradientVertical")
end

const function demoCornerGradient()
    const fb = Framebuffer.new(256, 256)
    Gradient.corners(fb, 0, 0, 256, 256, Color.Red, Color.Green, Color.Blue, Color.Yellow)
    save(fb, "GradientCorners")
end

const function demoRadialGradient()
    const fb = Framebuffer.new(256, 256)
    fb:Clear(Color.Black)
    Gradient.radial(fb, 128, 128, 120, Color.White, Color.Black)
    save(fb, "GradientRadial")
end

const function demoShapes()
    const fb = Framebuffer.new(256, 256)
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

const function demoNormalMap()
    const size = 256
    const fb = Framebuffer.new(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            const r = math.floor(x / (size - 1) * 255)
            const g = math.floor(y / (size - 1) * 255)
            const b = 128
            fb:SetPixel(x, y, Color.new(r, g, b))
        end
    end

    save(fb, "NormalMap")
end

const function demoColorWheel()
    const size = 256
    const cx = size / 2
    const cy = size / 2
    const radius = size / 2 - 8
    const fb = Framebuffer.new(size, size)
    fb:Clear(Color.new(20, 20, 20))

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            const dx = x - cx
            const dy = y - cy
            const dist = math.sqrt(dx * dx + dy * dy)

            if dist <= radius then
                const angle = math.deg(math.atan2(dy, dx)) + 180
                const saturation = dist / radius
                fb:SetPixel(x, y, Color.fromHSV(angle, saturation, 1))
            end
        end
    end

    save(fb, "ColorWheel")
end

const function demoCheckerboard()
    const size = 256
    const tileSize = 16
    const fb = Framebuffer.new(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            const tileX = math.floor(x / tileSize)
            const tileY = math.floor(y / tileSize)
            const isLight = (tileX + tileY) % 2 == 0
            fb:SetPixel(x, y, if isLight then Color.new(220, 220, 220) else Color.new(40, 40, 40))
        end
    end

    save(fb, "Checkerboard")
end

const Demo = {}

function Demo.exec()
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

Demo.exec()
