require("classes.tabuleiro")
require("classes.carta")

local vetorCartas = {
        Carta:new(1, "midia/images/cartas/fada.png"),
        Carta:new(2, "midia/images/cartas/naly.png"),
        Carta:new(3, "midia/images/cartas/elfa.png"),
        Carta:new(4, "midia/images/cartas/draenei.png"),
        Carta:new(5, "midia/images/cartas/borboleta.png"),
        Carta:new(6, "midia/images/cartas/lua.png"),
        Carta:new(7, "midia/images/cartas/coracao.png"),
        Carta:new(8, "midia/images/cartas/draenei.png"),
        Carta:new(9, "midia/images/cartas/flor.png"),
        Carta:new(10, "midia/images/cartas/gato.png"),
        Carta:new(11, "midia/images/cartas/pocao.png"),
        Carta:new(12, "midia/images/cartas/planta.png"),
        }

Tabuleiro:new(1, vetorCartas)

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
end

function adversario:buscarPar(memoriaJogador)
end

adversario:inicializarMemoria(6,4)
adversario:exibirMemoria()
    
