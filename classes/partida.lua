local Tabuleiro = require("classes.tabuleiro")
local Carta = require("classes.carta")
local Config = require("config")

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
    local cartas = {}
    for i = 0, 11 do
        local carta = Carta:new(i, Config.deck[i + 1])
        table.insert(cartas, carta)
    end
    return cartas
end


function Partida:atualizarTelaFundo()
    love.graphics.draw(Config.janela.IMAGEM_TELA_PARTIDA, 0, 0, 0)
end


return Partida
