
local carta = require("models.carta")
local tabuleiro = require("models.tabuleiro")
local anim8 = require 'anim8'
local Animacao = require("interface.Animacao")

local minhaCarta = carta.novo(1, "midia/images/cartas/gata.png", "midia/images/verso.png")
local imagem
local animacao

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
        animacao:setPosicao(100, 100)
    minhaCarta.x = 100
    minhaCarta.y = 100
end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y)
    if minhaCarta:clicada(x, y) then
        minhaCarta:alternar()
    end
end

function love.draw()
    love.graphics.clear(1, 1, 1, 1)
    minhaCarta:draw()
    animacao:draw()
end
