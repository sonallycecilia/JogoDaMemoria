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

--TODO: Adicionar a probabilidade de Erro as cartas
function Tabuleiro:new(lin, col, cartas, nivel) 
    nivel = 1
    lin = 4 -- Fixa o numero de linhas 
    col = 6 -- Fixa o tamaho de colunas
    local novoTabuleiro = {
        linhas = lin, 
        colunas = col,
        mapPares = {},

        -- Balancear os erros depois (caso dê tempo)
        erroBaseNivel1 = 60,
        taxaErroNivel1 = 20,

        erroBaseNivel2 = 40,
        taxaErroNivel2 = 15,
        
        erroBaseNivel3 = 30,
        taxaErroNivel3 = 10
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
    maxTamColunas = self:getMaxStringColunas("imagemExibida")
    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            local imagemExibida = "NIL"
            local padding = #imagemExibida
            local espacador = "|"
            local elemento = self:verificaSeCartaExiste(i, j)
            if type(elemento) == "table" then
                imagemExibida = tostring(elemento:imagemExibida())
                padding = maxTamColunas[j] - #imagemExibida + #espacador
            end
            if type(elemento) == "string" then
                imagemExibida = elemento
                padding = maxTamColunas[j] - #imagemExibida + #espacador
            end
            io.write(imagemExibida, String.new(" ", padding), espacador)
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
            local atributoString
            if type(valorAtributo) == "function" then
                atributoString = tostring(valorAtributo(cartaObjeto)) -- CartaTeste.exibirCarta(cartaTeste)
            end
            if type(valorAtributo) == "string" then
            atributoString = valorAtributo
            end
            if type(valorAtributo) == "nil" then
                atributoString = "NIL"
            end
            if (#atributoString > maxTam) then
                maxTam = #atributoString
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

-- NECESSITA DE TESTES
-- Retorna verdadeiro caso a posicao self[posX][posY] seja diferente de nil ou false, caso contrário retorna true 
function Tabuleiro:verificaPosicao(posX, posY)
    local posExiste = false
    if self[posX] and self[posX][posY] then
        posExiste = true
    end

    return posExiste
end

-- NECESSITA DE TESTES
-- Retorna uma nova lista de posicoes não nil
function Tabuleiro:verificaListaPosicao(listaTuplaPosicoes)
    local listaPosicaoValida = {}
    local posicaoExiste = false
    local tuplaAtual = {}
    for i = 1, #listaTuplaPosicoes, 1 do
        tuplaAtual = listaTuplaPosicoes[i]
        posicaoExiste = self:verificaPosicao(tuplaAtual[1], tuplaAtual[2])
        if posicaoExiste then
            table.insert(listaPosicaoValida, tuplaAtual)
        end
    end

    return listaPosicaoValida
end

function Tabuleiro:virarCarta(posX, posY)
    self[posX][posY]:virar()
end

-- for key, value in pairs(tab1.mapPares) do
--     io.write("Pares: ", key.imagemFrente, " ", value.imagemFrente, "\n")
-- end 

