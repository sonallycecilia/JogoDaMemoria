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
    if not self.modoCooperativo then
        return false
    end
    
    local cartaClicada = nil
    for i, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            cartaClicada = carta
            break
        end
    end
    
    if not cartaClicada then
        return false
    end
    
    return self.modoCooperativo:cliqueCarta(cartaClicada)
end

function Partida:cliqueModoSolo(x, y)
    if not self.modoSolo then
        return false
    end
    
    local cartaClicada = nil
    for i, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            cartaClicada = carta
            break
        end
    end
    
    if not cartaClicada then
        return false
    end
    
    return self.modoSolo:cliqueCarta(cartaClicada)
end

function Partida:cliqueModoCompetitivo(x, y)
    if not self.modoCompetitivo then
        return false
    end
    
    local cartaClicada = nil
    for i, carta in ipairs(self.tabuleiro.cartas) do
        if carta:clicada(x, y) then
            cartaClicada = carta
            break
        end
    end
    
    if not cartaClicada then
        return false
    end
    
    return self.modoCompetitivo:cliqueCarta(cartaClicada)
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
    local imgPrimeiraCarta = self.cartasViradasNoTurno[1].imagemFrente
    
    for i = 2, #self.cartasViradasNoTurno do
        if self.cartasViradasNoTurno[i].imagemFrente ~= imgPrimeiraCarta then
            grupoFormado = false
            break
        end
    end
    
    if grupoFormado then
        self:adicionarAoScore()
        self:removerCartasViradasNoTurno()
    else
        self.timerCartasViradas = self.tempoParaVirarDeVolta
        self:desvirarCartasDoTurno()
        self.cartasViradasNoTurno = {}
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            carta.encontrada = true
        end
    end
    
    if (not grupoFormado) or (self.modoDeJogo == "competitivo") then
        if #self.cartasViradasNoTurno == 0 then
            self:trocaJogadorAtual()
        end
    end
end

function Partida:update(dt)
    if not self.partidaFinalizada then
        self.tempoRestante = self.tempoRestante - dt
        
        if self.modoDeJogo == "cooperativo" and self.modoCooperativo then
            self.modoCooperativo:update(dt)
        elseif self.modoDeJogo == "solo" and self.modoSolo then
            self.modoSolo:update(dt)
        elseif self.modoDeJogo == "competitivo" and self.modoCompetitivo then
            self.modoCompetitivo:update(dt)
        end
        
        self:checkGameEnd()
    end
end

function Partida:adicionarAoScore()
    local ehNil = ehNil(self.cartasViradasNoTurno)  
    if not ehNil then
        self.score:pontuarGrupoEncontrado(self.cartasViradasNoTurno)
    end
end

function Partida:desvirarCartasDoTurno()
    local ehNil = ehNil(self.cartasViradasNoTurno)
    if not ehNil then
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            carta:alternarLado()
        end
        self.cartasViradasNoTurno = {}
    end
end

function Partida:trocaJogadorAtual()
    if self.jogadorAtual == "humano" then
        self.jogadorAtual = "maquina"
    end
    if self.jogadorAtual == "maquina" then
        self.jogadorAtual = "humano"
    end
end

function Partida:finalizarPartida(vitoria)
    self.partidaFinalizada = true
    self.vitoria = vitoria
    
    local DataHora = require("classes.utils.dataHora")
    DataHora = DataHora:new()
    DataHora:atualizar()
    
    if vitoria then
        local bonusTempo = math.floor(self.tempoRestante * 10)
        self.score:adicionarAoScore(bonusTempo)
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
        vitoria = self.vitoria
    }
    
    if self.modoDeJogo == "cooperativo" and self.modoCooperativo then
        local statusCooperativo = self.modoCooperativo:getStatus()
        for k, v in pairs(statusCooperativo) do
            info[k] = v
        end
    elseif self.modoDeJogo == "solo" and self.modoSolo then
        local statusSolo = self.modoSolo:getStatus()
        for k, v in pairs(statusSolo) do
            info[k] = v
        end
    elseif self.modoDeJogo == "competitivo" and self.modoCompetitivo then
        local statusCompetitivo = self.modoCompetitivo:getStatus()
        for k, v in pairs(statusCompetitivo) do
            info[k] = v
        end
    end
    
    return info
end

