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

local carta, animacao, tabuleiro, menu
local versoCarta = "midia/images/verso.png"

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    --carregando imagens das cartas
    local dadosCartas = {
        {id = 1, frente = "midia/images/cartas/fada.png"},
        {id = 2, frente = "midia/images/cartas/naly.png"},
        {id = 3, frente = "midia/images/cartas/elfa.png"},
        {id = 4, frente = "midia/images/cartas/draenei.png"},
    }

    menu = Menu:new()
    tabuleiro = Tabuleiro:new(1)

    for _, cartaInfo in ipairs(dadosCartas) do
        carta = Carta:new(cartaInfo.id, cartaInfo.frente)
        tabuleiro:addCarta(carta)
    end
    
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
