local Botao = require("interface.botao")
local Tabuleiro = require("classes.tabuleiro") --no caso, depois vai ser Partida

Menu = {}

function Menu:new()
    local novo = {
        botoes = {
            iniciarPartida = Botao:new(100, 100, 200, 50, "Iniciar Partida", function()
                print("Começar partida")
            end),
            Botao:new(100, 200, 200, 50, "Configurações", function()
                print("Abrir configurações...")
            end),
            Botao:new(100, 300, 200, 50, "Sair", function()
                love.event.quit()
            end)
        }
    }
    self.__index = self
    return setmetatable(novo, self)
end

function Menu:draw()
    for _, botao in ipairs(self.botoes) do
        botao:draw()
    end
end

function Menu:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

return Menu