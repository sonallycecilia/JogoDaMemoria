require("inteligencia_maquina.tabuleiro")

math.randomseed(os.time())

local adversario = {
    memoria = {
    lin = 0,
    col = 0
    }
}

function adversario:inicializarMemoria(linhas, colunas)
    local l = {}
    self.memoria.lin = linhas
    self.memoria.col = colunas
    for i = 1, self.memoria.lin, 1 do
        for j = 1, self.memoria.col, 1 do
            l[j] = nil
        end
        adversario.memoria[i] = l
        l = {}
    end
end

function adversario:exibirMemoria()
    local padding
    local maxTam = 13
    for i = 1, adversario.memoria.lin, 1 do
        for j = 1, adversario.memoria.col, 1 do
            local elementoMemoria 
            local elementoExibido
            if adversario.memoria[i] and adversario.memoria[i][j] then
                elementoMemoria = adversario.memoria[i][j]
            end
            if type(elementoMemoria) == "table" then
                padding = maxTam - #adversario.memoria[i][j].imagemFrente - #tostring(adversario.memoria[i][j].id) - 1
                elementoExibido = adversario.memoria[i][j].imagemFrente.." "..adversario.memoria[i][j].id
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

function adversario:selecionarPrimeiraCarta(tabuleiro, rodadaAtual)
    local lin, col
    local contQtdSorteios = 0
    
    repeat
        lin, col = self:sortearPosicao(tabuleiro.linhas, tabuleiro.colunas)
        contQtdSorteios = contQtdSorteios + 1
        io.write("posLin: ", lin, " posCol: ", col, "\n")
        -- Colocar um temporizador de 1 segundo entre as chamadas de math.random()
        print("Elemento na memoria", adversario.memoria[lin][col])
        io.write("Quantidade de Sorteios: ", contQtdSorteios, "\n")
    until (not adversario:estaNaMemoria(lin, col)) or (contQtdSorteios > 2 ) 
    adversario:adicionarCartaMemoria(lin, col,tabuleiro[lin][col], rodadaAtual)
    io.write("cartaSelecionada: ", adversario.memoria[lin][col].imagemFrente," ", adversario.memoria[lin][col].id, "\n")
    return adversario.memoria[lin][col]
end

function adversario:selecionarSegundaCarta(rodadaAtual, tabuleiro, primeiraCarta)
    if self:buscarPar(primeiraCarta) then
        
    end
    

    local ehPrimeiraCarta
    local lin, col
    repeat
        
    until not adversario:estaNaMemoria(lin, col)  

    self:adicionarCartaMemoria(lin, col, tabuleiro[lin][col], rodadaAtual)

    io.write("cartaSelecionada: ", adversario.memoria[lin][col].imagemFrente," ", adversario.memoria[lin][col].id, "\n")
    return adversario.memoria[lin][col]
end

-- Os métodos de memória deveriam estar em outra classe
function adversario:adicionarCartaMemoria(lin, col, carta, rodadaAtual)
    carta.rodadaEncontrada = rodadaAtual
    adversario.memoria[lin][col] = carta
end

function adversario:sortearPosicao(linhasMatriz, colunasMatriz)
    local lin, col
    lin = math.random(1, linhasMatriz) 
    col = math.random(1, colunasMatriz) 
    return lin, col
end

function adversario:estaNaMemoria(posX, posY)
    local result = false
    if adversario.memoria[posX] and type(adversario.memoria[posX][posY]) == "table" then
        result = true
    end

    return result
end

function adversario:buscarPar(tabuleiro, carta)
    for i = 1, #adversario.memoria, 1 do
        for j = 1, #adversario.memoria[i], 1 do
            if tabuleiro.mapPares[carta] == self.memoria[i][j] then
                return self.memoria[i][j]
            end
        end
    end
end


return adversario