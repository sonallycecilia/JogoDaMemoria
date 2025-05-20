local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")

local LARGURA_TELA = love.graphics.getWidth()
local ALTURA_TELA = love.graphics.getHeight()

local Partida = {}
Partida.__index = Partida

function Partida:new(modoDeJogo, nivel)
    local cartas = self:carregarCartas()

    local novaPartida = {
        modoDeJogo = modoDeJogo,
        tempoLimite = 60, -- Tempo limite em segundos
        tempoRestante = 60,
        score = 0,
        maximoTentativas = 2,
        tentativasRestantes = 2,
        tabuleiro = Tabuleiro:new(nivel, cartas),
    }
    setmetatable(novaPartida, self)

    return novaPartida
end

function Partida:carregarCartas()
    local cartas = {
        Carta:new(1, "midia/images/cartas/fada.png"),
        Carta:new(2, "midia/images/cartas/naly.png"),
        Carta:new(3, "midia/images/cartas/elfa.png"),
        Carta:new(4, "midia/images/cartas/draenei.png"),
        Carta:new(5, "midia/images/cartas/borboleta.png"),
        Carta:new(6, "midia/images/cartas/lua.png"),
        Carta:new(7, "midia/images/cartas/coracao.png"),
        Carta:new(8, "midia/images/cartas/draenei.png"),
        Carta:new(9, "midia/images/cartas/flor.png"),
        Carta:new(10, "midia/images/cartas/gato.png"),
        Carta:new(11, "midia/images/cartas/pocao.png"),
        Carta:new(12, "midia/images/cartas/planta.png"),
    }
    return cartas
end

function Partida:atualizarTelaFundo()
    love.graphics.draw(Config.janela.IMAGEM_TELA_PARTIDA, 0, 0, 0)
end


return Partida
