local LayerManager = require("layers.layerManager")
local Animacao = require("interface.animacao")
local Config = require("config")

-- Inicialização do debugger, se for o caso
if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

-- Instância principal do gerenciador de camadas
local manager = LayerManager:new()
local animacao

function love.load(arg)
    -- Debugger para o ZeroBrane
    if arg and arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    manager:setLayer("menuPrincipal") -- começa no menu principal
end

function love.update(dt)
    animacao:update(dt)
    manager:update(dt)

    -- Verifica troca de camada
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
    if (key == "ralt") or (key == "escape") or (key == "x") then
        love.event.quit()
    end
end

function love.wheelmoved(x, y)
    if manager and manager.currentLayer and manager.currentLayer.wheelmoved then
        manager.currentLayer:wheelmoved(x, y)
    end
end

function love.draw()
    manager:draw()
end