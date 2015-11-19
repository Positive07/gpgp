local lg = love.graphics
local lm = love.mouse

local Grid = require 'class.grid'

local TilePalette = {}

function TilePalette:enter(previous, tileset)
  local w      = tileset.image:getWidth() / tileset.tileSize
  local h      = tileset.image:getHeight() / tileset.tileSize
  self.grid    = Grid(w, h)
  self.tileset = tileset
end

function TilePalette:update(dt)
  self.grid:update(dt)
end

function TilePalette:mousepressed(x, y, button)
  self.grid:mousepressed(x, y, button)
end

function TilePalette:draw()
  self.grid:drawTransformed(function()
    self.grid:drawBorder()
    self.grid:drawGrid()
    love.graphics.setColor(255, 255, 255)
    self.tileset:draw()
    self.grid:drawCursor()
  end)
end

return TilePalette
