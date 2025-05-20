local Botao = {}
Botao.__index = Botao

function Botao:new(x, y, largura, altura, texto, funcao)
    local novo = {
        x = x,
        y = y,
        largura = largura,
        altura = altura,
        texto = texto or "",
        funcao = funcao,
        hover = false
    }
    setmetatable(novo, Botao)
    return novo
end

function Botao:update(mx, my)
    -- Verifica se o mouse está sobre o botão
    self.hover = mx >= self.x and mx <= self.x + self.largura and
                 my >= self.y and my <= self.y + self.altura
end

function Botao:draw()
    -- Cor do botão
    if self.hover then
        love.graphics.setColor(0.7, 0.7, 0.7)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.largura, self.altura, 8, 8)

    -- Cor e centralização do texto
    love.graphics.setColor(0, 0, 0)
    local fonte = love.graphics.getFont()
    local textoLargura = fonte:getWidth(self.texto)
    local textoAltura = fonte:getHeight()
    love.graphics.print(self.texto, self.x + (self.largura - textoLargura)/2, self.y + (self.altura - textoAltura)/2)
end

function Botao:mousepressed(mx, my, button)
    if button == 1 and self.hover and self.funcao then
        self.funcao()
    end
end

return Botao
