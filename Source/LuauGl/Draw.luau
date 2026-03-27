--[[

Draw

Drawing primitives for the framebuffer. Provides line, rectangle, circle, and triangle
rendering using standard rasterization algorithms (Bresenham for lines, midpoint for
circles).

--]]

local t = require("@packages/t")

local Color = require("./Color")
local Framebuffer = require("./Framebuffer")

type Color = Color.Color
type Framebuffer = Framebuffer.Framebuffer

local Draw = {}

function Draw.line(fb: Framebuffer, x0: number, y0: number, x1: number, y1: number, color: Color)
    assert(t.table(fb))
    assert(t.number(x0))
    assert(t.number(y0))
    assert(t.number(x1))
    assert(t.number(y1))
    assert(t.table(color))

    x0 = math.floor(x0)
    y0 = math.floor(y0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)

    local dx = math.abs(x1 - x0)
    local dy = -math.abs(y1 - y0)
    local sx = if x0 < x1 then 1 else -1
    local sy = if y0 < y1 then 1 else -1
    local err = dx + dy

    while true do
        fb:SetPixel(x0, y0, color)

        if x0 == x1 and y0 == y1 then
            break
        end

        local e2 = 2 * err
        if e2 >= dy then
            err += dy
            x0 += sx
        end
        if e2 <= dx then
            err += dx
            y0 += sy
        end
    end
end

function Draw.rect(fb: Framebuffer, x: number, y: number, w: number, h: number, color: Color)
    assert(t.table(fb))
    assert(t.number(x))
    assert(t.number(y))
    assert(t.number(w))
    assert(t.number(h))
    assert(t.table(color))

    x = math.floor(x)
    y = math.floor(y)
    w = math.floor(w)
    h = math.floor(h)

    Draw.line(fb, x, y, x + w - 1, y, color)
    Draw.line(fb, x, y + h - 1, x + w - 1, y + h - 1, color)
    Draw.line(fb, x, y, x, y + h - 1, color)
    Draw.line(fb, x + w - 1, y, x + w - 1, y + h - 1, color)
end

function Draw.fillRect(fb: Framebuffer, x: number, y: number, w: number, h: number, color: Color)
    assert(t.table(fb))
    assert(t.number(x))
    assert(t.number(y))
    assert(t.number(w))
    assert(t.number(h))
    assert(t.table(color))

    fb:Fill(math.floor(x), math.floor(y), math.floor(w), math.floor(h), color)
end

function Draw.circle(fb: Framebuffer, cx: number, cy: number, radius: number, color: Color)
    assert(t.table(fb))
    assert(t.number(cx))
    assert(t.number(cy))
    assert(t.number(radius))
    assert(t.table(color))

    cx = math.floor(cx)
    cy = math.floor(cy)
    radius = math.floor(radius)

    local x = radius
    local y = 0
    local err = 1 - radius

    while x >= y do
        fb:SetPixel(cx + x, cy + y, color)
        fb:SetPixel(cx - x, cy + y, color)
        fb:SetPixel(cx + x, cy - y, color)
        fb:SetPixel(cx - x, cy - y, color)
        fb:SetPixel(cx + y, cy + x, color)
        fb:SetPixel(cx - y, cy + x, color)
        fb:SetPixel(cx + y, cy - x, color)
        fb:SetPixel(cx - y, cy - x, color)

        y += 1
        if err < 0 then
            err += 2 * y + 1
        else
            x -= 1
            err += 2 * (y - x) + 1
        end
    end
end

function Draw.fillCircle(fb: Framebuffer, cx: number, cy: number, radius: number, color: Color)
    assert(t.table(fb))
    assert(t.number(cx))
    assert(t.number(cy))
    assert(t.number(radius))
    assert(t.table(color))

    cx = math.floor(cx)
    cy = math.floor(cy)
    radius = math.floor(radius)

    local x = radius
    local y = 0
    local err = 1 - radius

    local function drawHLine(startX: number, endX: number, row: number)
        for px = startX, endX do
            fb:SetPixel(px, row, color)
        end
    end

    while x >= y do
        drawHLine(cx - x, cx + x, cy + y)
        drawHLine(cx - x, cx + x, cy - y)
        drawHLine(cx - y, cx + y, cy + x)
        drawHLine(cx - y, cx + y, cy - x)

        y += 1
        if err < 0 then
            err += 2 * y + 1
        else
            x -= 1
            err += 2 * (y - x) + 1
        end
    end
end

function Draw.triangle(
    fb: Framebuffer,
    x0: number,
    y0: number,
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    color: Color
)
    assert(t.table(fb))
    assert(t.table(color))

    Draw.line(fb, x0, y0, x1, y1, color)
    Draw.line(fb, x1, y1, x2, y2, color)
    Draw.line(fb, x2, y2, x0, y0, color)
end

function Draw.fillTriangle(
    fb: Framebuffer,
    x0: number,
    y0: number,
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    color: Color
)
    assert(t.table(fb))
    assert(t.table(color))

    x0 = math.floor(x0)
    y0 = math.floor(y0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)
    x2 = math.floor(x2)
    y2 = math.floor(y2)

    -- Sort vertices by y coordinate
    if y0 > y1 then
        x0, x1 = x1, x0
        y0, y1 = y1, y0
    end
    if y0 > y2 then
        x0, x2 = x2, x0
        y0, y2 = y2, y0
    end
    if y1 > y2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    local totalHeight = y2 - y0
    if totalHeight == 0 then
        return
    end

    for py = y0, y2 do
        local secondHalf = py > y1 or y1 == y0
        local segmentHeight = if secondHalf then y2 - y1 else y1 - y0

        if segmentHeight == 0 then
            continue
        end

        local alpha = (py - y0) / totalHeight
        local beta = if secondHalf then (py - y1) / segmentHeight else (py - y0) / segmentHeight

        local ax = x0 + (x2 - x0) * alpha
        local bx = if secondHalf then x1 + (x2 - x1) * beta else x0 + (x1 - x0) * beta

        if ax > bx then
            ax, bx = bx, ax
        end

        for px = math.floor(ax), math.floor(bx) do
            fb:SetPixel(px, py, color)
        end
    end
end

return Draw
