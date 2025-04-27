local Carta = require("classes.carta")
local Animacao = require("interface.animacao")
local Tabuleiro = require("classes.tabuleiro")
local Menu = require("interface.menu")
if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

local carta, animacao, tabuleiro, menu, song

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)
    
    song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    --song:setLooping(true)
    song:play()

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

    }

    menu = Menu:new()
    tabuleiro = Tabuleiro:new(3, cartas)
    
end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y)
    for _, carta in ipairs(tabuleiro.cartas) do
        if carta:clicada(x, y) then
            carta:alternarLado()
            break  -- Se quiser virar só uma por clique
        end
    end
end

function love.keypressed(key)
    if key == "w" then
        
    end

end

function love.draw()
    love.graphics.clear(1, 1, 1, 1)
    --menu:draw()
    tabuleiro:draw()
    animacao:draw()
end
