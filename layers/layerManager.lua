local LayerManager = {}
LayerManager.__index = LayerManager

function LayerManager:new()
    return setmetatable({ currentLayer = nil }, self)
end

function LayerManager:setLayer(layer)
    self.currentLayer = layer
end

function LayerManager:update(dt)
    if self.currentLayer and self.currentLayer.update then
        self.currentLayer:update(dt)
    end
end

function LayerManager:draw()
    if self.currentLayer and self.currentLayer.draw then
        self.currentLayer:draw()
    end
end

function LayerManager:mousepressed(x, y, button)
    if self.currentLayer and self.currentLayer.mousepressed then
        self.currentLayer:mousepressed(x, y, button)
    end
end

function LayerManager:mousemoved(x, y, dx, dy)
    if self.currentLayer and self.currentLayer.mousemoved then
        self.currentLayer:mousemoved(x, y, dx, dy)
    end
end

return LayerManager
