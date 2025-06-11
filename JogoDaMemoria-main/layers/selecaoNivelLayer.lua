-- layers/selecaoNivelLayer.lua
local Config = require("config")
local Botao = require("interface.botao")

local SelecaoNivelLayer = {}
SelecaoNivelLayer.__index = SelecaoNivelLayer

function SelecaoNivelLayer:new(manager)
    local self = setmetatable({}, SelecaoNivelLayer)
    self.manager = manager
    self.proximaLayer = nil
    
    self.botoes = {
        Botao:new(Config, Config.botoes.imagemPath.menuSelecaoNivel.facil, 100, 300, 0.8, 0.8, function()
            self.manager.nivelSelecionado = 1
            -- DETECTA O MODO E VAI PARA O LAYER CORRETO
            if self.manager.modoSelecionado == "cooperativo" then
                self.proximaLayer = "jogoCooperativo"
            else
                self.proximaLayer = "partida"
            end
        end),
        
        Botao:new(Config, Config.botoes.imagemPath.menuSelecaoNivel.medio, 100, 360, 0.8, 0.8, function()
            self.manager.nivelSelecionado = 2
            -- DETECTA O MODO E VAI PARA O LAYER CORRETO
            if self.manager.modoSelecionado == "cooperativo" then
                self.proximaLayer = "jogoCooperativo"
            else
                self.proximaLayer = "partida"
            end
        end),
        
        Botao:new(Config, Config.botoes.imagemPath.menuSelecaoNivel.dificil, 100, 420, 0.8, 0.8, function()
            self.manager.nivelSelecionado = 3
            -- DETECTA O MODO E VAI PARA O LAYER CORRETO
            if self.manager.modoSelecionado == "cooperativo" then
                self.proximaLayer = "jogoCooperativo"
            else
                self.proximaLayer = "partida"
            end
        end),
        
        Botao:new(Config, Config.botoes.imagemPath.menuSelecaoNivel.extremo, 100, 480, 0.8, 0.8, function()
            self.manager.nivelSelecionado = 4
            -- DETECTA O MODO E VAI PARA O LAYER CORRETO
            if self.manager.modoSelecionado == "cooperativo" then
                self.proximaLayer = "jogoCooperativo"
            else
                self.proximaLayer = "partida"
            end
        end),
        
        Botao:new(Config, Config.botoes.imagemPath.menuSelecaoNivel.voltar, 100, 540, 0.8, 0.8, function()
            self.proximaLayer = "menuJogo"
        end),
    }
    
    return self
end

function SelecaoNivelLayer:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

function SelecaoNivelLayer:draw()
    love.graphics.clear(0, 0, 0, 1)
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()
    
    local imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    local xFundo = (largura - imagemFundo:getWidth()) / 2
    local yFundo = (altura - imagemFundo:getHeight()) / 2
    love.graphics.draw(imagemFundo, xFundo, yFundo)
    
    for _, botao in ipairs(self.botoes) do
        botao:draw()
    end
end

function SelecaoNivelLayer:mousepressed(x, y, button)
    for _, botao in ipairs(self.botoes) do
        botao:mousepressed(x, y, button)
    end
end

function SelecaoNivelLayer:mousemoved(x, y, dx, dy)
    for _, botao in ipairs(self.botoes) do
        botao:update(x, y)
    end
end

return SelecaoNivelLayer