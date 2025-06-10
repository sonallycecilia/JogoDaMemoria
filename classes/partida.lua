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
        rodadaAtual = 1,
    }
    setmetatable(novaPartida, self)

    --TODO: definir máximo de tentativos com base no nível, 2, 3, ou 4

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

return Partida
