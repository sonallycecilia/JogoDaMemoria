-- layers/layerPartida.lua
local LayerPartida = {}
LayerPartida.__index = LayerPartida

function LayerPartida:new(manager)
    local self = setmetatable({}, LayerPartida)
    self.manager = manager
    self.proximaLayer = nil
    -- Inicialize o estado do jogo da memória aqui (cartas, seleção, etc.)
    return self
end

function LayerPartida:update(dt)
    -- Atualizações da partida, como animações ou tempo
end

function LayerPartida:draw()
    love.graphics.print("Layer: Partida", 100, 100)
    -- Desenhar cartas, fundo, HUD etc.
end

function LayerPartida:mousepressed(x, y, button)
    -- Tratar cliques nas cartas
end

function LayerPartida:mousemoved(x, y, dx, dy)
    -- Se quiser hover ou efeitos de destaque
end

return LayerPartida
