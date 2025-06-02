local Config = require("config")

local Botao = {}
local Botao_mt = { __index = Botao }

function Botao:new(configTable, textoOrImagemPath, x, y, scaleX, scaleY, funcao, width, height)
    local imagem = nil
    local texto = nil
    local realWidth = width
    local realHeight = height

    if love.filesystem.getInfo(textoOrImagemPath) then
        imagem = love.graphics.newImage(textoOrImagemPath)
        realWidth = imagem:getWidth()
        realHeight = imagem:getHeight()
    else
        texto = textoOrImagemPath
        realWidth = width or configTable.botoes.largura
        realHeight = height or configTable.botoes.altura
    end

    local novoBotao = {
        x = x or 0,
        y = y or 0,
        width = realWidth,
        height = realHeight,
        texto = texto,
        imagem = imagem,
        funcao = funcao,
        selecionado = false,
        mouseSobre = false,
        scaleX = scaleX or configTable.scaleX or 1.0,
        scaleY = scaleY or configTable.scaleY or 1.0,
    }

    setmetatable(novoBotao, Botao_mt)
    return novoBotao
end

function Botao:update(mx, my)
    self.mouseSobre = mx >= self.x and mx <= self.x + self.width * self.scaleX and
                      my >= self.y and my <= self.y + self.height * self.scaleY
end

function Botao:clicar()
    if self.mouseSobre and self.funcao then
        self.funcao()
    end
end

function Botao:mousepressed(x, y, button)
    if button == 1 then
        self:update(x, y)
        self:clicar()
    end
end

function Botao:draw()
    local escalaX = self.scaleX
    local escalaY = self.scaleY

    if self.mouseSobre or self.selecionado then
        escalaX = escalaX * 0.9
        escalaY = escalaY * 0.9
    end

    if self.imagem then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            self.imagem,
            self.x + (self.width * self.scaleX) / 2,
            self.y + (self.height * self.scaleY) / 2,
            0,
            escalaX,
            escalaY,
            self.imagem:getWidth() / 2,
            self.imagem:getHeight() / 2
        )
    elseif self.texto then
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
        love.graphics.translate(
            self.x + (self.width * self.scaleX) / 2,
            self.y + (self.height * self.scaleY) / 2
        )
        love.graphics.scale(escalaX, escalaY)
        love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.texto, -self.width / 2, -8, self.width, "center")
        love.graphics.pop()
    end
end

return Botao
