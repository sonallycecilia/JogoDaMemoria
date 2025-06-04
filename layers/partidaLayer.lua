local Partida = require("classes.partida")
local Config = require("config")
local Botao = require("interface.botao")
-- layers/layerPartida.lua

local LayerPartida = {}
LayerPartida.__index = LayerPartida

function LayerPartida:new(manager)
    local self = setmetatable({}, LayerPartida)
    self.manager = manager
    self.proximaLayer = nil
    -- Inicialize o estado do jogo da memória aqui (cartas, seleção, etc.)
    self.partida = Partida:new("cooperativo", 2)
    self:load()
    -- Exemplo de modo de jogo e nível
    return self
end

function LayerPartida:update(dt)
    -- Atualizações da partida, como animações ou tempo
end

function LayerPartida:load()
    -- Carregue a imagem apenas uma vez
    self.imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    
    -- frames de imagens
    self.imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro)
    self.imagemCarta = love.graphics.newImage(Config.frames.partida.carta)
    self.imagemScore = love.graphics.newImage(Config.frames.partida.score)
end

function LayerPartida:draw()
    love.graphics.clear(0, 0, 0, 0)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    -- Fundo centralizado
    local larguraImagem = self.imagemFundo:getWidth()
    local alturaImagem = self.imagemFundo:getHeight()
    local xFundo = (larguraTela - larguraImagem) / 2
    local yFundo = (alturaTela - alturaImagem) / 2
    love.graphics.draw(self.imagemFundo, xFundo, yFundo)

    -- ESCALAS ajustadas
    local escalaTabuleiro = 0.9
    local escalaScore = 0.8
    local escalaCarta = 0.8

    -- POSICIONAMENTO baseado na imagem
    local xTabuleiro = 50
    local yTabuleiro = 130

    local xScore = 990
    local yScore = 130

    local xCarta = 990
    local yCarta = 323

    -- Desenhar frames com escalas proporcionais
    love.graphics.draw(self.imagemTabuleiro, xTabuleiro, yTabuleiro, 0, escalaTabuleiro, escalaTabuleiro)
    love.graphics.draw(self.imagemScore, xScore, yScore, 0, escalaScore, escalaScore)
    love.graphics.draw(self.imagemCarta, xCarta, yCarta, 0, escalaCarta, escalaCarta)

    -- Desenhar tabuleiro do jogo (internamente deve respeitar o novo layout)
    self.partida.tabuleiro:draw()
end

function LayerPartida:mousepressed(x, y, button)
    -- Tratar cliques nas cartas
end

function LayerPartida:mousemoved(x, y, dx, dy)
    -- Se quiser hover ou efeitos de destaque
end

return LayerPartida
