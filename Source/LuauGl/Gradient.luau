--[[

Gradient

Gradient fill operations for the framebuffer. Supports linear gradients between two
colors, four-corner gradients (bilinear interpolation), and radial gradients.

--]]

const t = require("@packages/t")

const Color = require("./Color")
const Framebuffer = require("./Framebuffer")

type Color = Color.Color
type Framebuffer = Framebuffer.Framebuffer

const Gradient = {}

function Gradient.linear(
    fb: Framebuffer,
    x: number,
    y: number,
    w: number,
    h: number,
    colorA: Color,
    colorB: Color,
    horizontal: boolean?
)
    assert(t.table(fb))
    assert(t.number(x))
    assert(t.number(y))
    assert(t.number(w))
    assert(t.number(h))
    assert(t.table(colorA))
    assert(t.table(colorB))

    const isHorizontal = if horizontal == nil then true else horizontal

    x = math.floor(x)
    y = math.floor(y)
    w = math.floor(w)
    h = math.floor(h)

    for py = y, y + h - 1 do
        for px = x, x + w - 1 do
            const alpha = if isHorizontal then (px - x) / math.max(w - 1, 1) else (py - y) / math.max(h - 1, 1)
            fb:SetPixel(px, py, Color.lerp(colorA, colorB, alpha))
        end
    end
end

function Gradient.corners(
    fb: Framebuffer,
    x: number,
    y: number,
    w: number,
    h: number,
    topLeft: Color,
    topRight: Color,
    bottomLeft: Color,
    bottomRight: Color
)
    assert(t.table(fb))
    assert(t.number(x))
    assert(t.number(y))
    assert(t.number(w))
    assert(t.number(h))
    assert(t.table(topLeft))
    assert(t.table(topRight))
    assert(t.table(bottomLeft))
    assert(t.table(bottomRight))

    x = math.floor(x)
    y = math.floor(y)
    w = math.floor(w)
    h = math.floor(h)

    for py = y, y + h - 1 do
        const v = (py - y) / math.max(h - 1, 1)
        for px = x, x + w - 1 do
            const u = (px - x) / math.max(w - 1, 1)
            const top = Color.lerp(topLeft, topRight, u)
            const bottom = Color.lerp(bottomLeft, bottomRight, u)
            fb:SetPixel(px, py, Color.lerp(top, bottom, v))
        end
    end
end

function Gradient.radial(fb: Framebuffer, cx: number, cy: number, radius: number, innerColor: Color, outerColor: Color)
    assert(t.table(fb))
    assert(t.number(cx))
    assert(t.number(cy))
    assert(t.number(radius))
    assert(t.table(innerColor))
    assert(t.table(outerColor))

    cx = math.floor(cx)
    cy = math.floor(cy)
    radius = math.floor(radius)

    const x0 = math.max(0, cx - radius)
    const y0 = math.max(0, cy - radius)
    const x1 = math.min(fb.Width - 1, cx + radius)
    const y1 = math.min(fb.Height - 1, cy + radius)

    for py = y0, y1 do
        for px = x0, x1 do
            const dx = px - cx
            const dy = py - cy
            const dist = math.sqrt(dx * dx + dy * dy)
            const alpha = math.clamp(dist / math.max(radius, 1), 0, 1)
            fb:SetPixel(px, py, Color.lerp(innerColor, outerColor, alpha))
        end
    end
end

return Gradient
