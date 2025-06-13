local Score = require("classes.utils.score")
Jogador = {}

Jogador.__index = Jogador

function Jogador:new(nivel)
    local novoJogador = {
        nome = "Convidado",
        paresEncontrados = 0,
        score = Score:new(nivel)
    }
    setmetatable(novoJogador, Jogador)
    return novoJogador
end

return Jogador