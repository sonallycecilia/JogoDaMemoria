local Config = require("config")
local Botao = require("interface.botao")

local MenuPrincipalLayer = {}
MenuPrincipalLayer.__index = MenuPrincipalLayer

function MenuPrincipalLayer:new(manager)
    local self = setmetatable({}, MenuPrincipalLayer)
    self.manager = manager
    self.proximaLayer = nil

    self.imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    self.imagemNome = love.graphics.newImage("midia/images/nome.png")

    self.botoes = {
        iniciarJogo = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.iniciarJogo,
            50, 500, 0.7, 0.7,
            function() self.proximaLayer = "menuJogo" end),

        configuracoes = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.configuracoes,
            50, 560, 0.7, 0.7,
            function() print("Configurações") end),

        conquistas = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.conquistas,
            50, 620, 0.7, 0.7,
            function() print("Conquistas") end),

        creditos = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.creditos,
            50, 680, 0.7, 0.7,
            function() print("Créditos") end),

        skins = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.skins,
            50, 740, 0.7, 0.7,
            function() self.proximaLayer = "rank" end),

        sair = Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.sair,
            1435, 740, 0.7, 0.7,
            function() love.event.quit() end),
    }

    return self
end

function MenuPrincipalLayer:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in pairs(self.botoes) do
        botao:update(mx, my)
    end
end

function MenuPrincipalLayer:draw()
    love.graphics.clear(1, 1, 1, 1)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()
    local larguraImagem = self.imagemFundo:getWidth()
    local alturaImagem = self.imagemFundo:getHeight()
    local xFundo = (larguraTela - larguraImagem) / 2
    local yFundo = (alturaTela - alturaImagem) / 2

    love.graphics.draw(self.imagemFundo, xFundo, yFundo)
    love.graphics.draw(self.imagemNome, 900, 95, 0, 0.7, 0.7)

    for _, botao in pairs(self.botoes) do
        botao:draw()
    end
end

function MenuPrincipalLayer:mousepressed(x, y, button)
    if button == 1 then
        for _, botao in pairs(self.botoes) do
            botao:clicar()
        end
    end
end

function MenuPrincipalLayer:mousemoved(x, y, dx, dy)
    for _, botao in pairs(self.botoes) do
        botao:update(x, y)
    end
end

return MenuPrincipalLayer
