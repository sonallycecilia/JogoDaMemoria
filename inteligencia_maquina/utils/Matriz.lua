-- Classe estática para funcoes de utilidade em relação a matrizes
-- TODO: utilizar herança múltipla na criação de uma matriz 
require("inteligencia_maquina.utils.String")
require("inteligencia_maquina.utils.Array")
Matriz = {linhas = 0, colunas = 0}
Matriz.__index = Matriz

function Matriz:new(obj, linhas, colunas)
    obj = obj or {}
    linhas = linhas or #self
    colunas = colunas or (#self[1] or 0)

    obj.linhas = linhas
    obj.colunas = colunas

    setmetatable(obj, Matriz)

    return obj
end

--TODO: Tratar matriz que possuem linhas com menos elementos que as outras
--TODO: Tratar execeçoes, colocar uma quantidade de linhas ou colunas diferentes da do obj matriz
function Matriz:exibir() 
    -- if (header ~= true) and (header ~= false) then
    --     header = false 
    -- end

    -- Só funciona se o objeto chamado tiver atributos para linhas e colunas, ou for uma matriz
    -- local instanciaMatriz = self
    -- local linhas = instanciaMatriz.linhas or #self
    -- local colunas = instanciaMatriz.colunas or #self[1]

    -- TODO: Utilizar outro método para isso
    -- Encontrar a maior string de cada coluna e armazena num array
        -- Cada indice do array se refere a uma coluna

    local maxTamColunas = {}
        -- Para cada coluna, percorrer todas as linhas
    for j = 1, self.colunas, 1 do 
        local maxTam = 0
        for i = 1, self.linhas, 1 do
            if (self[i] == nil) and (self[i][j] == nil) then
                --Evitar erro ao lidar com matrizes incompletas, valores nulos
            else
                if (#tostring(self[i][j]) > maxTam) then
                    maxTam = #tostring(self[i][j])
                end
            end
        maxTamColunas[j] = maxTam
        end
    end

    --Exibir cada elemento da matriz adicionando o padding correto 
    local padding = 0
    local valorCelulaOriginal = ""
    local valorCelulaExibido
    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            valorCelulaOriginal = self[i] and self[i][j]

            -- Poderia muito bem ser substituido por um if para facilitar a leitura
            -- mas eu gosto da avaliação de curto-circuito de Lua :)
            valorCelulaExibido = 
            ((valorCelulaOriginal == nil or valorCelulaOriginal == "") and "NIL") or valorCelulaOriginal  

            padding = maxTamColunas[j] - #tostring(valorCelulaExibido) + 1
            io.write(valorCelulaExibido, String.new(" ", padding), "|")
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
    {"Maria", "25", "Rio de Janeiro", ""},
    {"Pedro Silva", "42", "", "Rua C"},
}

matriz = Matriz:new(matriz, #matriz, #matriz[1])

-- io.write(#matriz," ", #matriz[1], "\n")
-- for i = 1, #matriz, 1 do
--     for j = 1, #matriz[1], 1 do
--         io.write(matriz[i][j], " ")
--     end
--     io.write("\n")
-- end

matriz:exibir()

