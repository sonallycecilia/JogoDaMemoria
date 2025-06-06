require("inteligencia_maquina.cartaTeste")
require("inteligencia_maquina.utils.String")
require("inteligencia_maquina.utils.Array")

Tabuleiro = {
    cartas = {}, 
    nivel = 1, 
    linhas = 4, 
    colunas = 6,
}
Tabuleiro.__index = Tabuleiro

function Tabuleiro:new(lin, col, cartas) 
    lin = 4 -- Fixa o numero de linhas 
    col = 6 -- Fixa o tamaho de colunas
    local novoTabuleiro = {
        linhas = lin, 
        colunas = col,
        mapPares = {}
    }
    setmetatable(novoTabuleiro, Tabuleiro)
    novoTabuleiro.cartas = cartas

    local linha = {}
    local indiceCarta = 1
    for i = 1, lin, 1 do
        linha = {}
        for j = 1, col, 1 do
            if cartas[indiceCarta] then 
                cartas[indiceCarta].posX = i
                cartas[indiceCarta].posY = j
                linha[j] = cartas[indiceCarta]
                indiceCarta = indiceCarta + 1
            else
                local cartaVazia = CartaTeste:new(0, "semCarta")
                cartaVazia.imagemVerso = "Vazio"
                cartaVazia.imagemFrente = "Vazio"
                linha[j] =  cartaVazia
            end
        end
        novoTabuleiro[i] = linha
    end

    novoTabuleiro.mapPares = novoTabuleiro:gerarMapPares()

    return novoTabuleiro
end

function Tabuleiro:exibir() 
    local maxTamColunas = {} 
    --Exibir cada elemento da matriz adicionando o padding correto 
    maxTamColunas = self:getMaxStringColunas("imagemExibida")
    -- for i = 1, #maxTamColunas, 1 do
    --     io.write(maxTamColunas[i], " ")
    -- end
    -- print()
    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            -- Calcular quando de espaço extra deve ser adicionando
            if self[i] and self[i][j] then
                local padding = maxTamColunas[j] - #tostring(self[i][j]:imagemExibida()) + 1
                io.write(tostring(self[i][j]:imagemExibida()), String.new(" ", padding), "|")
            else
                io.write("NIL ", String.new(" ", 5), "|")
            end
        end
        io.write("\n")
    end
    print("-----------------------------------------------------------")
end

function Tabuleiro:getMaxStringColunas(nomeIndice)
    local maxTamColunas = {}
    for j = 1, self.colunas, 1 do
        local maxTam = 0

        for i = 1, self.linhas, 1 do
            local cartaObjeto, valorAtributo = self:verificaSeCartaExiste(i, j, nomeIndice)

            if valorAtributo then
                local atributoString

                if type(valorAtributo) == "function" then
                    atributoString = tostring(valorAtributo(cartaObjeto)) -- CartaTeste.exibirCarta(cartaTeste)
                else
                    atributoString = tostring(valorAtributo)
                end

                if (#atributoString > maxTam) then
                    maxTam = #atributoString
                end
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

function Tabuleiro:gerarMapPares()
    local nomeParesAdicionados = {}
    local map = {}
    for i = 1, #self.cartas, 1 do
        for j = 1, #self.cartas, 1 do
            if (self.cartas[i].id ~= self.cartas[j].id) 
            and (self.cartas[i].imagemFrente == self.cartas[j].imagemFrente)
            and (not Array.exist(nomeParesAdicionados, self.cartas[i].imagemFrente)) then
                map[self.cartas[i]] = self.cartas[j]
                map[self.cartas[j]] = self.cartas[i]
                table.insert(nomeParesAdicionados, self.cartas.imagemFrente)
                io.write(self.cartas[i].imagemFrente,self.cartas[i].id, " ", self.cartas[j].imagemFrente,self.cartas[j].id, "\n")
                --io.write(tostring(map[self.cartas[i]]), " ", tostring(map[self.cartas[j]]), "\n")
            end
        end
    end

    return map
end

function Tabuleiro:verificaSeCartaExiste(i, j, nomeAtributo)
    nomeAtributo = nomeAtributo or "id"
    local valorAtributo
    local carta
    if self[i] and self[i][j] then
        carta = self[i][j]
        valorAtributo = carta[nomeAtributo]
    end

    return carta, valorAtributo
end

function Tabuleiro:revelarCarta(posX, posY)
    self[posX][posY]:virar()
end

-- for key, value in pairs(tab1.mapPares) do
--     io.write("Pares: ", key.imagemFrente, " ", value.imagemFrente, "\n")
-- end 

