-- layers/rankLayer.lua
local Config = require("config")
local Botao = require("interface.botao")

local RankLayer = {}
RankLayer.__index = RankLayer

function RankLayer:new(manager)
    local self = setmetatable({}, RankLayer)
    self.manager = manager
    self.proximaLayer = nil
    
    self.botoes = {
        Botao:new(Config,
            Config.botoes.imagemPath.menuJogo.voltar,
            50, 50, 0.7, 0.7,
            function() self.proximaLayer = "menuPrincipal" end),
    }
    
    return self
end

function RankLayer:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

function RankLayer:draw()
    love.graphics.clear(0, 0, 0, 1)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    
    -- Fundo principal
    local imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    local xFundo = (larguraTela - imagemFundo:getWidth()) / 2
    local yFundo = (alturaTela - imagemFundo:getHeight()) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(imagemFundo, xFundo, yFundo)

    -- Camada preta translúcida
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, larguraTela, alturaTela)

    -- Frame do menu com escala reduzida
    local imagemFundoMenu = love.graphics.newImage(Config.frames.menu.imagemPath)
    local menuScale = 0.8
    local larguraMenu = imagemFundoMenu:getWidth() * menuScale
    local alturaMenu = imagemFundoMenu:getHeight() * menuScale
    local xFundoMenu = (larguraTela - larguraMenu) / 2
    local yFundoMenu = (alturaTela - alturaMenu) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(imagemFundoMenu, xFundoMenu, yFundoMenu, 0, menuScale, menuScale)

    -- Calcula altura total real dos botões com espaçamento
    local espacamento = 5  -- margem entre botões
    local alturaTotal = 0
    for _, botao in ipairs(self.botoes) do
    alturaTotal = alturaTotal + (botao.height * botao.scaleY)
    end
    alturaTotal = alturaTotal + espacamento * (#self.botoes - 1)

    local yInicial = yFundoMenu + (alturaMenu - alturaTotal) / 2

    -- Posiciona centralizado
    local yAtual = yInicial
    for _, botao in ipairs(self.botoes) do
        botao.x = xFundoMenu + (larguraMenu - botao.width * botao.scaleX) / 2
        botao.y = 150 + yAtual
        botao:draw()
        yAtual = yAtual + (botao.height * botao.scaleY) + espacamento
    end
end

function RankLayer:mousepressed(x, y, button)
    for _, botao in ipairs(self.botoes) do
        botao:mousepressed(x, y, button)
    end
end

function RankLayer:mousemoved(x, y, dx, dy)
    for _, botao in ipairs(self.botoes) do
        botao:update(x, y)
    end
end

function RankLayer:formatarPlacar()
    -- Aqui você pode formatar o placar da maneira que desejar
    -- Por exemplo, adicionando zeros à esquerda ou formatando como uma string
    
end

return RankLayer