local LayerManager = require("layers.layerManager")
local Animacao = require("interface.animacao")
local menuPrincipalLayer = require("layers.menuPrincipalLayer")


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
local menuPrincipal

local partida
local song

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    menuPrincipal = menuPrincipalLayer:new()
    manager:setLayer(menuPrincipal)

    --song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    --song:setLooping(true)
    --song:play()

end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y, button)
    menuPrincipal:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    menuPrincipal:mousemoved(x, y, dx, dy)
end

function love.keypressed(key)
    if key == "x" then
        love.event.quit()
    end
end

function love.draw()
    -- desenhando botoes
    manager:draw()
    --animacao:draw()
end
