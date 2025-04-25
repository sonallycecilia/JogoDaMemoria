
local Carta = require("models.carta")
local Animacao = require("interface.animacao")
local Tabuleiro = require("models.Tabuleiro")


local carta, animacao, tabuleiro

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
        animacao:setPosicao(50, 50)
    carta = Carta.novo(1, "midia/images/cartas/coracao.png", "midia/images/verso.png", 100, 100)
        carta:setPosicao(200, 200)
    tabuleiro = Tabuleiro.novo(1)
        tabuleiro:setPosicao(200, 200)
        tabuleiro:addCarta(carta)

end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y)
    if carta:clicada(x, y) then
        carta:alternarLado()
    end
end

function love.draw()
    --love.graphics.clear(1, 1, 1, 1)
    
    tabuleiro:draw()
    animacao:draw()
end
