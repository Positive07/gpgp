local lg = love.graphics
local lm = love.mouse

local function lerp(a, b, x)
  return a + (b - a) * x
end

local Grid = Class:extend()

function Grid:new()
  self.mousePos  = Vector()
  self.mousePrev = Vector()

  self.pan            = Vector(lg.getWidth() / 2, lg.getHeight() / 2)
  self.scale          = 25
  self.displayPan     = self.pan
  self.displayScale   = self.scale
  self.cursor         = Vector()
end

function Grid:getRelativeMousePos()
  local pos   = Vector()
  pos.x = (lm.getX() - self.displayPan.x) / self.scale + Project.width / 2
  pos.y = (lm.getY() - self.displayPan.y) / self.scale + Project.height / 2
  return pos
end

function Grid:getCursorWithinMap()
  local c = self.cursor
  return c.x >= 0
     and c.x < Project.width
     and c.y >= 0
     and c.y < Project.height
end

function Grid:update(dt)
  --track mouse movement
  self.mousePrev = self.mousePos
  self.mousePos  = Vector(love.mouse.getX(), love.mouse.getY())
  local mouseDelta = self.mousePos - self.mousePrev

  --panning
  if love.mouse.isDown 'm' then
    self.pan        = self.pan + mouseDelta
    self.displayPan = self.pan
  end

  self.displayPan.x = lerp(self.displayPan.x, self.pan.x, 1 - (10^-5) ^ dt)
  self.displayPan.y = lerp(self.displayPan.y, self.pan.y, 1 - (10^-5) ^ dt)
  self.displayScale = lerp(self.displayScale, self.scale, 1 - (10^-5) ^ dt)

  --cursor
  local relativeMousePos = self:getRelativeMousePos()
  self.cursor.x          = math.floor(relativeMousePos.x)
  self.cursor.y          = math.floor(relativeMousePos.y)
end

function Grid:mousepressed(x, y, button)
  if button == 'wu' then
    self.scale = self.scale * 1.1
  end
  if button == 'wd' then
    self.scale = self.scale / 1.1
  end
end

function Grid:drawBorder()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setLineWidth(1 / self.displayScale)
  lg.line(0, 0, Project.width, 0)
  lg.line(0, Project.height, Project.width, Project.height)
  lg.line(0, 0, 0, Project.height)
  lg.line(Project.width, 0, Project.width, Project.height)
end

function Grid:drawGrid()
  lg.setColor(255, 255, 255, 100)
  love.graphics.setLineWidth(1 / self.displayScale)
  for i = 1, Project.width - 1 do
    lg.line(i, 0, i, Project.height)
  end
  for i = 1, Project.height - 1 do
    lg.line(0, i, Project.width, i)
  end
end

function Grid:drawCursor(i, w, h)
  if self:getCursorWithinMap() then
    lg.setColor(255, 255, 255, 100)
    lg.rectangle('fill', self.cursor.x, self.cursor.y, 1, 1)
  end
end

function Grid:drawTransformed(f)
  lg.push()
  lg.translate(self.displayPan.x, self.displayPan.y)
  lg.scale(self.displayScale)
  lg.translate(-Project.width / 2, -Project.height / 2)
  f()
  lg.pop()
end

return Grid