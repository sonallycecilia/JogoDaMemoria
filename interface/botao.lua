Botao = {}

function Botao:new(x, y, largura, altura, texto, funcao)
    local novo = {
        x = x,
        y = y,
        largura = largura,
        altura = altura,
        texto = texto,
        funcao = funcao, -- o que o botão vai fazer quando clicado
        hover = false
    }
    self.__index = self
    return setmetatable(novo, self)
end

function Botao:draw()
    if self.hover then
        love.graphics.setColor(0.7, 0.7, 0.7) -- cor quando mouse em cima
    else
        love.graphics.setColor(0.5, 0.5, 0.5) -- cor normal
    end
    love.graphics.rectangle("fill", self.x, self.y, self.largura, self.altura)

    love.graphics.setColor(0, 0, 0) -- cor preta para o texto
    love.graphics.printf(self.texto, self.x, self.y + self.altura/2 - 10, self.largura, "center")
end

function Botao:update(mx, my)
    -- Atualiza se o mouse está sobre o botão
    self.hover = mx >= self.x and mx <= self.x + self.largura and
                 my >= self.y and my <= self.y + self.altura
end

function Botao:mousepressed(mx, my, button)
    if button == 1 and self.hover then
        self.funcao() -- chama a função associada
    end
end

return Botao