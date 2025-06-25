-- layers/layerManager.lua
local layerMap = require("layers.layersMap") -- importa o mapa de layers (sem ciclos)

local LayerManager = {}
LayerManager.__index = LayerManager

function LayerManager:new()
    return setmetatable({
        currentLayer = nil,
        modoSelecionado = nil,
        nivelSelecionado = nil
    }, self)
end

function LayerManager:setLayer(layerName)
    local layerClass = layerMap[layerName]
    if layerClass then
        if layerName == "jogoCooperativo" then
            -- Criação especial para jogoCooperativo
            self.currentLayer = layerClass:new()
            self.currentLayer:iniciar(self.nivelSelecionado or 1)
        elseif layerName == "jogoCompetitivo" then
            -- Criação especial para jogoCompetitivo
            self.currentLayer = layerClass:new()
            self.currentLayer:iniciar(self.nivelSelecionado or 1)
        elseif layerName == "jogoSolo" then
            -- Criação especial para jogoSolo
            self.currentLayer = layerClass:new()
            self.currentLayer:iniciar(self.nivelSelecionado or 1)
        elseif layerName == "partida" then
            -- Criação para partida comum (sistema legado)
            self.currentLayer = layerClass:new(self, self.modoSelecionado, self.nivelSelecionado)
        else
            -- Criação padrão para outros layers (menus, etc.)
            self.currentLayer = layerClass:new(self)
        end
    else
        error("Layer desconhecida: " .. tostring(layerName))
    end
end

function LayerManager:update(dt)
    if self.currentLayer and self.currentLayer.update then
        self.currentLayer:update(dt)
    end
    
    -- Verifica se há mudança de layer pendente
    if self.currentLayer and self.currentLayer.proximaLayer then
        local proximaLayer = self.currentLayer.proximaLayer
        self.currentLayer.proximaLayer = nil -- Limpa para evitar loops
        self:setLayer(proximaLayer)
    end
end


function LayerManager:draw()
    if self.currentLayer and self.currentLayer.draw then
        self.currentLayer:draw()
    end
end

function LayerManager:mousepressed(x, y, button)
    if self.currentLayer and self.currentLayer.mousepressed then
        return self.currentLayer:mousepressed(x, y, button)
    end
    return false
end

function LayerManager:mousemoved(x, y, dx, dy)
    if self.currentLayer and self.currentLayer.mousemoved then
        self.currentLayer:mousemoved(x, y, dx, dy)
    end
end

function LayerManager:keypressed(key)
    if self.currentLayer and self.currentLayer.keypressed then
        self.currentLayer:keypressed(key)
    end
end

return LayerManager