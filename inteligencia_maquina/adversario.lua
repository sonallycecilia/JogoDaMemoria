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

-- TODO: adicionar verificação para não entrar em looping infinito quando acabarem as cartas a serem selecionadas
function adversario:selecionarPrimeiraCarta(tabuleiro, rodadaEncontrada)
    local lin, col
    repeat
        lin = math.random(1, 4) 
        col = math.random(1, 6) 
        io.write("posLin: ",lin," posCol: ", col, "\n")
        -- Colocar um temporizador de 1 segundo entre as chamadas de math.random()
        print(adversario.memoria[lin][col])
    until not adversario:estaNaMemoria(lin, col)  

    adversario.memoria[lin][col] = tabuleiro[lin][col];
    adversario.memoria[lin][col].rodadaEncontrada = rodadaEncontrada
    io.write("cartaSelecionada: ", adversario.memoria[lin][col].imagemFrente," ", adversario.memoria[lin][col].id, "\n")
    return adversario.memoria[lin][col]
end

-- TODO: adicionar verificação para não entrar em looping infinito quando acabarem as cartas a serem selecionadas
function adversario:selecionarSegundaCarta(tabuleiro, carta)
    local lin, col
    repeat
        lin = math.random(1, 4) 
        col = math.random(1, 6) 
        io.write("posLin: ",lin," posCol: ", col, "\n")
        -- Colocar um temporizador de 1 segundo entre as chamadas de math.random()
        print(adversario.memoria[lin][col])
    until not adversario:estaNaMemoria(lin, col)  

    adversario.memoria[lin][col] = tabuleiro[lin][col];
    adversario.memoria[lin][col].rodadaEncontrada = carta.rodadaEncontrada
    io.write("cartaSelecionada: ", adversario.memoria[lin][col].imagemFrente," ", adversario.memoria[lin][col].id, "\n")
    return adversario.memoria[lin][col]
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