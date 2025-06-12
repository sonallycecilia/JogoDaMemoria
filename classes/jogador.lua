require("classes.utils.score")

Jogador = {
    nome = "Convidado",
    paresEncontrados = 0,
    score = Score:new("nivel")
}
Jogador.__index = Jogador

function Jogador:new(nivel)
    local novoJogador ={
        score = Score:new(nivel)
    }    

    setmetatable(novoJogador, Jogador)

    return novoJogador
end 