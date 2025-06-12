local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")
local DataHora = require("utils.dataHora")
local Score = require("classes.score")
local Validacao = require("classes.utils.validacao")

local Partida = {
    nivel = nil,
    modoDeJogo = nil,
    tempoLimite = 60, -- Tempo limite em segundos
    tempoRestante = 60,
    score = Score:new(),
    maximoTentativas = 2,
    tentativasRestantes = 2,
    DataHora = nil,
    dataInicio = nil, 
    horaInicio = nil,
    dataFinal = nil,
    horaFinal = nil,
    tabuleiro = nil,
    rodadaAtual = 1,
    cartasViradasNoTurno = {},
    partidaFinalizada = false,
    jogadorAtual = "humano" or "maquina", -- jogador sempre começa jogando
    nomeJogador = "convidado",
    cartas = nil,
    adversarioIA = nil,   
    seleciontarCartaCongela = false,
    cartaCongelada = nil,
    tempoGelo = 0
}
Partida.__index = Partida

function Partida:new(modoDeJogo, nivel)
    local self = setmetatable({}, Partida)

    self.score = Score:new()

    self.nivel = nivel
    self.modoDeJogo = modoDeJogo
    self.tempoLimite = 300 -- Tempo limite em segundos
    self.tempoRestante = self.tempoLimite
    
    --TODO: definir máximo de tentativos com base no nível, 2, 3, ou 4
    self.maximoTentativas = 2
    self.tentativasRestantes = 2

    DataHora = DataHora:new()
    DataHora:atualizar()
    self.dataInicio =  DataHora:formatarData()
    self.horaInicio = DataHora:formatarHora()
    self.dataFinal = nil
    self.horaFinal = nil
    self.rodadaAtual = 1
    self.cartasViradasNoTurno = {} 
    self.partidaFinalizada = false
    self.jogadorAtual = "humano" or "maquina" -- jogador sempre começa jogando
    self.nomeJogador = nil

    local cartas = self:carregarCartas()
    self.tabuleiro = Tabuleiro:new(nivel, cartas)
    self.adversarioIA = require("inteligencia_maquina.adversario")
    self.adversarioIA:inicializarMemoria(self.tabuleiro.linhas, self.tabuleiro.colunas)

    
    return self
end

function Partida:carregarCartas()
    local cartas = {}
    local carta
    for i = 1, 12 do
        carta = Carta:new(i, Config.deck[i])
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
            break;
        end
    end

    -- Transferir essa responsabilidade para um método validaGrupoFormado()
    if grupoFormado then
        self:adicionarAoScore()
        self:removerCartasViradasNoTurno()
    else
        self.timerCartasViradas = self.tempoParaVirarDeVolta -- Timer para desvirar
        self:desvirarCartasDoTurno()
        self.cartasViradasNoTurno = {}
    end

    -- Troca de turno se errou, ou se o humano já jogou e acertou
    if (not grupoFormado) or (self.modoDeJogo == "competitivo") then
        if #self.cartasViradasNoTurno == 0 then
            self:trocaJogadorAtual()
        end
    end
end

function Partida:adicionarAoScore()
    local ehNil = Validacao:ehNil(self.cartasViradasNoTurno)  
    if not ehNil then
        self.score:pontuarGrupoEncontrado(self.cartasViradasNoTurno)
    end
end

function Partida:desvirarCartasDoTurno()
    local ehNil = Validacao:ehNil(self.cartasViradasNoTurno)
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

function Partida:finalizarPartida()
    print("Partida finalizada!") -- debug
    local modoDeJogo = self.modoDeJogo
    local dificuldade = self.nivel -- Substituir 1, 2, 3, 4 por FACIL, MEDIO, DIFICIL, EXTREMO. Utilizar a classe nivelDeJogo
    local pontuacao = self.score
    local dataInicio = self.dataInicio
    local horaInicio = self.horaInicio
    local dataFinal = DataHora:formatarData()
    local horaFinal = DataHora:formatarHora()
    
    local nomeJogador = nil
    -- Abrir Nova janela para o jogador adicionar o nome
    -- local nomejogador = self.manager:setLayar("telaNomeJogador"):inputNome()
    
    -- TODO: dar merge com o que foi feito no BD 
   -- ranking:adicionarResultado(nomeJogador, dataInicio, horaInicio, dataFinal, horaFinal, pontuacao, dificuldade, modoDeJogo )

    -- TODO: criar rankingLayer e adiconar ao layersMap
    --self.manager:setLayer("rankingLayer")
end

return Partida
