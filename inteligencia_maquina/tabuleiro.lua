require("inteligencia_maquina.cartaTeste")

local Tabuleiro = {cartas = {}, nivel = 1, linhas = 4, colunas = 6}
Tabuleiro.__index = Tabuleiro

local vetorCartas = {
    CartaTeste:new(1,"img01"),
    CartaTeste:new(2,"img02"),
    CartaTeste:new(3,"img03"),
    CartaTeste:new(4,"img04"),
    CartaTeste:new(5,"img05"),
    CartaTeste:new(6,"img06"),
    CartaTeste:new(7,"img07"),
    CartaTeste:new(8,"img08"),
    CartaTeste:new(9,"img09"),
    CartaTeste:new(10,"img10"),
    CartaTeste:new(11,"img11"),
    CartaTeste:new(12,"img12"),
}

function Tabuleiro:new(lin, col, vetorCartas) 
    lin = 4 -- Fixa o tamanho do tabuleiro por enquanto
    col = 12 -- Fixa o tamaho do tabuleiro
    local novoTabuleiro = {}
    novoTabuleiro.cartas = vetorCartas

    local linha = {}
    local indiceCarta = 1
    for i = 1, lin, 1 do
        for j = 1, col, 1 do
            linha[j] = vetorCartas[indiceCarta]
            indiceCarta = indiceCarta + 1
        end
        self[i] = linha
        linha = {}
    end
    setmetatable(novoTabuleiro, Tabuleiro)

    return novoTabuleiro
end

function Tabuleiro:exibir()
    local indiceCarta = 1

    for i = 1, self.linhas, 1 do
        for j = 1, self.colunas, 1 do
            if self.cartas[indiceCarta] ~= nil then
                io.write(self.cartas[indiceCarta].imagemVerso, " ")
            else
                io.write("X", " ")
            end
            indiceCarta = indiceCarta + 1
        end
        io.write("\n")
    end
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

local tab1 = Tabuleiro:new(4,6, vetorCartas)
tab1:gerarCopiaDeCartas(vetorCartas)
tab1:exibir()