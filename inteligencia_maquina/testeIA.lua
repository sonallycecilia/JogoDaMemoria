local adversario = require("inteligencia_maquina.adversario")
local CartaTeste =  require("inteligencia_maquina.cartaTeste")
require("inteligencia_maquina.cartaTeste")
local Tabuleiro = require("inteligencia_maquina.tabuleiro")

local cartas = {
    CartaTeste:new(9,"gato"),
    CartaTeste:new(21,"gato"),
    CartaTeste:new(11,"nally"),
    CartaTeste:new(18,"elfa"),
    CartaTeste:new(23,"nally"),
    CartaTeste:new(22,"lua"),
    CartaTeste:new(14,"borboleta"),
    CartaTeste:new(2,"borboleta"),
    CartaTeste:new(15,"cogumelo"),
    CartaTeste:new(3,"cogumelo"),
    CartaTeste:new(10,"lua"),
    CartaTeste:new(12,"planta"),
    CartaTeste:new(24,"planta"),
    CartaTeste:new(1,"bomba"),
    CartaTeste:new(13,"bomba"),
    CartaTeste:new(7,"fada"),
    CartaTeste:new(19,"fada"),
    CartaTeste:new(8,"flor"),
    CartaTeste:new(20,"flor"),
    CartaTeste:new(16,"coracao"),
    CartaTeste:new(4,"coracao"),
    CartaTeste:new(17,"draenei"),
    CartaTeste:new(5,"draenei"),
    CartaTeste:new(6,"elfa")
}

local tabuleiro = Tabuleiro:new(1, cartas)
local rodadaAtual = 0
local primeiraCartaSele = {}
local segundaCartaSele = {}

os.execute("pause")
os.execute("cls")

for i = 1, #tabuleiro.cartas, 1 do
    print("Erro Carta: ", tabuleiro.cartas[i].probErro)
end

adversario:inicializarMemoria(tabuleiro.linhas, tabuleiro.colunas)
while tabuleiro.cartasRestantes > 0 do
    print("Avancar?")
    tabuleiro:exibir()
    io.write("PRIMEIRA CARTA: ")
    os.execute("pause")
    os.execute("cls")

    primeiraCartaSele = adversario:selecionarPrimeiraCarta(tabuleiro, rodadaAtual)

    tabuleiro:virarCarta(primeiraCartaSele.posX, primeiraCartaSele.posY)
    tabuleiro:exibir()
    os.execute("pause")
    os.execute("cls")
    
    
    print("Memoria adversario: ")
    adversario:exibirMemoria()
    os.execute("pause")
    os.execute("cls")
    io.write("SEGUNDA CARTA ")
    os.execute("pause")
    os.execute("cls")
    
    print("Primeira Carta Selecionada em teste.lua : ",primeiraCartaSele.imagemFrente,primeiraCartaSele.id)
    segundaCartaSele = adversario:selecionarSegundaCarta(tabuleiro, rodadaAtual, primeiraCartaSele)
    
    tabuleiro:virarCarta(segundaCartaSele.posX, segundaCartaSele.posY)
    tabuleiro:exibir()
    
    tabuleiro:virarCarta(primeiraCartaSele.posX, primeiraCartaSele.posY)
    tabuleiro:virarCarta(segundaCartaSele.posX, segundaCartaSele.posY)
    os.execute("pause")
    os.execute("cls")

    print("Memoria adversario: ")
    adversario:exibirMemoria()
    os.execute("pause")
    os.execute("cls")
    rodadaAtual = rodadaAtual + 1
end


