local nivelDeJogo = require("classes.niveldeJogoEnum")
local Partida = require("classes.partida")
local Config = require("config")

local LARGURA_TELA = love.graphics.getWidth()
local ALTURA_TELA = love.graphics.getHeight()

local PartidaLayer = {}
PartidaLayer.__index = PartidaLayer

function PartidaLayer:new(manager, modoDeJogo, nivel)
    local self = setmetatable({}, PartidaLayer)
    self.modoDeJogo = modoDeJogo
    self.manager = manager
    self.proximaLayer = nil
self.partida = Partida:new(modoDeJogo, nivel)
    -- function () 
    --     if self.modoDeJogo == "competitivo" then 
    --         return PartidaCompetitiva:new(self.modoDeJogo, nivel) 
    --     end 
    --     if self.modoDeJogo == "cooperativo" then
    --         return PartidaCooperativa:new(self.modoDeJogo, nivel)
    --     end
    -- end

    self.tempoParaVirarDeVolta = 1
    self.timerCartasViradas = 0
    self.partidaFinalizada = false

    self:load()
    return self
end

-- Atualizações da partida, como animações ou tempo
function PartidaLayer:update(dt)
    if self.partidaFinalizada then return end
    
    self.partida:update(dt) -- REVISAR ISSO AQUI

    -- Lógica de tempo para o modo cooperativo
    if self.partida.modoDeJogo == "cooperativo" and not self.partida.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        
        if self.partida:finalizou() then
            self.partida:finalizarPartida()
        end
    end

    -- Lógica de tempo para o modo competitivo
    if self.modoDeJogo == "competitivo" and not self.partida.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then -- Adicionar verificar para saber se todo os pares foram encontrados
            self.partida.partidaFinalizada = true
            -- Lógica de fim de jogo por tempo
            self:finalizarPartida()
        end
    end

    if self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            for _, carta in ipairs(self.partida.cartasViradasNoTurno) do
                if not carta.encontrada then
                    carta:alternarLado()
                end
            end
            self.partida.cartasViradasNoTurno = {}
            self.partida:trocaJogadorAtual()
        end
        
    elseif self.partida.jogadorAtual == "maquina" and #self.partida.cartasViradasNoTurno == 0 then
        self:jogadaMaquina()
    end
    
    -- Lógica para a jogada da máquina
    if self.jogadorAtual == "maquina" and not self.partida.partidaFinalizada and #self.cartasViradasNoTurno == 0 then
        self:jogadaMaquina() -- TODO: implementar método que realiza as duas jogadas da máquina 
    end

    -- Verifica se todos os pares foram encontrados
    if self.partida.tabuleiro.cartasRestantes == 0 and not self.partida.partidaFinalizada then
        self.partida.partidaFinalizada = true
        self:finalizarPartida() -- TODO: implementar método de finalização, mostrar o ranking, colocar o nome do jogador...
    end
end

function PartidaLayer:load()
    self.imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    self.imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro)
    self.imagemCarta = love.graphics.newImage(Config.frames.partida.carta)
    self.imagemScore = love.graphics.newImage(Config.frames.partida.score)
end

function PartidaLayer:draw()
    love.graphics.clear(0, 0, 0, 0)

    local larguraImagem = self.imagemFundo:getWidth()
    local alturaImagem = self.imagemFundo:getHeight()
    local xFundo = (LARGURA_TELA - larguraImagem) / 2
    local yFundo = (ALTURA_TELA - alturaImagem) / 2
    love.graphics.draw(self.imagemFundo, xFundo, yFundo)

    love.graphics.draw(self.imagemTabuleiro, 50, 130, 0, 0.9, 0.9)
    love.graphics.draw(self.imagemScore, 990, 130, 0, 0.8, 0.8)
    love.graphics.draw(self.imagemCarta, 990, 323, 0, 0.8, 0.8)

    self.partida.tabuleiro:draw()
end

function PartidaLayer:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- MODO SOLO
    if self.partida.modoDeJogo == "solo" then
        self.partida:mousepressed(x, y, button)
        return
    end

    -- MODO COOPERATIVO
    if self.partida.modoDeJogo == "cooperativo" then
        if self.partida.jogadorAtual ~= "humano" then return end
        if #self.partida.cartasViradasNoTurno >= self.partida.maximoTentativas then return end
        if self.timerCartasViradas > 0 then return end

        for linha = 1, self.partida.tabuleiro.linhas do
            for coluna = 1, self.partida.tabuleiro.colunas do
                local i = (linha - 1) * self.partida.tabuleiro.colunas + coluna
                local carta = self.partida.tabuleiro.cartas[i]
                if carta and not carta.revelada and not carta.encontrada and carta:clicada(x, y) then
                    carta:alternarLado()
                    table.insert(self.partida.cartasViradasNoTurno, carta)
                    self.partida.adversarioIA:adicionarCartaMemoria(carta)

                    if #self.partida.cartasViradasNoTurno == self.partida.maximoTentativas then
                        local acertou = self.partida:verificaGrupoCartas()
                        if not acertou then
                            self.timerCartasViradas = self.tempoParaVirarDeVolta
                        else
                            for _, c in ipairs(self.partida.cartasViradasNoTurno) do
                                c.encontrada = true
                            end
                            self.partida.cartasViradasNoTurno = {}
                            self.partida:trocaJogadorAtual()
                        end
                    end
                    return
                end
            end
        end
    end
end

function PartidaLayer:jogadaMaquina()
    local carta1, carta2 = self.partida.adversarioIA:buscarParConhecido()

    if not carta1 or not carta2 then
        carta1 = self.partida.adversarioIA:selecionarCartaAleatoria(self.partida.tabuleiro)
        if not carta1 then return end
        carta2 = self.partida.adversarioIA:buscarPar(self.partida.tabuleiro, carta1)
            or self.partida.adversarioIA:selecionarCartaAleatoria(self.partida.tabuleiro, carta1)
    end

    if not carta1 or not carta2 then return end

    carta1:alternarLado()
    table.insert(self.partida.cartasViradasNoTurno, carta1)
    self.partida.adversarioIA:adicionarCartaMemoria(carta1)

    carta2:alternarLado()
    table.insert(self.partida.cartasViradasNoTurno, carta2)
    self.partida.adversarioIA:adicionarCartaMemoria(carta2)

    if carta1.id == carta2.id then
        carta1.encontrada = true
        carta2.encontrada = true
        self.partida.score = self.partida.score + 200
        self.partida.tabuleiro:removerGrupoEncontrado({carta1, carta2})
        self.partida.cartasViradasNoTurno = {}
        self.partida:trocaJogadorAtual()
    else
        self.timerCartasViradas = self.tempoParaVirarDeVolta
    end
end

function PartidaLayer:mousemoved(x, y, dx, dy) end

function PartidaLayer:finalizarPartida()
    print("Partida finalizada!")
end

return PartidaLayer