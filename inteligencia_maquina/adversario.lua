require("inteligencia_maquina.tabuleiro")

--Utilizar seed 1 para testes, retirar depois
math.randomseed(1)

local Adversario = {
    memoria = {
    lin = 0,
    col = 0
    },
    cartasEncontradas = 0,
    paresEncontrados = 0
}

function Adversario:inicializarMemoria(linhas, colunas)
    local l = {}
    self.memoria.lin = linhas
    self.memoria.col = colunas
    for i = 1, self.memoria.lin, 1 do
        for j = 1, self.memoria.col, 1 do
            l[j] = nil
        end
        self.memoria[i] = l
        l = {}
    end
end

function Adversario:exibirMemoria()
    local padding
    local maxTam = 13
    for i = 1, self.memoria.lin, 1 do
        for j = 1, self.memoria.col, 1 do
            local elementoMemoria 
            local elementoExibido
            if self.memoria[i] and self.memoria[i][j] then
                elementoMemoria = self.memoria[i][j]
            end
            if type(elementoMemoria) == "table" then
                padding = maxTam - #self.memoria[i][j].imagemFrente - #tostring(self.memoria[i][j].id) - 1
                elementoExibido = self.memoria[i][j].imagemFrente.." "..self.memoria[i][j].id
            end
            if type(elementoMemoria) == "nil" then
                padding = maxTam - #"NIL"
                elementoExibido = "NIL"
            end    
            io.write(elementoExibido, String.new(' ', padding), "|")
        end
        io.write("\n")
    end
end

function Adversario:selecionarPrimeiraCarta(tabuleiro, rodadaAtual)
    local cartaSelecionada 

    cartaSelecionada = self:selecionarCartaAleatoria(tabuleiro)

    self:adicionarCartaMemoria(cartaSelecionada, rodadaAtual)
    io.write("cartaSelecionada: ", cartaSelecionada.imagemFrente," ", cartaSelecionada.id, "\n")
    return cartaSelecionada
end

-- Seleciona uma carta aleatória no tabuleiro, recebe dois parâmetros opicionais para indicar a posições que não serão sorteadas
function Adversario:selecionarCartaAleatoria(tabuleiro, cartaAnterior)
    local lin, col
    local contQtdSorteios = 0
    local cartaSelecionada 
    local ehCartaAnterior = false

    -- Repita ... até que (condição) seja verdadeiro
    repeat
        lin, col = self:sortearIndiceMatriz(tabuleiro.linhas, tabuleiro.colunas)
        contQtdSorteios = contQtdSorteios + 1
        io.write("posLin: ", lin, " posCol: ", col, "\n")
        -- Colocar um temporizador de 1 segundo entre as chamadas de math.random()
        print("Elemento na memoria", cartaSelecionada)
        io.write("Quantidade de Sorteios: ", contQtdSorteios, "\n")
        ehCartaAnterior = tabuleiro[lin][col] == cartaAnterior -- Ao selecionar a segunda carta, esta não pode ser igual a primeira carta
    
    until ((not self:estaNaMemoria(lin, col)) or (contQtdSorteios > 2 )) and (not ehCartaAnterior)


    cartaSelecionada = tabuleiro[lin][col]

    return cartaSelecionada
end

function Adversario:selecionarSegundaCarta(tabuleiro, rodadaAtual, primeiraCarta)
    local cartaPar = self:buscarPar(primeiraCarta)
    local parExiste = false
    local acertou = false
    local lin, col
    local cartaSelecionada
    local parFoiEncontrado = false
    
    if cartaPar then
        print("Carta Par existe: ", cartaPar)
        parExiste = true
    end
    
    if parExiste then
        cartaSelecionada = cartaPar
        acertou = self:verificaAcerto(cartaPar)
        print("Par Existe na Memoria")
        print("cartaSelecionada: ", cartaSelecionada, " ", cartaSelecionada.imagemFrente)
    else
        cartaSelecionada = Adversario:selecionarCartaAleatoria(tabuleiro, primeiraCarta)
        print("Par não Existe Seleciona Carta Par")
        print("cartaSelecionada: ", cartaSelecionada, " ", cartaSelecionada.imagemFrente)
    end

    if acertou then
        --self:contaParesEncontrados()
        --parFoiEncontrado = true
    end
    
    Adversario:adicionarCartaMemoria(cartaSelecionada, rodadaAtual)
    lin, col = cartaSelecionada.posX, cartaSelecionada.posY

    io.write("posLinCartaSelecionada: ", lin, " posColCartaSelecionada: ", col, "\n")
    io.write("cartaSelecionada: ", cartaSelecionada.imagemFrente," ", cartaSelecionada.id, "\n")
    io.write("Par encontrado: ", parFoiEncontrado, "\n")
    io.write("Pares totais: ", self.paresEncontrados, "\n")

    return cartaSelecionada, parFoiEncontrado
