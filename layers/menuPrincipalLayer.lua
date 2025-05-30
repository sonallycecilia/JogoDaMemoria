-- MenuPrincipalLayer.lua
local Config = require("config")
local Botao = require("interface.botao")

local MenuPrincipalLayer = {}
MenuPrincipalLayer.__index = MenuPrincipalLayer


function MenuPrincipalLayer:new(manager)
    local self = setmetatable({}, MenuPrincipalLayer)
    self.manager = manager
    self.proximaLayer = nil

    self.botoes = {
        iniciarJogo = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.iniciarJogo,
                    80, 500,
                    0.5, 0.5,
                    function ()
                        self.proximaLayer = "menuJogo"
                    end),

        configuracoes = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.configuracoes,
                    80, 560,
                    0.5, 0.5,
                    function()
                        print("Configurações")
        end),

        conquistas = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.conquistas,
                    80, 620,
                    0.5, 0.5,
                    function()
                        print("Conquistas")
        end),

        creditos = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.creditos,
                    80, 680,
                    0.5, 0.5,
                    function()
                        print("Créditos")
        end),

        skins = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.skins,
                    80, 740,
                    0.5, 0.5,
                    function()
                        print("Skins")
        end),

        sair = Botao:new(Config,
                        Config.botoes.imagemPath.menuPrincipal.sair,
                        1400, 740,
                        0.5, 0.5,
                        function()
                            love.event.quit()
        end),
    }

    return self
end

function MenuPrincipalLayer:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

function MenuPrincipalLayer:draw()
    love.graphics.clear(1, 1, 1, 1)
    local imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    -- Centraliza imagemFundo na tela
    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()
    local larguraImagemFundo = imagemFundo:getWidth()
    local alturaImagemFundo = imagemFundo:getHeight()
    local xFundo = (larguraTela - larguraImagemFundo) / 2
    local yFundo = (alturaTela - alturaImagemFundo) / 2
    
    love.graphics.draw(imagemFundo, xFundo, yFundo)
    -- Desenhar os botões
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
