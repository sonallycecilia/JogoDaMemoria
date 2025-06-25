Score = {}
Score.__index = Score

function Score:new(nivel)
    local novaScore = {
        nivel = nivel,
        pontuacao = 0, 
        valorBase = function (nivel) return (100* nivel) end
    }
    setmetatable(novaScore, Score)

    return novaScore
end

function Score:getPontuacao()
    return self.pontuacao
end

function Score:pontuarGrupoEncontrado(tamGrupoCartas)
    local base = self.valorBase(self.nivel or 1)
    self.pontuacao = self.pontuacao + base * tamGrupoCartas
end

function Score:adicionarPontuacao(pontos)
    self.pontuacao = self.pontuacao + pontos
end


return Score

