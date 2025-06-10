require("inteligencia_maquina.cartaTeste")
require("inteligencia_maquina.utils.String")
require("inteligencia_maquina.utils.Array")
require("classes.niveldeJogo")

Tabuleiro = {
    cartas = {}, 
    mapPares = {},
    nivel = 1, 
    linhas = 4, 
    colunas = 6,
    cartasTotais = 0,
    cartasRestantes = 0,
    taxaErroBase = 30,
    erroBase = 30,
}
Tabuleiro.__index = Tabuleiro

function Tabuleiro:new(lin, col, cartas, nivel) 
    local novoTabuleiro = {
        --nivel = nivel,
        --linhas = lin, 
        --colunas = col,
        mapPares = {},
    }
    -- Balancear os erros depois (caso dê tempo)
    
    setmetatable(novoTabuleiro, Tabuleiro)
    novoTabuleiro.cartas = cartas

    novoTabuleiro:calculaProbErro()

    local linha = {}
    local indiceCarta = 1
    for i = 1, self.linhas, 1 do
        linha = {}
        for j = 1, self.colunas, 1 do
            if cartas[indiceCarta] then 
                cartas[indiceCarta].posX = i
                cartas[indiceCarta].posY = j
                cartas[indiceCarta].probErro = novoTabuleiro.erroBase
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
    novoTabuleiro.cartasTotais = #cartas --Considerando que o vetor de cartas terá o seus respectivos pares
    novoTabuleiro.cartasRestantes = novoTabuleiro.cartasTotais

    return novoTabuleiro
end

function Tabuleiro:exibir() 
    local maxTamColunas = {} 
    maxTamColunas = self:getMaxStringColunas("imagemExibida")
    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            local imagemExibida = "NIL"
            local espacador = "|"
            local padding = maxTamColunas[j] - #imagemExibida + #espacador
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
    io.write("Map Pares:\n")
    local nomeParesAdicionados = {}
    local map = {}
    local contPares = 0
    for i = 1, #self.cartas, 1 do
        for j = i, #self.cartas, 1 do
            if (self.cartas[i].id ~= self.cartas[j].id) 
            and (self.cartas[i].imagemFrente == self.cartas[j].imagemFrente)
            and (not Array.exist(nomeParesAdicionados, self.cartas[i].imagemFrente)) then

                map[self.cartas[i]] = self.cartas[j]
                map[self.cartas[j]] = self.cartas[i]
                contPares = contPares + 1
                table.insert(nomeParesAdicionados, self.cartas.imagemFrente)
                io.write("Pares Encontrados: ", contPares, "\n")
                io.write(map[self.cartas[i]].imagemFrente,map[self.cartas[i]].id, " ", map[self.cartas[j]].imagemFrente,map[self.cartas[j]].id, "\n")
                io.write(map[self.cartas[j]].imagemFrente,map[self.cartas[j]].id, " ", map[self.cartas[i]].imagemFrente,map[self.cartas[i]].id, "\n\n")
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
function Tabuleiro:verificaListaPosicao(listaTuplaPosicoes, primeiraCarta)
    local listaPosicaoValida = {}
    local posicaoExiste = false
    local tuplaAtual = {}
    for i = 1, #listaTuplaPosicoes, 1 do
        tuplaAtual = listaTuplaPosicoes[i]
        posicaoExiste = self:verificaPosicao(tuplaAtual[1], tuplaAtual[2])
        if posicaoExiste and (tuplaAtual[1] ~= primeiraCarta.posX) and (tuplaAtual[2] ~= primeiraCarta.posY)then
            table.insert(listaPosicaoValida, tuplaAtual)
        end
    end

    return listaPosicaoValida
end

function Tabuleiro:virarCarta(posX, posY)
    local posicaoExiste = self:verificaPosicao(posX, posY)
    if posicaoExiste then
        self[posX][posY]:virar()
    end
end

function Tabuleiro:removerParEncontrado(carta1, carta2)
    local ehNil = true
    if carta1 and carta2 then
        ehNil = false
    end
    
    if (not ehNil) and (self.mapPares[carta1] == carta2) then
        self.cartasRestantes = self.cartasRestantes - 2
        self[carta1.posX][carta1.posY] = nil
        self[carta2.posX][carta2.posY] = nil
    end

end

function Tabuleiro:calculaProbErro()
    if self.nivel == FACIL then
        self.erroBase = 40
        self.taxaErroBase = 20
    end

    if self.nivel == MEDIO then
        self.erroBase = 35
        self.taxaErroBase = 15
    end

    if self.nivel == DIFICIL then
        self.erroBase = 30
        self.taxaErroBase = 10
    end

    if self.nivel == EXTREMO then
        self.erroBase = 25
        self.taxaErroBase = 5
    end
end