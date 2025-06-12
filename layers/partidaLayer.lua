local nivelDeJogo = require("classes.niveldeJogo")
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

    self.tempoParaVirarDeVolta = 1
    self.timerCartasViradas = 0
    self.partidaFinalizada = false

    self:load()
    return self
end

-- Atualizações da partida, como animações ou tempo
function PartidaLayer:update(dt)
    if self.partidaFinalizada then return end
    
    self.partida:update(dt)

    -- Lógica de tempo para o modo cooperativo
    if self.partida.modoDeJogo == "cooperativo" and not self.partida.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        
        if self.partida:finalizou() then
            self.partida:finalizarPartida()
        end
    end

    -- ✅ CORRIGIDO: Lógica de tempo para o modo SOLO
    if self.partida.modoDeJogo == "solo" and not self.partida.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then
            self.partida.partidaFinalizada = true
            self:finalizarPartida()
        end
    end

    -- Lógica de tempo para o modo competitivo
    if self.modoDeJogo == "competitivo" and not self.partida.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then
            self.partida.partidaFinalizada = true
            self:finalizarPartida()
        end
    end

    -- ✅ CORRIGIDO: Timer para cartas viradas (aplicável aos modos antigos)
    if self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            for _, carta in ipairs(self.partida.cartasViradasNoTurno) do
                if not carta.encontrada then
                    carta:alternarLado()
                end
            end
            self.partida.cartasViradasNoTurno = {}
            if self.partida.trocaJogadorAtual then
                self.partida:trocaJogadorAtual()
            end
        end
    elseif self.partida.jogadorAtual == "maquina" and #self.partida.cartasViradasNoTurno == 0 then
        self:jogadaMaquina()
    end

    -- Verifica se todos os grupos foram encontrados
    if self.partida.tabuleiro.cartasRestantes == 0 and not self.partida.partidaFinalizada then
        self.partida.partidaFinalizada = true
        self:finalizarPartida()
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
    
    -- ✅ ADICIONADO: Interface específica para modo solo
    if self.partida.modoDeJogo == "solo" and self.partida.modoSolo then
        self.partida.modoSolo:drawInterface()
    end
    
    -- ✅ ADICIONADO: Interface específica para modo competitivo (se usar partidaLayer)
    if self.partida.modoDeJogo == "competitivo" and self.partida.modoCompetitivo then
        self:drawInterfaceCompetitivo()
    end
end

-- ✅ NOVA FUNÇÃO: Interface para modo competitivo na partidaLayer
function PartidaLayer:drawInterfaceCompetitivo()
    if not self.partida.modoCompetitivo then return end
    
    local largura = love.graphics.getWidth()
    local info = self.partida:getStatusInfo()
    
    -- Painel de informações no canto superior direito
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", largura - 280, 10, 270, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    
    local x, y = largura - 270, 20
    
    -- Título
    love.graphics.setColor(1, 0.8, 0) -- Dourado para competitivo
    love.graphics.print("MODO COMPETITIVO", x, y)
    love.graphics.setColor(1, 1, 1)
    y = y + 25
    
    -- Tempo
    love.graphics.print("Tempo: " .. math.floor(info.tempo / 60) .. ":" .. string.format("%02d", info.tempo % 60), x, y)
    y = y + 20
    
    -- Placar
    love.graphics.setColor(0.2, 1, 0.2) -- Verde para humano
    love.graphics.print("VOCÊ: " .. (info.scoreHumano or 0) .. " pts", x, y)
    y = y + 20
    
    love.graphics.setColor(1, 0.2, 0.2) -- Vermelho para IA
    love.graphics.print("IA: " .. (info.scoreIA or 0) .. " pts", x, y)
    y = y + 20
    
    love.graphics.setColor(1, 1, 1)
    
    -- Vez do jogador
    if info.jogadorAtual == "HUMANO" then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.print(">>> SUA VEZ! <<<", x, y)
    else
        love.graphics.setColor(0.2, 0.8, 1)
        love.graphics.print(">>> VEZ DA IA <<<", x, y)
    end
    love.graphics.setColor(1, 1, 1)
end

function PartidaLayer:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- ✅ CORRIGIDO: MODO SOLO - Usar o sistema correto
    if self.partida.modoDeJogo == "solo" then
        return self.partida:mousepressed(x, y, button)
    end

    -- ✅ CORRIGIDO: MODO COMPETITIVO - Usar o sistema correto
    if self.partida.modoDeJogo == "competitivo" then
        return self.partida:mousepressed(x, y, button)
    end

    -- MODO COOPERATIVO - Sistema antigo mantido
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
        -- ✅ CORRIGIDO: Usar método correto para adicionar score
        if self.partida.score and self.partida.score.adicionarAoScore then
            self.partida.score:adicionarAoScore(200)
        else
            self.partida.score = (self.partida.score or 0) + 200
        end
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
    
    -- ✅ ADICIONADO: Lógica específica por modo
    if self.partida.modoDeJogo == "solo" then
        print("Modo Solo finalizado!")
        local pontuacao = self.partida.score and self.partida.score.pontuacao or 0
        print("Pontuação final: " .. pontuacao)
    elseif self.partida.modoDeJogo == "competitivo" and self.partida.modoCompetitivo then
        print("Modo Competitivo finalizado!")
        local resultado = self.partida.modoCompetitivo:obterResultadoFinal()
        print("Vencedor: " .. resultado.vencedor)
        print("Placar: VOCÊ " .. resultado.scoreHumano .. " x " .. resultado.scoreIA .. " IA")
    end
    
    -- Retorna ao menu após alguns segundos
    self.tempoEspera = 0
end

-- ✅ ADICIONADO: Controla retorno ao menu
function PartidaLayer:updateFinalizacao(dt)
    if self.partidaFinalizada then
        self.tempoEspera = (self.tempoEspera or 0) + dt
        if self.tempoEspera > 3 then
            self.proximaLayer = "menuPrincipal"
        end
    end
end

return PartidaLayer