local Font      = require 'resources.fonts'
local Color     = require 'resources.colors'
local Grid      = require 'class.grid'
local Gamestate = require 'lib.gamestate'

local lg = love.graphics

local menuHeight = 0

local MainEditor = {}

function MainEditor:enter()
  self.grid = Grid(Project.width, Project.height, 0, menuHeight)
  function self.grid.place(grid, a, b)
    self.selectedLayer:place(a, b)
  end
  function self.grid.remove(grid, a, b)
    self.selectedLayer:remove(a, b)
  end

  self.selectedLayer = Project.groups[1].layers[1]
  self.visibleMode   = 1
  self.ghostLayers   = false

  self.help = {
    show = true,
    x    = 0,
    text = love.filesystem.read('resources/help.txt')
  }

  --cosmetic
  self.tween = require('lib.flux').group()
end

function MainEditor:update(dt)
  self.tween:update(dt)
  self.grid:update(dt)
end

function MainEditor:keypressed(key)
  --toggle help
  if key == 'f1' then
    self.help.show = not self.help.show
    if self.help.show then
      self.tween:to(self.help, .25, {x = 0}):ease('backout')
    else
      self.tween:to(self.help, .25, {x = -500}):ease('backin')
    end
  end

  --open palette
  if key == 'space' then
    self.selectedLayer:openPalette()
  end

  --layer picker
  if key == 'f5' then
    Gamestate.push(require('state.layer-picker'))
  end

  --change layer visibility
  if key == 'v' then
    self.visibleMode = self.visibleMode + 1
    if self.visibleMode == 4 then
      self.visibleMode = 1
    end
    conversation:say('setVisibleMode', self.visibleMode)
  end

  --change snap
  if key == '[' then
    self.grid.snap = self.grid.snap / 2
    conversation:say('changedSnap', self.grid.snap)
  end
  if key == ']' then
    self.grid.snap = self.grid.snap * 2
    conversation:say('changedSnap', self.grid.snap)
  end

  --toggle ghost layers
  if key == 'b' then
    self.ghostLayers = not self.ghostLayers
    conversation:say('toggledGhostLayers', self.ghostLayers)
  end

  if love.keyboard.isDown('lctrl') then
    --save
    if key == 's' then
      require('managers.project-manager').save()
      conversation:say('savedGame', Project.levelName)
    end
    --open
    if key == 'o' then
      Gamestate.push(require('state.level-picker'))
    end
  end
end

function MainEditor:wheelmoved(x, y)
  self.grid:wheelmoved(x, y, button)
end

function MainEditor:mousepressed(x, y, button)
  self.grid:mousepressed(x, y, button)
end

function MainEditor:mousereleased(x, y, button)
  self.grid:mousereleased(x, y, button)
end

function MainEditor:resize()
  self.grid:setScissor(0, menuHeight)
end

function MainEditor:draw()
  self.grid:drawTransformed(function()
    self.grid:drawBorder()
    self.grid:drawGrid()

    --draw layers
    for i = #Project.groups, 1, -1 do
      for j = #Project.groups[i].layers, 1, -1 do
        local layer = Project.groups[i].layers[j]
        local visible = (self.visibleMode == 1)
          or (self.visibleMode == 2 and layer.group == self.selectedLayer.group)
          or (self.visibleMode == 3 and layer == self.selectedLayer)
        if visible then
          layer:draw()
        elseif self.ghostLayers then
          layer:draw(50)
        end
      end
    end

    if self.grid:getCursorWithinMap() then
      self.grid:drawCursor()
      if self.grid.selectMode ~= 2 then
        if self.grid.selectionA then
          local g = self.grid
          self.selectedLayer:drawCursorImage(g.selectionA, g.selectionB)
        else
          self.selectedLayer:drawCursorImage(self.grid.cursor, self.grid.cursor)
        end
      end
    end
  end)

  --draw entity tooltips
  if self.selectedLayer.data.type == 'entity' then
    local entity = self.selectedLayer:getAt(self.grid.cursor)
    if entity then
      local mx, my = love.mouse.getX(), love.mouse.getY()
      lg.setColor(Color.Dark)
      local h = Font.Small:getHeight('test') * 3 + 10
      lg.rectangle('fill', mx + 10, my + 10, 100, h)
      local string = entity.entity.name ..
        '\nx: '..entity.pos.x..
        '\ny: '..entity.pos.y
      lg.setColor(Color.AlmostWhite)
      lg.setFont(Font.Small)
      lg.printf(string, mx + 15, my + 15, 100)
    end
  end

  --draw help
  local c = Color.Dark
  lg.setColor(c[1], c[2], c[3], 100)
  lg.rectangle('fill', self.help.x, menuHeight, 500, 340)
  lg.setColor(Color.AlmostWhite)
  lg.setFont(Font.Medium)
  lg.print(self.help.text, self.help.x, menuHeight)
end

return MainEditor
