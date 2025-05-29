local Config = require("config")

local Botao = {}
local Botao_mt = { __index = Botao }

function Botao:new(x, y, width, height, textoOrImagemPath, funcao)
    local imagem = nil
    local texto = nil

    -- Se o arquivo existir, é uma imagem
    if love.filesystem.getInfo(textoOrImagemPath) then
        imagem = love.graphics.newImage(textoOrImagemPath)
    else
        texto = textoOrImagemPath
    end

    local novoBotao = {
        x = x,
        y = y,
        width = width,
        height = height,
        texto = texto,
        imagem = imagem,

        corNormal = Config.botoes.coresBotao.normal,
        corHover = Config.botoes.coresBotao.hover,
        corSelecionado = Config.botoes.coresBotao.selecionado,

        funcao = funcao,
        selecionado = false,
        mouseSobre = false
    }

    setmetatable(novoBotao, Botao_mt)
    return novoBotao
end


function Botao:update(mx, my)
    self.mouseSobre = mx >= self.x and mx <= self.x + self.width and
                      my >= self.y and my <= self.y + self.height
end

function Botao:clicar()
    if self.mouseSobre then
        self.selecionado = not self.selecionado
        if self.funcao then
            self.funcao()
        end
    end
end


function Botao:draw()
    local cor = self.corNormal
    if self.selecionado then
        cor = self.corSelecionado
    elseif self.mouseSobre then
        cor = self.corHover
    end

    love.graphics.setColor(cor)

    -- Desenha a imagem do botão, se existir
    if self.imagem then
        love.graphics.draw(self.imagem, self.x, self.y)
    else
        -- Desenha um botão retangular padrão, se não tiver imagem
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        -- Só desenha o texto se existir
        if self.texto then
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(self.texto, self.x, self.y + self.height / 2 - 8, self.width, "center")
        end
    end
end


return Botao