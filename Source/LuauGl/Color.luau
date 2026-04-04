--[[

Color

Color representation and utility functions. Colors are stored as tables with r, g, b, a
fields (0-255 integers). Provides constructors from various formats and interpolation.

--]]

local t = require("@packages/t")

export type Color = {
    r: number,
    g: number,
    b: number,
    a: number,
}

local Color = {}

local function clamp(value: number): number
    return math.clamp(math.floor(value + 0.5), 0, 255)
end

function Color.new(r: number, g: number, b: number, a: number?): Color
    assert(t.number(r))
    assert(t.number(g))
    assert(t.number(b))
    assert(t.optional(t.number)(a))

    return {
        r = clamp(r),
        g = clamp(g),
        b = clamp(b),
        a = clamp(a or 255),
    }
end

function Color.fromHex(hex: string): Color
    assert(t.string(hex))

    local stripped = hex:gsub("^#", "")
    assert(#stripped == 6 or #stripped == 8, `Invalid hex color "{hex}"`)

    local r = tonumber(stripped:sub(1, 2), 16) :: number
    local g = tonumber(stripped:sub(3, 4), 16) :: number
    local b = tonumber(stripped:sub(5, 6), 16) :: number
    local a = if #stripped == 8 then tonumber(stripped:sub(7, 8), 16) :: number else 255

    return Color.new(r, g, b, a)
end

function Color.fromHSV(h: number, s: number, v: number, a: number?): Color
    assert(t.number(h))
    assert(t.number(s))
    assert(t.number(v))
    assert(t.optional(t.number)(a))

    h = h % 360
    s = math.clamp(s, 0, 1)
    v = math.clamp(v, 0, 1)

    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return Color.new((r + m) * 255, (g + m) * 255, (b + m) * 255, a or 255)
end

function Color.fromNormalized(r: number, g: number, b: number, a: number?): Color
    assert(t.number(r))
    assert(t.number(g))
    assert(t.number(b))
    assert(t.optional(t.number)(a))

    return Color.new(r * 255, g * 255, b * 255, (a or 1) * 255)
end

function Color.lerp(a: Color, b: Color, alpha: number): Color
    assert(t.table(a))
    assert(t.table(b))
    assert(t.number(alpha))

    alpha = math.clamp(alpha, 0, 1)
    return Color.new(
        a.r + (b.r - a.r) * alpha,
        a.g + (b.g - a.g) * alpha,
        a.b + (b.b - a.b) * alpha,
        a.a + (b.a - a.a) * alpha
    )
end

function Color.equal(a: Color, b: Color): boolean
    return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
end

Color.Black = Color.new(0, 0, 0)
Color.White = Color.new(255, 255, 255)
Color.Red = Color.new(255, 0, 0)
Color.Green = Color.new(0, 255, 0)
Color.Blue = Color.new(0, 0, 255)
Color.Yellow = Color.new(255, 255, 0)
Color.Cyan = Color.new(0, 255, 255)
Color.Magenta = Color.new(255, 0, 255)
Color.Transparent = Color.new(0, 0, 0, 0)

return Color
