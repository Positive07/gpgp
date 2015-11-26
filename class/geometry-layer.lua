local Class  = require 'lib.classic'
local vector = require 'lib.vector'

local GeometryLayer = Class:extend()

function GeometryLayer:new(data)
  self.blocks = {}
  self:load(data)
end

function GeometryLayer:place(x1, y1, x2, y2)
  self:remove(x1, y1, x2, y2)
  for i = x1, x2 do
    for j = y1, y2 do
      table.insert(self.blocks, {pos = vector(i, j)})
    end
  end
end

function GeometryLayer:remove(x1, y1, x2, y2)
  for i = #self.blocks, 1, -1 do
    local block = self.blocks[i]
    if block.pos.x >= x1 and block.pos.x < x2 + 1
      and block.pos.y >= y1 and block.pos.y < y2 + 1 then
      table.remove(self.blocks, i)
    end
  end
end

function GeometryLayer:load(data)
  self.data = data
  self.name = data.name
  for _, block in pairs(self.data.blocks or {}) do
    table.insert(self.blocks, {
      pos = vector(block.x, block.y)
    })
  end
end

function GeometryLayer:save()
  local blocks = {}
  for _, block in pairs(self.blocks) do
    table.insert(blocks, {x = block.pos.x, y = block.pos.y})
  end

  return {
    name   = self.name,
    type   = 'geometry',
    blocks = blocks,
  }
end

function GeometryLayer:openPalette() end

function GeometryLayer:drawCursorImage(a, b) end

function GeometryLayer:draw(alpha)
  for _, block in pairs(self.blocks) do
    love.graphics.setColor(129, 187, 209, (alpha or 255) * .5)
    love.graphics.rectangle('fill', block.pos.x - 1, block.pos.y - 1, 1, 1)
  end
end

return GeometryLayer
