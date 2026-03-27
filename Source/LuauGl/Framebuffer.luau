--[[

Framebuffer

Core pixel buffer for software rendering. Stores RGBA pixel data in a flat buffer with
4 bytes per pixel. Provides pixel-level read/write access and bulk operations like
clear and fill.

--]]

local t = require("@packages/t")

local Color = require("./Color")

type Color = Color.Color

local BYTES_PER_PIXEL = 4

export type Framebuffer = {
    Width: number,
    Height: number,
    Data: buffer,
    SetPixel: (self: Framebuffer, x: number, y: number, color: Color) -> (),
    GetPixel: (self: Framebuffer, x: number, y: number) -> Color,
    Clear: (self: Framebuffer, color: Color?) -> (),
    Fill: (self: Framebuffer, x: number, y: number, w: number, h: number, color: Color) -> (),
    BlendPixel: (self: Framebuffer, x: number, y: number, color: Color) -> (),
    IsInBounds: (self: Framebuffer, x: number, y: number) -> boolean,
    Clone: (self: Framebuffer) -> Framebuffer,
}

local Framebuffer = {}
Framebuffer.__index = Framebuffer

function Framebuffer.new(width: number, height: number): Framebuffer
    assert(t.number(width))
    assert(t.number(height))
    assert(width > 0 and height > 0, "Dimensions must be positive")
    assert(width == math.floor(width) and height == math.floor(height), "Dimensions must be integers")

    local self = setmetatable({}, Framebuffer) :: any
    self.Width = width
    self.Height = height
    self.Data = buffer.create(width * height * BYTES_PER_PIXEL)
    return self
end

function Framebuffer.IsInBounds(self: Framebuffer, x: number, y: number): boolean
    return x >= 0 and x < self.Width and y >= 0 and y < self.Height
end

function Framebuffer.SetPixel(self: Framebuffer, x: number, y: number, color: Color)
    if not self:IsInBounds(x, y) then
        return
    end

    local offset = (y * self.Width + x) * BYTES_PER_PIXEL
    buffer.writeu8(self.Data, offset, color.r)
    buffer.writeu8(self.Data, offset + 1, color.g)
    buffer.writeu8(self.Data, offset + 2, color.b)
    buffer.writeu8(self.Data, offset + 3, color.a)
end

function Framebuffer.GetPixel(self: Framebuffer, x: number, y: number): Color
    assert(self:IsInBounds(x, y), `Pixel ({x}, {y}) is out of bounds`)

    local offset = (y * self.Width + x) * BYTES_PER_PIXEL
    return {
        r = buffer.readu8(self.Data, offset),
        g = buffer.readu8(self.Data, offset + 1),
        b = buffer.readu8(self.Data, offset + 2),
        a = buffer.readu8(self.Data, offset + 3),
    }
end

function Framebuffer.BlendPixel(self: Framebuffer, x: number, y: number, color: Color)
    if not self:IsInBounds(x, y) then
        return
    end

    if color.a == 255 then
        self:SetPixel(x, y, color)
        return
    end

    if color.a == 0 then
        return
    end

    local dst = self:GetPixel(x, y)
    local srcA = color.a / 255
    local dstA = dst.a / 255
    local outA = srcA + dstA * (1 - srcA)

    if outA == 0 then
        self:SetPixel(x, y, Color.Transparent)
        return
    end

    self:SetPixel(x, y, {
        r = math.floor((color.r * srcA + dst.r * dstA * (1 - srcA)) / outA + 0.5),
        g = math.floor((color.g * srcA + dst.g * dstA * (1 - srcA)) / outA + 0.5),
        b = math.floor((color.b * srcA + dst.b * dstA * (1 - srcA)) / outA + 0.5),
        a = math.floor(outA * 255 + 0.5),
    })
end

function Framebuffer.Clear(self: Framebuffer, color: Color?)
    local c = color or Color.Transparent
    local size = self.Width * self.Height

    for i = 0, size - 1 do
        local offset = i * BYTES_PER_PIXEL
        buffer.writeu8(self.Data, offset, c.r)
        buffer.writeu8(self.Data, offset + 1, c.g)
        buffer.writeu8(self.Data, offset + 2, c.b)
        buffer.writeu8(self.Data, offset + 3, c.a)
    end
end

function Framebuffer.Fill(self: Framebuffer, x: number, y: number, w: number, h: number, color: Color)
    local x0 = math.max(0, x)
    local y0 = math.max(0, y)
    local x1 = math.min(self.Width, x + w)
    local y1 = math.min(self.Height, y + h)

    for py = y0, y1 - 1 do
        for px = x0, x1 - 1 do
            self:SetPixel(px, py, color)
        end
    end
end

function Framebuffer.Clone(self: Framebuffer): Framebuffer
    local clone = Framebuffer.new(self.Width, self.Height)
    buffer.copy(clone.Data, 0, self.Data, 0, buffer.len(self.Data))
    return clone
end

return Framebuffer
