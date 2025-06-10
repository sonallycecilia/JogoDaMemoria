local Partida = require("classes.partida")
local Config = require("config")
local Botao = require("interface.botao")
-- layers/layerPartida.lua

local LayerPartida = {}
LayerPartida.__index = LayerPartida

function LayerPartida:new(manager, modoDeJogo, nivel, nomeJogador)
    local self = setmetatable({}, LayerPartida)
    self.manager = manager
    self.proximaLayer = nil
    self.nomeJogador = nomeJogador or "usuario1" --Nome do jogador será informado ao final da partida
    self.partida = Partida:new(modoDeJogo, nivel)
    
    self.cartasViradasNoTurno = {} 
    self.jogadorAtual = "jogador" | "maquina"--Jogador ou Máquina, jogador sempre começa jogando
    self.tempoParaVirarCarta = 1
    self.timerCartasViradas = 0 -- Pra que serve isso?
    self.partidaFinalizada = false

    self.adversarioIA = require("inteligencia_maquina.adversario")
    self.adversarioIA:inicializarMemoria(self.partida.tabuleiro.linhas, self.partida.tabuleiro.colunas)

    self:load()
    return self
end

function LayerPartida:update(dt)
    -- Atualizações da partida, como animações ou tempo
    
    -- Lógica de tempo para o modo cooperativo
    if self.partida.modoDeJogo == "cooperativo" and not self.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then -- Adicionar verificar para saber se todo os pares foram encontrados
            self.partidaFinalizada = true
            -- Lógica de fim de jogo por tempo
            self:finalizarPartida()
        end
    end

    -- Lógica de tempo para o modo competitivo
    if self.modoDeJogo == "competitivo" and not self.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then -- Adicionar verificar para saber se todo os pares foram encontrados
            self.partidaFinalizada = true
            -- Lógica de fim de jogo por tempo
            self:finalizarPartida()
        end
    end

    -- Lógica para desvirar as cartas após errar o par
    if #self.cartasViradasNoTurno > 0 and self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            for _, carta in ipairs(self.cartasViradasNoTurno) do
                if carta.revelada then -- Desvira apenas se estiver revelada
                    carta:alternarLado()
                end
            end
            self.cartasViradasNoTurno = {}
            -- Troca de turno após o erro
            if self.jogadorAtual == "humano" then
                self.jogadorAtual = "maquina"
            else
                self.jogadorAtual = "humano"
            end
        end
    end

    -- Lógica para a jogada da máquina
    if self.jogadorAtual == "maquina" and not self.partidaFinalizada and #self.cartasViradasNoTurno == 0 then
        self:jogadaMaquina() -- TODO: implementar método que realiza as duas jogadas da máquina 
    end

    -- Verifica se todos os pares foram encontrados
    if self.partida.tabuleiro.cartasRestantes == 0 and not self.partidaFinalizada then
        self.partidaFinalizada = true
        self:finalizarPartida() -- TODO: implementar método de finalização, mostrar o ranking, colocar o nome do jogador...
    end
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
