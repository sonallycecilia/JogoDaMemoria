-- MenuPrincipalLayer.lua
local LayerManager = require("layers.layerManager")
local Config = require("config")
local Botao = require("interface.botao")

local MenuPrincipalLayer = {}
MenuPrincipalLayer.__index = MenuPrincipalLayer


function MenuPrincipalLayer:new()
    local self = setmetatable({}, MenuPrincipalLayer)
    self.manager = LayerManager:new()
    self.botoes = {
        iniciarJogo = Botao:new(Config,
                Config.botoes.imagemPath.menuPrincipal.iniciarJogo,
                80, 500,
                0.5, 0.5,
                function()
                    love.graphics.clear(1, 1, 1, 1)
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
    love.graphics.draw(imagemFundo, 0, 0, 0)
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
