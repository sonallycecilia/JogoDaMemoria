require("inteligencia_maquina.cartaTeste")
require("inteligencia_maquina.utils.String")

local Tabuleiro = {
    cartas = {}, 
    nivel = 1, 
    linhas = 4, 
    colunas = 6
}
Tabuleiro.__index = Tabuleiro

function Tabuleiro:new(lin, col, vetorCartas) 
    lin = 4 -- Fixa o numero de linhas 
    col = 6 -- Fixa o tamaho de colunas
    local novoTabuleiro = {
        cartas = {},
        nivel = 1,
        linhas = lin, 
        colunas = col
    }
    novoTabuleiro.cartas = vetorCartas

    local linha = {}
    local indiceCarta = 1
    for i = 1, lin, 1 do
        for j = 1, col, 1 do
            linha[j] = vetorCartas[indiceCarta]
            indiceCarta = indiceCarta + 1
        end
        novoTabuleiro[i] = linha
        linha = {}
    end
    setmetatable(novoTabuleiro, Tabuleiro)

    return novoTabuleiro
end

function Tabuleiro:exibir(nomeAtributo) 
    nomeAtributo = nomeAtributo or "id"
    local maxTamColunas = self:getMaxStringColunas(nomeAtributo) 
    --Exibir cada elemento da matriz adicionando o padding correto 
    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            -- Calcular quando de espaço extra deve ser adicionando
            local padding = maxTamColunas[j] - #tostring(self[i][j][nomeAtributo]) + 1
            io.write(self[i][j][nomeAtributo], String.new(" ", padding), "|")
        end
        io.write("\n")
    end
end

function Tabuleiro:getMaxStringColunas(nomeAtributo)
    -- Cada indice do array se refere a uma coluna
    local maxTamColunas = {}
        -- Para cada coluna, percorrer todas as linhas
    for j = 1, self.colunas, 1 do 
        local maxTam = 0
        for i = 1, self.linhas, 1 do
            if (#tostring((self[i][j])[nomeAtributo]) > maxTam) then
                maxTam = #tostring((self[i][j])[nomeAtributo])
            end
        end
        maxTamColunas[j] = maxTam
    end

    return maxTamColunas
end

function Tabuleiro:gerarCopiaDeCartas(dadosCartas)
    local numCopia = self.nivel + 1  -- Nível 1 gera 2 cópias, Nível 2 gera 3 cópias, etc.
    -- Para cada carta recebida, gera o número adequado de cópias
    for _, carta in ipairs(dadosCartas) do
        if carta then
            for i = 1, numCopia do
                local copia = self:gerarCopiaUnica(carta)
                table.insert(self.cartas, copia)
            end
        end
    end
end

function Tabuleiro:gerarCopiaUnica(cartaOriginal)
    return CartaTeste:new(cartaOriginal.id, cartaOriginal.pathImagem)
end

local vetorCartas = {
    CartaTeste:new(1,"bomba"),
    CartaTeste:new(2,"borboleta"),
    CartaTeste:new(3,"cogumelo"),
    CartaTeste:new(4,"coracao"),
    CartaTeste:new(5,"draenei"),
    CartaTeste:new(6,"elfa"),
    CartaTeste:new(7,"fada"),
    CartaTeste:new(8,"flor"),
    CartaTeste:new(9,"gato"),
    CartaTeste:new(10,"lua"),
    CartaTeste:new(11,"nally"),
    CartaTeste:new(12,"planta"),
    CartaTeste:new(1,"bomba"),
    CartaTeste:new(2,"borboleta"),
    CartaTeste:new(3,"cogumelo"),
    CartaTeste:new(4,"coracao"),
    CartaTeste:new(5,"draenei"),
    CartaTeste:new(6,"elfa"),
    CartaTeste:new(7,"fada"),
    CartaTeste:new(8,"flor"),
    CartaTeste:new(9,"gato"),
    CartaTeste:new(10,"lua"),
    CartaTeste:new(11,"nally"),
    CartaTeste:new(12,"planta")
}

local tab1 = Tabuleiro:new(4,6,vetorCartas)
--Matriz.exibir(tab1)
tab1:exibir("imagemVerso")