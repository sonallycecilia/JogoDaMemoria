local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")
local Score = require("classes.score")
local Validacao = require("classes.utils.validacao")
local DataHora = require("classes.utils.dataHora")
local Cooperativo = require("classes.modos.cooperativo")
local Solo = require("classes.modos.solo")
local Competitivo = require("classes.modos.competitivo")

local Partida = {}
Partida.__index = Partida

function Partida:new(modoDeJogo, nivel)
    local self = setmetatable({}, Partida)

    self.nivel = nivel
    self.modoDeJogo = modoDeJogo
    self.score = Score:new()
    self.maximoTentativas = 2
    self.tentativasRestantes = 2
    self.cartasViradasNoTurno = {}
    self.partidaFinalizada = false
    self.vitoria = false
    self.jogadorAtual = "humano"
    self.nomeJogador = "convidado"
    self.rodadaAtual = 1

    if modoDeJogo == "cooperativo" then
        self.tempoLimite = ({180, 150, 120, 90})[nivel] or 180
    elseif modoDeJogo == "solo" then
        self.tempoLimite = ({300, 360, 420, 480})[nivel] or 300
    elseif modoDeJogo == "competitivo" then
        self.tempoLimite = ({240, 300, 360, 420})[nivel] or 240
    else
        self.tempoLimite = 180
    end
    self.tempoRestante = self.tempoLimite

    local dh = DataHora:new()
    dh:atualizar()
    self.dataInicio = dh:formatarData()
    self.horaInicio = dh:formatarHora()

    local cartas = self:carregarCartasInterno()
    self.tabuleiro = Tabuleiro:new(nivel, cartas)

    self.adversarioIA = require("inteligencia_maquina.adversario"):new()
    self.adversarioIA:inicializarMemoria(self.tabuleiro.linhas, self.tabuleiro.colunas)

    if modoDeJogo == "cooperativo" then
        self.modoCooperativo = Cooperativo:new(self)
    elseif modoDeJogo == "solo" then
        self.modoSolo = Solo:new(self)
    elseif modoDeJogo == "competitivo" then
        self.modoCompetitivo = Competitivo:new(self)
    end

    return self
end

function Partida:carregarCartasInterno()
    local cartas = {}
    for i = 1, 12 do
        local carta = Carta:new(i, Config.deck[i])
        table.insert(cartas, carta)
    end
    return cartas
end

function Partida:mousepressed(x, y, button)
    if button == 1 and not self.partidaFinalizada then
        if self.modoDeJogo == "cooperativo" then
            return self:cliqueModoCooperativo(x, y)
        elseif self.modoDeJogo == "solo" then
            return self:cliqueModoSolo(x, y)
        elseif self.modoDeJogo == "competitivo" then
            return self:cliqueModoCompetitivo(x, y)
        else
            return self:cliqueGeral(x, y)
        end
    end
    return false
end

function Partida:cliqueModoCooperativo(x, y)
    if not self.modoCooperativo then return false end
    for _, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            return self.modoCooperativo:cliqueCarta(carta)
        end
    end
    return false
end

function Partida:cliqueModoSolo(x, y)
    if not self.modoSolo then return false end
    for _, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            return self.modoSolo:cliqueCarta(carta)
        end
    end
    return false
end

function Partida:cliqueModoCompetitivo(x, y)
    if not self.modoCompetitivo then return false end
    for _, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            return self.modoCompetitivo:cliqueCarta(carta)
        end
    end
    return false
end

function Partida:cliqueGeral(x, y)
    for _, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) and not carta.encontrada then
            if #self.cartasViradasNoTurno < 2 then
                carta:alternarLado()
                table.insert(self.cartasViradasNoTurno, carta)
                if #self.cartasViradasNoTurno == 2 then
                    self:verificaGrupoCartas()
                end
                return true
            end
        end
    end
    return false
end

function Partida:verificaGrupoCartas()
    local grupoFormado = true
    local imgPrimeira = self.cartasViradasNoTurno[1].imagemFrente
    for i = 2, #self.cartasViradasNoTurno do
        if self.cartasViradasNoTurno[i].imagemFrente ~= imgPrimeira then
            grupoFormado = false
            break
        end
    end
    if grupoFormado then
        self:adicionarAoScore()
        for _, carta in ipairs(self.cartasViradasNoTurno) do carta.encontrada = true end
        self.cartasViradasNoTurno = {}
    else
        self:desvirarCartasDoTurno()
    end
    if not grupoFormado or self.modoDeJogo == "competitivo" then
        self:trocaJogadorAtual()
    end
end

function Partida:adicionarAoScore()
    if self.cartasViradasNoTurno and #self.cartasViradasNoTurno > 0 then
        self.score:pontuarGrupoEncontrado(self.cartasViradasNoTurno)
    end
end

function Partida:desvirarCartasDoTurno()
    if self.cartasViradasNoTurno and #self.cartasViradasNoTurno > 0 then
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            carta:alternarLado()
        end
        self.cartasViradasNoTurno = {}
    end
end

function Partida:trocaJogadorAtual()
    self.jogadorAtual = (self.jogadorAtual == "humano") and "maquina" or "humano"
end

function Partida:update(dt)
    if not self.partidaFinalizada then
        self.tempoRestante = self.tempoRestante - dt
        if self.modoCooperativo then self.modoCooperativo:update(dt) end
        if self.modoSolo then self.modoSolo:update(dt) end
        if self.modoCompetitivo then self.modoCompetitivo:update(dt) end
        self:checkGameEnd()
    end
end

function Partida:finalizarPartida(vitoria)
    self.partidaFinalizada = true
    self.vitoria = vitoria
    DataHora:atualizar()
    if vitoria then
        local tempoGasto = self.tempoLimite - self.tempoRestante
        print((self.modoDeJogo == "solo" and "VITÓRIA! Parabéns! Você completou" or "VITÓRIA! Parabéns! Vocês completaram") .. " em " .. string.format("%.1f", tempoGasto) .. " segundos!")
        print("Pontuação final: " .. tostring(self.score))
        local bonusTempo = math.floor(self.tempoRestante * 10)
        self.score:adicionarAoScore(bonusTempo)
    else
        print("DERROTA! O tempo acabou!")
        print("Pontuação final: " .. tostring(self.score))
    end
end

function Partida:checkGameEnd()
    if self.tabuleiro:allCardsFound() then
        self:finalizarPartida(true)
    elseif self.tempoRestante <= 0 then
        self:finalizarPartida(false)
    end
end

function Partida:getStatusInfo()
    local info = {
        tempo = math.ceil(self.tempoRestante),
        score = self.score,
        cartasRestantes = self.tabuleiro.cartasRestantes,
        partidaFinalizada = self.partidaFinalizada,
        vitoria = self.vitoria,
        jogadorAtual = self.jogadorAtual
    }

    if self.modoCooperativo then
        for k, v in pairs(self.modoCooperativo:getStatus()) do info[k] = v end
    end
    if self.modoSolo then
        for k, v in pairs(self.modoSolo:getStatus()) do info[k] = v end
    end
    if self.modoCompetitivo then
        for k, v in pairs(self.modoCompetitivo:getStatus()) do info[k] = v end
    end

    return info
end

return Partida
