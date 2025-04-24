local carta = require("models.carta")


local minhaCarta = carta.novo(1, "images/cartas/gata.png", "images/verso.png")

function love.load()
    minhaCarta.x = 100
    minhaCarta.y = 100
end



function love.mousepressed(x, y)
    if minhaCarta:clicada(x, y) then
        minhaCarta:alternar()
    end
end

function love.draw()
    love.graphics.rectangle("fill", 600, 400, 400, 400)
    minhaCarta:draw()
end
