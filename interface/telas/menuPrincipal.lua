local Botao = require("interface.botao")
local Tabuleiro = require("classes.tabuleiro") --no caso, depois vai ser Partida

MenuPrincipal = {}

function MenuPrincipal:new()
    local novo = {
        botoes = {
            Botao:new(100, 100, 200, 50, "Iniciar Partida", function()
                print("Iniciar Partida")
            end),
            Botao:new(100, 200, 200, 50, "Sair", function()
                love.event.quit()
            end)
        }
    }
    self.__index = self
    return setmetatable(novo, self)
end

function MenuPrincipal:draw()
    -- Desenhar fundo do menu (quadrado marrom)
    love.graphics.setColor(0.4, 0.2, 0.1, 1) -- marrom
    love.graphics.rectangle("fill", 80, 80, 240, 200, 10, 10)

    -- Desenhar os botões
    for _, botao in ipairs(self.botoes) do
        botao:draw()
    end
end

function MenuPrincipal:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

return MenuPrincipal