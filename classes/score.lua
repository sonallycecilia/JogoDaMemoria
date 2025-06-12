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
    return pontuacao
end

function Score:pontuarGrupoEncontrado(tamGrupoCartas)
    self.pontuacao = self.pontuacao + self.valorBase * tamGrupoCartas
    -- Adicionar pontuacao adicional com base no tempo ou um sistema de combo para pares encontrados em sequência
end

function Score:adicionarAoScore(pontos)
    self.pontuacao = self.pontuacao + pontos
end

return Score

