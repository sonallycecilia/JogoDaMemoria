local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")
local Score = require("classes.score")
local DataHora = require("classes.utils.dataHora")
local Cooperativo = require("classes.modos.cooperativo")
local Competitivo = require("classes.modos.competitivo")
local Solo = require("classes.modos.solo")
local EhNil = require("classes.utils.validacao")

local Partida = {}
Partida.__index = Partida

local debugCount = 0
local function logTabuleiroStatus(context)
    debugCount = debugCount + 1
    local status = "nil"
    if Partida and Partida.tabuleiro then
        status = "table: " .. tostring(Partida.tabuleiro) -- Ou um ID único se Tabuleiro tivesse um
    end
    print(string.format("[DEBUG TRACE] %s: Tabuleiro status: %s (Chamada %d)", context, status, debugCount))
end

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

    -- A partida não deveria acessar as cartas diretamente, deveria fazer isso por meio de tabuleiro 
    self.tabuleiro = Tabuleiro:new(nivel)
    print("[Partida] Tabuleiro:", self.tabuleiro)
    self.adversarioIA = require("inteligencia_maquina.adversario"):new()
    self.adversarioIA:inicializarMemoria(self.tabuleiro.linhas, self.tabuleiro.colunas)

    if modoDeJogo == "cooperativo" then
        self.modoCooperativo = Cooperativo:new(self)
    end
    if modoDeJogo == "solo" then
        self.modoSolo = Solo:new(self)
    elseif modoDeJogo == "competitivo" then
        self.modoCompetitivo = Competitivo:new(self)
    end
    if modoDeJogo == "competitivo" then
        --self.modoCompetitivo = Competitivo:new(self)
    end

    return self
end

function Partida:mousepressed(x, y, button)
    print("=== DEBUG CLIQUE ===")
    print("Posição:", x, y, "Botão:", button)
    print("Modo de jogo:", self.modoDeJogo)
    print("Partida finalizada:", self.partidaFinalizada)
    
    if button == 1 and not self.partidaFinalizada then -- Clique esquerdo
        if self.modoDeJogo == "cooperativo" then
            print("Chamando clique cooperativo...")
            return self:cliqueModoCooperativo(x, y)
        end
        if self.modoDeJogo == "solo" then
            print("Chamando clique solo...")
            return self:cliqueModoSolo(x, y)
        end
        if self.modoDeJogo == "competitivo" then
            print("Chamando clique geral...")
            return self:cliqueGeral(x, y)
        end
    end

    print("Clique ignorado")
    return false
end

function Partida:cliqueModoCooperativo(x, y)
    -- Check nil
    if not self.modoCooperativo then
        return false
    end
    
    -- Busca a carta clicada
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
    
    -- Busca a carta clicada
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

function Partida:cliqueGeral(x, y)
    -- Implementação para outros modos de jogo
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


function Partida:update(dt)

    local ganhou 

    if not self.partidaFinalizada then
        self.tempoRestante = self.tempoRestante - dt
        
        -- Atualiza modo específico
        if self.modoDeJogo == "cooperativo" and self.modoCooperativo then
            self.modoCooperativo:update(dt)
        end
        if self.modoDeJogo == "solo" and self.modoSolo then
            self.modoSolo:update(dt)
        end
        if self.modoDeJogo == "competitivo" then
            self.modoCompetitivo:update(dt)
        end
        
        self:checkGameEnd()
    end
end

function Partida:adicionarPontuacao()

    local ehNil = EhNil(self.cartasViradasNoTurno)  
    if not ehNil then
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
 
        if bonusTempo > 0 then
            print("Bônus de tempo: +" .. tostring(bonusTempo) .. " pontos")
        end
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
    
    -- Adiciona informações específicas do modo cooperativo
    if self.modoDeJogo == "cooperativo" and self.modoCooperativo then
        local statusCooperativo = self.modoCooperativo:getStatus()
        for k, v in pairs(statusCooperativo) do
            info[k] = v
        end
    end
    if self.modoDeJogo == "solo" and self.modoSolo then
        local statusSolo = self.modoSolo:getStatus()
        for k, v in pairs(statusSolo) do
            info[k] = v
        end
    end
  
    if self.modoDeJogo == "competitivo" and self.modoCompetitivo then
        local statusSolo = self.modoCompetitivo:getStatus()
        for k, v in pairs(statusSolo) do
            info[k] = v
        end
    end
    
    return info
end

function Partida:draw()
    self.tabuleiro:draw()

    -- Cor padrão e fonte
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))

    local info = self:getStatusInfo()
    local y = 10

    -- === INFO GERAL: tempo + pontos ===
    love.graphics.print("Tempo: " .. math.floor(info.tempo / 60) .. ":" .. string.format("%02d", info.tempo % 60), 10, y)
    y = y + 25

    love.graphics.print("Pontos: " .. tostring(info.score), 10, y)
    y = y + 25

    -- === INFO ESPECÍFICA: Cooperativo ou Solo ===
    if self.modoDeJogo == "cooperativo" then
        if info.multiplicador > 1 then
            love.graphics.print("Multiplicador: " .. string.format("%.1f", info.multiplicador) .. "x", 10, y)
            y = y + 25
        end
        if info.paresConsecutivos > 1 then
            love.graphics.print("Sequência: " .. tostring(info.paresConsecutivos) .. " pares", 10, y)
            y = y + 25
        end

        if info.vezIA then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("IA pensando...", 10, y)
            love.graphics.setColor(1, 1, 1)
        end

    elseif self.modoDeJogo == "solo" then
        if info.multiplicador > 1 then
            love.graphics.print("Multiplicador: " .. string.format("%.1f", info.multiplicador) .. "x", 10, y)
            y = y + 25
        end

        if info.gruposConsecutivos > 1 then
            love.graphics.print("Sequência: " .. tostring(info.gruposConsecutivos) .. " grupos", 10, y)
            y = y + 25
        end
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