end

function Adversario:contaParesEncontrados()
    self.paresEncontrados = self.paresEncontrados + 1
end

function Adversario:verificaAcerto(carta)
    local erro = math.random(1,100)
    local acertou = false
    if erro < carta.probErro then
        acertou = true
    end
    
    return acertou
end

-- TODO: Implementar selecionar cartar nas posições vizinhas
-- TODO: Printar posLinOutraCarta e posColOutraCarta
function Adversario:erroAoSelecionarSegundaCarta(tabuleiro, cartaPar)
    local listaTuplaPosCandidata = {}
    local listaTuplaPosValida = {}
    local cartaSele
    local indiceListaTuplaSelec = 0 -- Se a posiçao 0 for selecionada na listaPosicaoValida, saberemos onde está o erro
    local tuplaSele
    local linSele, colSele = 0, 0
    local linCartaPar, colCartaPar = cartaPar.posX, cartaPar.posY
    -- Foi criado uma variavel para representar cada posicao adjacente a carta para facilitar o debugging e a compreensão do código
    -- Essas posicoes adjacentes podem ser atributos de carta, pelo menos cima, baixo, esquerda, direita. Já que as posições diagonais são geradas a partir destas
    local cima, baixo = {linCartaPar - 1, colCartaPar}, {linCartaPar + 1, colCartaPar}
    local esquerda, direta = {linCartaPar, colCartaPar - 1}, {linCartaPar, colCartaPar + 1}

    local cimaEsquerda, cimaDireita = {linCartaPar - 1, colCartaPar - 1}, {linCartaPar - 1, colCartaPar + 1}
    local baixoEsquerda, baixoDireita = {linCartaPar + 1, colCartaPar - 1}, {linCartaPar + 1, colCartaPar + 1}

    listaTuplaPosCandidata = {cima, baixo, esquerda, direta, cimaEsquerda, cimaDireita, baixoEsquerda, baixoDireita}
    listaTuplaPosValida = tabuleiro:verificaListaPosicao(listaTuplaPosCandidata)

    indiceListaTuplaSelec = self:sortearIndiceLista(listaTuplaPosValida)
    tuplaSele = listaTuplaPosCandidata[indiceListaTuplaSelec]
    linSele, colSele = tuplaSele[1], tuplaSele[2]

    cartaSele = tabuleiro[linSele][colSele]

    return cartaSele;
end

-- Os métodos de memória deveriam estar em outra classe
function Adversario:adicionarCartaMemoria(carta, rodadaAtual)
    self.cartasEncontradas = self.cartasEncontradas + 1
    carta.rodadaEncontrada = rodadaAtual
    self.memoria[carta.posX][carta.posY] = carta
end

function Adversario:sortearIndiceMatriz(linhasMatriz, colunasMatriz)
    local lin, col
    lin = math.random(1, linhasMatriz) 
    col = math.random(1, colunasMatriz) 
    return lin, col
end

function Adversario:sortearIndiceLista(listaPosicao)
    listaPosicao = listaPosicao or {} 
    local posicao
    posicao = math.random(1, #listaPosicao)
    return posicao
end

function Adversario:estaNaMemoria(posX, posY)
    local result = false
    if self.memoria[posX] and type(self.memoria[posX][posY]) == "table" then
        result = true
    end

    return result
end

function Adversario:buscarPar(tabuleiro, carta)
    for i = 1, #self.memoria, 1 do
        for j = 1, #self.memoria[i], 1 do
            if tabuleiro.mapPares[carta] == self.memoria[i][j] then
                return self.memoria[i][j]
            end
        end
    end
end

return Adversario