local tabuleiro = {}

function tabuleiro:new(tam) 
    tabuleiro.tam = tam
    local linha = {}
    for i = 1, tam, 1 do
        for j = 1, tam, 1 do
            linha[j] = "X"
        end
        tabuleiro[i] = linha
        linha = {}
    end
end

function tabuleiro:exibir()
    for i = 1, tabuleiro.tam, 1 do
        for j = 1, tabuleiro.tam, 1 do
            io.write(tabuleiro[i][j], " ")
        end
        io.write("\n")
    end
end


tabuleiro:new(5)
tabuleiro:exibir()