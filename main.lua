
local Carta = require("classes.carta")
local Animacao = require("interface.animacao")
local Tabuleiro = require("classes.Tabuleiro")


local carta, animacao, tabuleiro
local versoCarta = "midia/images/verso.png"

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    --carregando imagens das cartas
    local dadosCartas = {
        {id = 1, frente = "midia/images/cartas/coracao.png"},
        {id = 2, frente = "midia/images/cartas/morcego.png"},
        {id = 3, frente = "midia/images/cartas/borboleta.png"},
        {id = 4, frente = "midia/images/cartas/bomba.png"},
        {id = 5, frente = "midia/images/cartas/gato.png"},
        {id = 6, frente = "midia/images/cartas/lua.png"},

    }

    tabuleiro = Tabuleiro.novo(3)

    for _, cartaInfo in ipairs(dadosCartas) do
        carta = Carta.novo(cartaInfo.id, cartaInfo.frente, versoCarta, 100, 100)
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

function love.draw()
    love.graphics.clear(1, 1, 1, 1)
    
    tabuleiro:draw()
    animacao:draw()
end
