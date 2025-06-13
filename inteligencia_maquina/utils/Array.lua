Array = {type = ""}
Array.__index = {}

function Array.soma(arr)
    local soma = 0
    for i = 1, #arr, 1 do
        soma = soma  + arr[i]
    end
    return soma
end

function Array.exist(arr, elemento)
    local result = false
    for i = 1, #arr, 1 do
        if(arr[i] == elemento) then
            result = true
        end
    end
    return result
end

--[[
    Conversão de um array unidimensional para um array bidimensional.
    Retorna o indice no array linear com base nas linhas e colunas da
    matriz virtual
]]--
function Array.arrParaMatrizindice(linhaAtual, colunaAtual, numColunas)
    local indice =  ((linhaAtual - 1) * numColunas) + colunaAtual
    return indice
end

--[[
    Conversão de um array unidimensional para um array bidimensional.
    Retorna a linha da matriz virtual com base no índice do array linear
]]--
function Array.arrParaMatrizlinha(indice, numColunas)
    local linha = math.floor((indice - 1)/numColunas) + 1
    return linha
end

--[[
    Conversão de um array unidimensional para um array bidimensional.
    Retorna a coluna da matriz virtual com base no índice do array linear
]]--
function Array.arrParaMatrizColuna(indice, numColunas)
    local coluna = ((indice - 1) % numColunas) + 1
    return coluna
end

-- -- TESTE
-- local numlinhas = 3
-- local numcolunas = 4
-- local totalElementos = numlinhas * numcolunas

-- local arr = {}

-- -- Inicializando índices do array linear
-- for i = 1, (totalElementos) do
--     arr[i] = nil 
-- end

-- print("--- Escrevendo valores na matriz virtual ---")
-- for linha = 1, numlinhas do
--     for coluna = 1, numcolunas do
--         local valor = (linha * 100) + coluna 
        
--         local indice = Array.arrParaMatrizindice(linha, coluna, numcolunas)
        
--         arr[indice] = valor
--         print(string.format("Escrevendo valor %d na posicao (%d,%d) -> indice %d", valor, linha, coluna, indice))
--     end
-- end

-- print("\nArray Unidimensional Resultante:")
-- for i = 1, #arr do 
--     local val = arr[i]
--     io.write(string.format("%s ", tostring(val)))
-- end
-- print("\n")

-- print("--- Lendo valores da matriz virtual ---")
-- for linha = 1, numlinhas do
--     for coluna = 1, numcolunas do 
--         -- Calcula o índice unidimensional para leitura
--         local indice = Array.arrParaMatrizindice(linha, coluna, numcolunas)
        
--         local valor_lido = arr[indice]
--         print(string.format("Lendo valor %s da posicao (%d,%d) -> indice %d", tostring(valor_lido), linha, coluna, indice))
--     end
-- end

-- --- Acessando um elemento específico com base na linha e coluna---
-- local linha = 2
-- local coluna = 3
-- local indice = Array.arrParaMatrizindice(linha, coluna, numcolunas)
-- local valor = arr[indice]
-- print(string.format("\nValor na posicao (%d,%d): %s", linha, coluna, tostring(valor)))

-- -- Iterando no Array com base na linha e coluna
-- print("\n--- Convertendo índices unidimensionais para (linha, coluna) ---")
-- for i = 1, totalElementos do
--     local linhaReconstruida = Array.arrParaMatrizlinha(i, numcolunas)
--     local colunaReconstruida = Array.arrParaMatrizColuna(i, numcolunas)
--     print(string.format("indice %d corresponde a (%d,%d)", i, linhaReconstruida, colunaReconstruida))
-- end
-- -- FIM DO TESTE

return Array