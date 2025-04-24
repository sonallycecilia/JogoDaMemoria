local carta = require("models.carta")
local tabuleiro = require("models.tabuleiro")

local anim8 = require 'anim8'


local minhaCarta = carta.novo(1, "midia/images/cartas/gata.png", "midia/images/verso.png")
local imagem
local animacao

function love.load()
    imagem = love.graphics.newImage("midia/sprites/trofeu.png")
        -- Substitua 32,32 pelo tamanho real de cada frame
        local larguraFrame = 120
        local alturaFrame = 120
    
        local grid = anim8.newGrid(larguraFrame, alturaFrame, imagem:getWidth(), imagem:getHeight())
        
        -- Se está tudo na mesma linha (horizontal), anima todos os frames da linha 1
        animacao = anim8.newAnimation(grid('1-73', 1), 0.1) -- 73 frames, 0.1s por frame
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
    
    minhaCarta:draw()
    animacao:draw(imagem, 100, 100)
end
