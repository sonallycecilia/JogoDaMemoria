local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")
local DataHora = require("utils.dataHora")

local Partida = {}
Partida.__index = Partida

function Partida:new(modoDeJogo, nivel)
    local self = setmetatable({}, Partida)

    self.nivel = nivel
    self.modoDeJogo = modoDeJogo
    self.tempoLimite = 60 -- Tempo limite em segundos
    self.tempoRestante = 60
    
    self.score = 0
    --TODO: definir máximo de tentativos com base no nível, 2, 3, ou 4
    self.maximoTentativas = 2
    self.tentativasRestantes = 2

    DataHora = DataHora:new()
    DataHora:atualizar()
    self.dataInicio =  DataHora:formatarData()
    self.horaInicio = DataHora:formatarHora()
    self.dataFinal = nil
    self.horaFinal = nil
    
    self.tabuleiro = Tabuleiro:new(nivel, cartas)
    self.rodadaAtual = 1
    self.cartasViradasNoTurno = {} 
    self.partidaFinalizada = false
    self.jogadorAtual = "humano" or "maquina"--Jogador ou Máquina, jogador sempre começa jogando
    self.nomeJogador = "convidado"
    
    local cartas = self:carregarCartas()
    
    self.adversarioIA = require("inteligencia_maquina.adversario")
    self.adversarioIA:inicializarMemoria(self.partida.tabuleiro.linhas, self.partida.tabuleiro.colunas)

    return novaPartida
end

function Partida:carregarCartas()
    local cartas = {}
    for i = 0, 11 do
        local carta = Carta:new(i, Config.deck[i + 1])
        table.insert(cartas, carta)
    end
    return cartas
end

function Partida:verificaGrupoCartas()
    local grupoFormado = true -- É mais fácil verificar a condição de não serem um grupo
    local imgPrimeiraCarta = self.cartasViradasNoTurno[1].imagemFrente

    for i = 2, #self.cartasViradasNoTurno, 1 do
        if self.cartasViradasNoTurno[i].imagemFrente ~= imgPrimeiraCarta then
            grupoFormado = false
            break; -- Clean code? Pra que? O importante é funcionar, laço "bonito" é preciosismo 
        end
    end

    -- Transferir essa responsabilidade para um método validaGrupoFormado()
    if grupoFormado then
        -- ACERTOU
        self.partida.score = self.partida.score + #self.cartasViradasNoTurno * 100 -- Cada carta vale 100 pontos
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            self.partida.tabuleiro:removerGrupoEncontrado(self.cartasViradasNoTurno)
        end
        self.cartasViradasNoTurno = {}
    else
        -- ERROU
        self.timerCartasViradas = self.tempoParaVirarDeVolta -- Timer para desvirar
    end

    -- Troca de turno se errou, ou se o humano já jogou e acertou
    if not grupoFormado or self.partida.modoDeJogo == "competitivo" then
        if #self.cartasViradasNoTurno == 0 then
            self:trocaJogadorAtual()
        end
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

function Partida:finalizarPartida()
    print("Partida finalizada!") -- debug
    local modoDeJogo = self.partida.modoDeJogo
    local dificuldade = self.partida.nivel -- Substituir 1, 2, 3, 4 por FACIL, MEDIO, DIFICIL, EXTREMO. Utilizar a classe nivelDeJogo
    local pontuacao = self.partida.score
    local dataInicio = self.dataInicio
    local horaInicio = self.horaInicio
    local dataFinal = DataHora:formatarData()
    local horaFinal = DataHora:formatarHora()
    
    local nomeJogador = nil
    -- Abrir Nova janela para o jogador adicionar o nome
    -- local nomejogador = self.manager:setLayar("telaNomeJogador"):inputNome()
    
    -- TODO: dar merge com o que foi feito no BD 
    Ranking:adicionarResultado(nomeJogador, dataInicio, horaInicio, dataFinal, horaFinal, pontuacao, dificuldade, modoDeJogo )

    -- TODO: criar rankingLayer e adiconar ao layersMap
    self.manager:setLayer("rankingLayer")
end


return Partida
