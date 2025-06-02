local Config = require("config")
Menu = {}

function Menu:new()
    local novo = {
        botoes = {}
    }
    self.__index = self
    return setmetatable(novo, self)
end

function Menu:draw()
    local fundo
    -- Desenhar fundo do menu (quadrado marrom)
        -- Desenhar os botões
    for _, botao in ipairs(self.botoes) do
        botao:draw()
    end
end

function Menu:clicada(x, y, button)
    for _, botao in ipairs(self.botoes) do
        botao:clicada(x, y, button)
    end
end


function Menu:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

function Menu:adicionarBotao(botao)
    table.insert(botao)
end

return Menu