local Partida = {}
Partida.__index = Partida

function Partida:new(modoDeJogo, nivel, cartas)
    local novaPartida = {
        modoDeJogo = modoDeJogo,
        tabuleiro = Tabuleiro:new(nivel, cartas),
        tempoLimite = 60, -- Tempo limite em segundos
        tempoRestante = 60,
        score = 0,
        maximoTentativas = 2,
        tentativasRestantes = 2,
    }
    setmetatable(novaPartida, self)

    return novaPartida
end



return Partida
