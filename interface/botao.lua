local Config = require("config")

local Botao = {}
local Botao_mt = { __index = Botao }

function Botao:new(configTable, textoOrImagemPath, x, y, scaleX, scaleY, funcao, width, height)
    local imagem = nil
    local texto = nil

    if love.filesystem.getInfo(textoOrImagemPath) then
        imagem = love.graphics.newImage(textoOrImagemPath)
    else
        texto = textoOrImagemPath
    end

    local novoBotao = {
        x = x or 0,
        y = y or 0,
        width = width or configTable.botoes.largura,
        height = height or configTable.botoes.altura,
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
    self.mouseSobre = mx >= self.x and mx <= self.x + self.width and
                      my >= self.y and my <= self.y + self.height
end

function Botao:clicar()
    if self.mouseSobre and self.funcao then
        self.funcao()
    end
end

function Botao:draw()
    local escalaX = self.scaleX
    local escalaY = self.scaleY

    -- Efeito visual ao passar o mouse ou clicar
    if self.mouseSobre or self.selecionado then
        escalaX = escalaX * 1.2
        escalaY = escalaY * 1.2
    end

    if self.imagem then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.imagem, self.x, self.y, 0, escalaX, escalaY)
    elseif self.texto then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.texto, self.x, self.y + self.height / 2 - 8, self.width, "center")
    end
end


return Botao