function Partida:draw()
    self.tabuleiro:draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))

    local info = self:getStatusInfo()
    local y = 10

    love.graphics.print("Tempo: " .. math.floor(info.tempo / 60) .. ":" .. string.format("%02d", info.tempo % 60), 10, y)
    y = y + 25

    if self.modoDeJogo == "competitivo" then
        love.graphics.print("VOCÊ: " .. (info.scoreHumano or 0) .. " pts", 10, y)
        y = y + 25
        love.graphics.print("IA: " .. (info.scoreIA or 0) .. " pts", 10, y)
        y = y + 25
    else
        love.graphics.print("Pontos: " .. tostring(info.score), 10, y)
        y = y + 25
    end

    if self.modoDeJogo == "cooperativo" then
        if info.multiplicador and info.multiplicador > 1 then
            love.graphics.print("Multiplicador: " .. string.format("%.1f", info.multiplicador) .. "x", 10, y)
            y = y + 25
        end

        if info.paresConsecutivos and info.paresConsecutivos > 1 then
            love.graphics.print("Sequência: " .. tostring(info.paresConsecutivos) .. " pares", 10, y)
            y = y + 25
        end

        if info.vezIA then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("IA pensando...", 10, y)
            love.graphics.setColor(1, 1, 1)
        end

    elseif self.modoDeJogo == "solo" then
        if info.multiplicador and info.multiplicador > 1 then
            love.graphics.print("Multiplicador: " .. string.format("%.1f", info.multiplicador) .. "x", 10, y)
            y = y + 25
        end

        if info.gruposConsecutivos and info.gruposConsecutivos > 1 then
            love.graphics.print("Sequência: " .. tostring(info.gruposConsecutivos) .. " grupos", 10, y)
            y = y + 25
        end
        
    elseif self.modoDeJogo == "competitivo" then
        if info.jogadorAtual == "HUMANO" then
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("SUA VEZ!", 10, y)
        else
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("VEZ DA IA...", 10, y)
        end
        love.graphics.setColor(1, 1, 1)
        y = y + 25
        
        love.graphics.print("Grupos: VOCÊ " .. (info.gruposHumano or 0) .. " x " .. (info.gruposIA or 0) .. " IA", 10, y)
        y = y + 25
        
        if info.scoreHumano and info.scoreIA then
            if info.scoreHumano > info.scoreIA then
                love.graphics.setColor(0, 1, 0)
                love.graphics.print("VOCÊ ESTÁ GANHANDO!", 10, y)
            elseif info.scoreIA > info.scoreHumano then
                love.graphics.setColor(1, 0, 0)
                love.graphics.print("IA ESTÁ GANHANDO...", 10, y)
            else
                love.graphics.setColor(1, 1, 0)
                love.graphics.print("EMPATE!", 10, y)
            end
            love.graphics.setColor(1, 1, 1)
        end
    end

    if self.partidaFinalizada then
        local largura = love.graphics.getWidth()
        local altura = love.graphics.getHeight()

        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, largura, altura)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(40))
        
        local texto
        if self.modoDeJogo == "competitivo" and self.modoCompetitivo then
            local resultado = self.modoCompetitivo:obterResultadoFinal()
            if resultado.vencedor == "HUMANO" then
                texto = "VITÓRIA!"
                love.graphics.setColor(0, 1, 0)
            elseif resultado.vencedor == "IA" then
                texto = "DERROTA!"
                love.graphics.setColor(1, 0, 0)
            else
                texto = "EMPATE!"
                love.graphics.setColor(1, 1, 0)
            end
        else
            texto = self.vitoria and "VITÓRIA!" or "DERROTA!"
            if self.vitoria then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(1, 0, 0)
            end
        end
        
        local fonte = love.graphics.getFont()
        local textoLargura = fonte:getWidth(texto)
        love.graphics.print(texto, (largura - textoLargura) / 2, altura / 2 - 50)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(20))
        
        local pontuacao
        if self.modoDeJogo == "competitivo" and info.scoreHumano and info.scoreIA then
            pontuacao = "VOCÊ: " .. info.scoreHumano .. " pts | IA: " .. info.scoreIA .. " pts"
        else
            pontuacao = "Pontuação: " .. tostring(info.score)
        end
        
        local pontuacaoLargura = love.graphics.getFont():getWidth(pontuacao)
        love.graphics.print(pontuacao, (largura - pontuacaoLargura) / 2, altura / 2 + 10)
    end
end

return Partida