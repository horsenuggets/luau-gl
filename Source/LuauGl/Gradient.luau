--[[

Gradient

Gradient fill operations for the framebuffer. Supports linear gradients between two
colors, four-corner gradients (bilinear interpolation), and radial gradients.

--]]

local t = require("@packages/t")

local Color = require("./Color")
local Framebuffer = require("./Framebuffer")

type Color = Color.Color
type Framebuffer = Framebuffer.Framebuffer

local Gradient = {}

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

    local isHorizontal = if horizontal == nil then true else horizontal

    x = math.floor(x)
    y = math.floor(y)
    w = math.floor(w)
    h = math.floor(h)

    for py = y, y + h - 1 do
        for px = x, x + w - 1 do
            local alpha = if isHorizontal then (px - x) / math.max(w - 1, 1) else (py - y) / math.max(h - 1, 1)
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
        local v = (py - y) / math.max(h - 1, 1)
        for px = x, x + w - 1 do
            local u = (px - x) / math.max(w - 1, 1)
            local top = Color.lerp(topLeft, topRight, u)
            local bottom = Color.lerp(bottomLeft, bottomRight, u)
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

    local x0 = math.max(0, cx - radius)
    local y0 = math.max(0, cy - radius)
    local x1 = math.min(fb.Width - 1, cx + radius)
    local y1 = math.min(fb.Height - 1, cy + radius)

    for py = y0, y1 do
        for px = x0, x1 do
            local dx = px - cx
            local dy = py - cy
            local dist = math.sqrt(dx * dx + dy * dy)
            local alpha = math.clamp(dist / math.max(radius, 1), 0, 1)
            fb:SetPixel(px, py, Color.lerp(innerColor, outerColor, alpha))
        end
    end
end

return Gradient
