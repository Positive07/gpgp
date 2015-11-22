local EntityLayer = Class:extend()

function EntityLayer:new(data)
  self.entities = {}
  self.selected = Project.entities[1]
  self:load(data)
end

function EntityLayer:getAt(x, y)
  for _, entity in pairs(self.entities) do
    if entity.x == x and entity.y == y then
      return entity
    end
  end
end

function EntityLayer:place(x, y)
  self:remove(x, y)
  table.insert(self.entities, {x = x, y = y, entity = self.selected})
end

function EntityLayer:remove(x, y)
  for n, entity in pairs(self.entities) do
    if entity.x == x and entity.y == y then
      table.remove(self.entities, n)
    end
  end
end

function EntityLayer:load(data)
  self.data = data
  self.name = self.data.name
  for _, entity in pairs(self.data.entities) do
    for _, e in pairs(Project.entities) do
      if e.name == entity.entity then
        table.insert(self.entities, {x = entity.x, y = entity.y, entity = e})
      end
    end
  end
end

function EntityLayer:save()
  local toSave = {
    name     = self.name,
    type     = 'entity',
    entities = {},
  }
  for i = 1, #self.entities do
    local e = self.entities[i]
    table.insert(toSave.entities, {x = e.x, y = e.y, entity = e.entity.name})
  end
  return toSave
end

function EntityLayer:openPalette()
  require('lib.gamestate').push(require('state.entity-palette'), self)
end

function EntityLayer:drawCursorImage(x, y)
  if self.selected.image then
    local i = self.selected.image
    local sx = (self.selected.width or 1) / i:getWidth()
    local sy = (self.selected.height or 1) / i:getHeight()
    love.graphics.draw(i, x - 1, y - 1, 0, sx, sy)
  end
end

function EntityLayer:draw()
  for _, entity in pairs(self.entities) do
    local i  = entity.entity.image
    local x  = entity.x
    local y  = entity.y
    local sx = (entity.entity.width or 1) / i:getWidth()
    local sy = (entity.entity.height or 1) / i:getHeight()
    love.graphics.draw(i, x, y, 0, sx, sy)
  end
end

return EntityLayer
