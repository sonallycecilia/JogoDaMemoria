local LayerManager = require("layers.layerManager")
local Animacao = require("interface.animacao")
local Config = require("config")

if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

local manager = LayerManager:new()
local animacao

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    --carregando imagens das cartas
    local cartas = {
        Carta:new(1, "midia/images/cartas/fada.png"),
        Carta:new(2, "midia/images/cartas/naly.png"),
        Carta:new(3, "midia/images/cartas/elfa.png"),
        Carta:new(4, "midia/images/cartas/draenei.png"),
        Carta:new(5, "midia/images/cartas/borboleta.png"),
        Carta:new(6, "midia/images/cartas/lua.png"),
        Carta:new(7, "midia/images/cartas/coracao.png"),
        Carta:new(8, "midia/images/cartas/draenei.png"),
        Carta:new(9, "midia/images/cartas/flor.png"),
        Carta:new(10, "midia/images/cartas/gato.png"),
        Carta:new(11, "midia/images/cartas/pocao.png"),
        Carta:new(12, "midia/images/cartas/planta.png"),

    -- Exemplo de música
    -- local song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    -- song:setLooping(true)
    -- song:play()
    }
end

function love.update(dt)
    animacao:update(dt)
    manager:update(dt)

    local layerAtual = manager.currentLayer
    if layerAtual and layerAtual.proximaLayer then
        manager:setLayer(layerAtual.proximaLayer)
        layerAtual.proximaLayer = nil
    end
end

function love.mousepressed(x, y, button)
    manager:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    manager:mousemoved(x, y, dx, dy)
end

function love.keypressed(key)
    if (key == "escape") or (key == "q") then
        love.event.quit()
    end
end

function love.draw()
    manager:draw()
    -- animacao:draw()
end
