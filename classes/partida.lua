local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")
local Score = require("classes.score")
local Validacao = require("classes.utils.validacao")
local DataHora = require("classes.utils.dataHora")
local Cooperativo = require("classes.modos.cooperativo")
local Solo = require("classes.modos.solo")
local EhNil = require("classes.utils.validacao")

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
    print("=== DEBUG CLIQUE ===")
    print("Posição:", x, y, "Botão:", button)
    print("Modo de jogo:", self.modoDeJogo)
    print("Partida finalizada:", self.partidaFinalizada)

    if button == 1 and not self.partidaFinalizada then -- Clique esquerdo
        -- Verifica clique em botões
        if self.botoes then
            for _, botao in ipairs(self.botoes) do
                botao:mousepressed(x, y, button)
                if botao.mouseSobre then
                    print("Botão clicado:", botao.texto or "<imagem>")
                    return true
                end
            end
        end

        -- Caso nenhum botão tenha sido clicado, verifica o modo de jogo
        if self.modoDeJogo == "cooperativo" then
            return self:cliqueModoCooperativo(x, y)
        elseif self.modoDeJogo == "solo" then
            print("Chamando clique solo...")
            return self:cliqueModoSolo(x, y)
        else
            print("Chamando clique geral...")
            return self:cliqueGeral(x, y)
        end
    end

    print("Clique ignorado")
    return false
end



function Partida:cliqueModoCooperativo(x, y)
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

function Partida:verificaGrupoCartas()
    -- Método original para outros modos
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
        self.timerCartasViradas = self.tempoParaVirarDeVolta -- Timer para desvirar
        self:desvirarCartasDoTurno()
        self.cartasViradasNoTurno = {}
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            carta.encontrada = true
        end
    end
    --Removi os returns se não os métodos abaixo não seria chamados
    if (not grupoFormado) or (self.modoDeJogo == "competitivo") then
        if #self.cartasViradasNoTurno == 0 then
            self:trocaJogadorAtual()
        end
    end

end

function Partida:update(dt)
    if not self.partidaFinalizada then
        self.tempoRestante = self.tempoRestante - dt
        
        -- Atualiza modo específico
        if self.modoDeJogo == "cooperativo" and self.modoCooperativo then
            self.modoCooperativo:update(dt)
        elseif self.modoDeJogo == "solo" and self.modoSolo then
            self.modoSolo:update(dt)
        end
        
        self:checkGameEnd()
    end
end

function Partida:adicionarAoScore()
    local ehNil = EhNil(self.cartasViradasNoTurno)  
    if not ehNil then
        self.score:pontuarGrupoEncontrado(self.cartasViradasNoTurno)
    end
end

function Partida:desvirarCartasDoTurno()
    local ehNil = EhNil(self.cartasViradasNoTurno)
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
    print("Partida finalizada!") -- debug
    local modoDeJogo = self.modoDeJogo
    local dificuldade = self.nivel -- Substituir 1, 2, 3, 4 por FACIL, MEDIO, DIFICIL, EXTREMO. Utilizar a classe nivelDeJogo
    local pontuacao = self.score
    local dataInicio = self.dataInicio
    local horaInicio = self.horaInicio
    self.partidaFinalizada = true
    self.vitoria = vitoria
    
    local DataHora = require("classes.utils.dataHora")
    DataHora = DataHora:new()
    DataHora:atualizar()
    local dataFinal = DataHora:formatarData()
    local horaFinal = DataHora:formatarHora()
    
    if vitoria then
        local tempoGasto = self.tempoLimite - self.tempoRestante
        local mensagem = self.modoDeJogo == "solo" and "VITÓRIA! Parabéns! Você completou" or "VITÓRIA! Parabéns! Vocês completaram"
        print(mensagem .. " em " .. string.format("%.1f", tempoGasto) .. " segundos!")
        print("PonEhNilo final: " .. tostring(self.score) .. " pontos")
        
        -- Bonus por tempo restante
        local bonusTempo = math.floor(self.tempoRestante * 10)
        self.score:adicionarAoScore(bonusTempo)
        if bonusTempo > 0 then
            print("Bônus de tempo: +" .. tostring(bonusTempo) .. " pontos")
        end
    else
        print("DERROTA! O tempo acabou!")
        print("Pontuação final: " .. tostring(self.score) .. " pontos")
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
    
    -- Adiciona informações específicas do modo cooperativo
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

    -- === TELA DE FIM DE PARTIDA ===
    if self.partidaFinalizada then
        local largura = love.graphics.getWidth()
        local altura = love.graphics.getHeight()

        -- Fundo escuro semi-transparente
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, largura, altura)

        -- Texto principal
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(40))
        local texto = self.vitoria and "VITÓRIA!" or "DERROTA!"
        local fonte = love.graphics.getFont()
        local textoLargura = fonte:getWidth(texto)
        love.graphics.print(texto, (largura - textoLargura) / 2, altura / 2 - 50)

        -- Pontuação final
        love.graphics.setFont(love.graphics.newFont(20))
        local pontuacao = "Pontuação: " .. tostring(info.score)
        local pontuacaoLargura = love.graphics.getFont():getWidth(pontuacao)
        love.graphics.print(pontuacao, (largura - pontuacaoLargura) / 2, altura / 2 + 10)
    end
end

return Partida
