local Font  = require 'resources.fonts'
local Color = require 'resources.colors'

local Gamestate = require 'lib.gamestate'

local lg = love.graphics

local ScrollArea   = require 'class.ui.scroll-area'
local EntityButton = require 'class.ui.entity-button'

local EntityPalette = {}

function EntityPalette:enter(previous, layer)
  self.previous = previous
  self.layer    = layer
  self:generateMenu()

  --cosmetic
  self.canvasAlpha = 0
  self.canvasY     = 100
  self.tween       = require('lib.flux').group()
  self.tween:to(self, .5, {canvasY = 0, canvasAlpha = 255}):ease('quartout')
end

function EntityPalette:generateMenu()
  local bSize  = 100
  local bSpace = 1.5

  self.scrollArea = ScrollArea(0, 130, lg.getWidth() - 10, lg.getHeight() - 130)

  local gridWidth          = math.floor(self.scrollArea.size.x / (bSize * bSpace))
  local buttonTotalWidth   = gridWidth * bSize
  local buttonSpacingWidth = (gridWidth - 1) * bSize * (bSpace - 1)
  local totalWidth         = buttonTotalWidth + buttonSpacingWidth
  local offsetX            = (self.scrollArea.size.x - totalWidth) / 2
  local offsetY            = 0

  self.scrollArea:expand(offsetY + bSize * bSpace)

  local gridX, gridY = 0, 0
  for _, entity in pairs(Project.entities) do
    if gridX == gridWidth then
      gridY = gridY + 1
      self.scrollArea:expand(bSize * bSpace)
      gridX = 0
    end
    local x = offsetX + gridX * bSize * bSpace
    local y = offsetY + gridY * bSize * bSpace
    self.scrollArea:add(EntityButton(x, y, bSize, bSize, entity, self.layer))
    gridX = gridX + 1
  end

  --cosmetic
  self.canvas     = lg.newCanvas()
  self.background = lg.newCanvas()
  self.background:renderTo(function()
    love.graphics.clear(Color.AlmostBlack)
    local gaussianblur      = require('lib.shine').gaussianblur()
    gaussianblur.parameters = {sigma = 5}
    gaussianblur:draw(function()
      self.previous:draw()
    end)
  end)
end

function EntityPalette:keypressed(key)
  if key == 'space' or key == 'escape' then
    Gamestate.pop()
  end
end

function EntityPalette:wheelmoved(x, y)
  self.scrollArea:wheelmoved(x, y)
end

function EntityPalette:resize()
  self:generateMenu()
end

function EntityPalette:update(dt)
  self.tween:update(dt)
  self.scrollArea:update(dt)
end

function EntityPalette:draw()
  lg.setColor(150, 150, 150)
  lg.draw(self.background)

  self.canvas:renderTo(function()
    lg.clear(0, 0, 0, 0)
    lg.setColor(Color.AlmostWhite)
    lg.setFont(Font.Big)
    lg.printf('Entities', 10, 40, lg.getWidth() - 20, 'center')
    self.scrollArea:draw(dt)
  end)

  lg.setColor(255, 255, 255, self.canvasAlpha)
  lg.draw(self.canvas, 0, self.canvasY)
end

return EntityPalette
