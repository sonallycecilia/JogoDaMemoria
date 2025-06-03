-- Classe estática para funcoes de utilidade em relação a matrizes
-- TODO: utilizar herança múltipla na criação de uma matriz 
require("inteligencia_maquina.utils.String")
require("inteligencia_maquina.utils.Array")
Matriz = {linhas = 0, colunas = 0}
Matriz.__index = Matriz

function Matriz:new(obj, linhas, colunas)
    obj = obj or {}
    linhas = linhas or #self
    colunas = colunas or #self[1]

    obj = {
        linhas = linhas,
        colunas = colunas
    }

    setmetatable(obj, Matriz)

    return obj
end

--TODO: Tratar matriz que possuem linhas com menos elementos que as outras
--TODO: Tratar execeçoes, colocar uma quantidade de linhas ou colunas diferentes da do obj matriz
function Matriz:exibir(nomeAtributo) 
    -- if (header ~= true) and (header ~= false) then
    --     header = false 
    -- end

    -- Só funciona se o objeto chamado tiver atributos para linhas e colunas, ou for uma matriz
    local instanciaMatriz = self
    local linhas = instanciaMatriz.linhas or #self
    local colunas = instanciaMatriz.colunas or #self[1]

    -- TODO: Utilizar outro método para isso
    -- Encontrar a maior string de cada coluna e armazena num array
        -- Cada indice do array se refere a uma coluna

    local maxTamColunas = {}
        -- Para cada coluna, percorrer todas as linhas
    for j = 1, self.colunas, 1 do 
        local maxTam = 0
        for i = 1, self.linhas, 1 do
            if (#tostring(self[i][j]) > maxTam) then
                maxTam = #tostring(self[i][j])
            end
        end
        maxTamColunas[j] = maxTam
    end

    --Exibir cada elemento da matriz adicionando o padding correto 
    for i = 1, linhas, 1 do
        for j = 1, colunas, 1 do
            -- Calcular quando de espaço extra deve ser adicionando
            local padding = maxTamColunas[j] - #tostring(self[i][j]) + 1
            io.write(self[i][j], String.new(" ", padding), "|")
        end
        io.write("\n")

        -- if i == 1 and header then -- Explicitar o cabeçalho
        --     for k = 1, #maxTamColunas, 1 do
        --         io.write(String.new("-", maxTamColunas[k] + 1),"|")
        --     end
        --     io.write("\n")
        -- end
        
    end
end




--{"Carlos", "35", "Sao Paulo", "Rua D"}
local matriz = {
    {"Nome", "Idade", "Cidade", "Endereco"},
    {"Joao", "30", "Salvador", "Rua A"},
    {"Maria", "25", "Rio de Janeiro", "Rua B"},
    {"Pedro Silva", "42", "Sao Paulo", "Rua C"},
}

matriz = Matriz:new(matriz, #matriz, #matriz[1])

matriz:exibir("id")
