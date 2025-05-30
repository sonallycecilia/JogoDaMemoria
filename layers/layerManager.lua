-- layers/layerManager.lua
local layerMap = require("layers.layersMap") -- importa o mapa de layers (sem ciclos)

local LayerManager = {}
LayerManager.__index = LayerManager

function LayerManager:new()
    return setmetatable({ currentLayer = nil }, self)
end

function LayerManager:setLayer(layerName)
    local layerClass = layerMap[layerName]
    if layerClass then
        -- Passa o próprio LayerManager para a layer na criação (para comunicação)
        self.currentLayer = layerClass:new(self)
    else
        error("Layer desconhecida: " .. tostring(layerName))
    end
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
