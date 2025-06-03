

math.randomseed(os.time())

local adversario = {memoria = {}}

function adversario:inicializarMemoria(linhas, colunas)
    local l = {}
    for i = 1, linhas, 1 do
        for j = 1, colunas, 1 do
            l[j] = "X"
        end
        adversario.memoria[i] = l
        l = {}
    end
end

function adversario:exibirMemoria()
    for i = 1, #adversario.memoria, 1 do
        for j = 1, #adversario.memoria[i], 1 do
            io.write(adversario.memoria[i][j], " ")
        end
        io.write("\n")
    end
end

function adversario:selecionarCarta()
    local selectLin = math.random(1, 4) 
    local selectCol = math.random(1, 6) 
    print(selectLin, selectCol)
    adversario.memoria[selectLin][selectCol] = 'O';
end

function adversario:buscarCarta()
    
end

function adversario:buscarPar(Carta, memoriaJogador)
end

adversario:inicializarMemoria(4,6)
adversario:exibirMemoria()
adversario:selecionarCarta()
adversario:exibirMemoria()