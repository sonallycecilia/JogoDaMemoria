local Config = require("config")
local Botao = require("interface.botao")

local MenuJogo = {}
MenuJogo.__index = MenuJogo

function MenuJogo:new(manager)
    local self = setmetatable({}, MenuJogo)
    self.manager = manager
    self.proximaLayer = nil
    self.anteriorLayer = nil

    self.botoes = {
        cooperativo = Botao:new(Config,
                    Config.botoes.imagemPath.menuJogo.cooperativo,
                    80, 500,
                    1, 1,
                    function()
                        print("Modo Cooperativo")
                    end),

        competitivo = Botao:new(Config,
                    Config.botoes.imagemPath.menuJogo.competitivo,
                    80, 560,
                    1, 1,
                    function()
                        print("Modo Competitivo")
                    end),

        solo = Botao:new(Config,
                    Config.botoes.imagemPath.menuJogo.solo,
                    80, 620,
                    1, 1,
                    function()
                        print("Modo Solo")
                    end),

        voltar = Botao:new(Config,
                    Config.botoes.imagemPath.menuJogo.voltar,
                    80, 740,
                    1, 1,
                    function()
                        self.proximaLayer = nil
                        self.anteriorLayer = "menuPrincipal"
                    end)
    }
    return self
end

function MenuJogo:draw()
    love.graphics.clear(1, 1, 1, 1)

    local imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    local imagemFundoMenu = love.graphics.newImage(Config.frames.menu.imagemPath)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    -- Centraliza imagemFundo (com opacidade)
    local larguraImagemFundo = imagemFundo:getWidth()
    local alturaImagemFundo = imagemFundo:getHeight()
    local xFundo = (larguraTela - larguraImagemFundo) / 2
    local yFundo = (alturaTela - alturaImagemFundo) / 2

    love.graphics.setColor(1, 1, 1, 0.7)-- Opacidade do fundo: 30%
    love.graphics.draw(imagemFundo, xFundo, yFundo)

    -- Centraliza imagemFundoMenu
    local larguraImagemFundoMenu = imagemFundoMenu:getWidth()
    local alturaImagemFundoMenu = imagemFundoMenu:getHeight()
    local xFundoMenu = (larguraTela - larguraImagemFundoMenu) / 2
    local yFundoMenu = (alturaTela - alturaImagemFundoMenu) / 2

    love.graphics.setColor(1, 1, 1, 1)  -- Restaura cor/opacidade normal
    love.graphics.draw(imagemFundoMenu, xFundoMenu, yFundoMenu)

    local offsetY = 0
    local espacamento = 100  -- espaço entre os botões
    
    for _, botao in pairs(self.botoes) do
        botao.x = xFundoMenu + (larguraImagemFundoMenu - botao.width * botao.scaleX) / 2
        botao.y = yFundoMenu + 150 + offsetY
        botao:draw()
        offsetY = offsetY + espacamento
    end
end

function MenuJogo:mousepressed(x, y, button)
    for _, botao in pairs(self.botoes) do
        botao:mousepressed(x, y, button)
    end
end

function MenuJogo:mousemoved(x, y, dx, dy)
    for _, botao in pairs(self.botoes) do
        botao:update(x, y)
    end
end

function MenuJogo:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end


return MenuJogo
