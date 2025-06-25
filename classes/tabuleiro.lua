local ESPACAMENTO = 10
local Carta = require("classes.carta")
local Config = require("config")
local Array = require("inteligencia_maquina.utils.Array")

local Tabuleiro = {}
Tabuleiro.__index = Tabuleiro

-- TODO: Alterar parâmetro dadosCartas para vetorCartas
function Tabuleiro:new(nivel)
    self = {
        nivel = nivel or 1,
        largura = 800,
        altura = 600,
        cartas = {},
        tiposCartas = {},
        tamanhoCarta = 100,
        cartasTotais = nil,
        cartasRestantes = 0,
        linhas = 4, 
        colunas = 6,
        taxaErroBase = 30,
        erroBase = 30,
        imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro),
    }
    setmetatable(self, Tabuleiro)

    self:carregarCartas()
    self:definirLayout()
    self:ajustarTamanhoCarta()
    self:gerarCopiaDeCartas()
    self:embaralhar()
    -- Adicionar método para adicionar a posX e poxY de cada carta
    -- após os pares serem gerados, sem isso a IA não funciona
    -- Embaralha as cartas depois de criadas
 return self
end

function Tabuleiro:atualizarCartasRestantes()
     local count = 0
    for _, carta in ipairs(self.cartas) do
        if not carta.encontrada then
            count = count + 1
        end
    end
    self.cartasRestantes = 0
end

function Tabuleiro:carregarCartas()
    self.tiposCartas = {} 

    for i = 1, #Config.deck do
        local tipoCarta = {
            id = "g" .. tostring(i),
            pathImagem = Config.deck[i]
        }
        table.insert(self.tiposCartas, tipoCarta)
    end

    print("Carregadas " .. #self.tiposCartas .. " tipos de cartas (IDs 1 a " .. #self.tiposCartas .. ")")
end

function Tabuleiro:definirLayout()
    if self.nivel == FACIL then
        self.colunas = 6
        self.linhas = 4
        self.cartasTotais = self.linhas * self.colunas
        self.cartasRestantes = self.cartasTotais
        -- 4x6 = 24 cartas = 12 pares perfeito!
    end
    if self.nivel == MEDIO then
        self.colunas = 6
        self.linhas = 6
        self.cartasTotais = self.linhas * self.colunas
        self.cartasRestantes = self.cartasTotais
        -- 6x6 = 36 cartas = 12 trincas
    end
    if self.nivel == DIFICIL then
        self.colunas = 8
        self.linhas = 6
        self.cartasTotais = self.linhas * self.colunas
        self.cartasRestantes = self.cartasTotais
        -- 8x6 = 48 cartas = 12 quadras
    end
    if self.nivel == EXTREMO then
        self.colunas = 8
        self.linhas = 6
        self.cartasTotais = self.linhas * self.colunas
        self.cartasRestantes = self.cartasTotais
    end
    print("[Tabuleiro] Nível " .. self.nivel .. ": " .. self.linhas .. "x" .. self.colunas .. " = " .. (self.cartasTotais) .. " posições")
end

function Tabuleiro:ajustarTamanhoCarta()
    local larguraFrame = self.imagemTabuleiro:getWidth()
    local alturaFrame = self.imagemTabuleiro:getHeight()

    local larguraDisponivel = larguraFrame - ((self.colunas + 1) * ESPACAMENTO)
    local alturaDisponivel = alturaFrame - ((self.linhas + 1) * ESPACAMENTO)

    local larguraCarta = math.floor(larguraDisponivel / self.colunas)
    local alturaCarta = math.floor(alturaDisponivel / self.linhas)

    self.tamanhoCarta = math.min(larguraCarta, alturaCarta)
    print("[Tabuleiro] Tamanho da carta: " .. self.tamanhoCarta .. "px")
end


function Tabuleiro:gerarCopiaDeCartas()
    local mapCartaCopias = self:definirNumCopiasDoGrupo()
    local tipoCarta

    print("[Tabuleiro] Retorno do mapCartaCopias", mapCartaCopias)
    print("[Tabuleiro] Gerando cartas - Preciso de " .. self.cartasTotais .. " cartas")
    print("[Tabuleiro] Tenho " .. #self.tiposCartas .. " tipos diferentes\n")

    for i = 1, #self.tiposCartas, 1 do
        tipoCarta = self.tiposCartas[i]
        tipoCarta.numCopias = mapCartaCopias[tipoCarta]
        print("[Tabuleiro] Fazendo ", mapCartaCopias[tipoCarta], " cópias da carta", tipoCarta.pathImagem)

        for _ = 1, tipoCarta.numCopias do
            local copia = self:gerarCopiaUnica(tipoCarta)
            table.insert(self.cartas, copia) -- Vetor de cartas inicia Vazio
        end
    end

    self.cartasRestantes = #self.cartas

    -- Agora adiciona até 3 cartas especiais em cartas normais
    self:geraCartasEspeciais()

    print("[Tabuleiro] Total de cartas criadas: " .. #self.cartas)
end

function Tabuleiro:geraCartasEspeciais()
    local tiposDisponiveis = {"Revelacao", "Bomba", "Congelamento"}
    local iconesEspeciais = {
        Revelacao = "midia/images/cartas/cartaRevela.png",
        Bomba = "midia/images/cartas/bombaEspecial.png",
        Congelamento = "midia/images/cartas/congelamento.png"
    }

    local maxCartasEspeciais = 3
    local colocadas = 0
    local tentativas = 0
    local maxTentativas = 50

    while colocadas < maxCartasEspeciais and tentativas < maxTentativas do
        local index = math.random(1, #self.cartas)
        local carta = self.cartas[index]

        if carta and not carta.ehEspecial and carta.idGrupo ~= "especiais" then
            local tipo = table.remove(tiposDisponiveis, math.random(1, #tiposDisponiveis))
            if tipo then
                carta:setEspecial(tipo, iconesEspeciais[tipo])
                carta.revelada = false -- 👈 Garante que ela esteja virada ao entrar no jogo
                colocadas = colocadas + 1

                print(string.format(" → Carta especial adicionada: %s [%s] no índice %d", tipo, carta.idGrupo, index))
            end
        end

        tentativas = tentativas + 1
    end

    print(string.format("[Tabuleiro] %d cartas especiais posicionadas com sucesso", colocadas))
end

--Lidar com um array unidimensional como se fosse um array bidimensional
function Tabuleiro:adicionarPosicoesCartas()
    local linha, coluna
    for i = 1, 10, 1 do
        linha = Array.arrParaMatrizlinha(i, self.colunas)
        coluna = Array.arrParaMatrizColuna(i, self.colunas)
        self.cartas[i].posX = linha
        self.cartas[i].posY = coluna
    end
end

-- Gravar um vídeo explicando esse método
function Tabuleiro:definirNumCopiasDoGrupo()
    local copiasPorGrupo = {} -- Vai retornar um Map<Carta, copiasPorCarta>
    if (self.nivel == FACIL) or (self.nivel == MEDIO) or (self.nivel == DIFICIL) then
        print("[Tabuleiro] geracao de cartas para FACIL, MEDIO ou DIFICIL")
        copiasPorGrupo = self:definirNumCopiasDoGrupoFacilMedioDificil()
    end
    if self.nivel == EXTREMO then
        print("[Tabuleiro] geracao de cartas para EXTREMO")
        copiasPorGrupo = self:definirNumCopiasDoGrupoExtremo()
    end

    return copiasPorGrupo
end

function Tabuleiro:definirNumCopiasDoGrupoFacilMedioDificil()
    local copiasPorGrupo = {} -- Vai retornar um Map<Carta, copiasPorCarta>
    local tipoCarta, numCopia

    for i = 1, #self.tiposCartas, 1 do --Recebe o vetor de cartas inicializado sem os seus respectivos pares
        tipoCarta = self.tiposCartas[i]
        numCopia = self.nivel + 1
        copiasPorGrupo[tipoCarta] = numCopia
        print("[Tabuleiro] tipoCarta de :", tipoCarta.id, tipoCarta.pathImagem, "copias:", self.nivel + 1)
    end

    return copiasPorGrupo
end

function Tabuleiro:definirNumCopiasDoGrupoExtremo()
    local copiasPorGrupo = {}
    local minCopias, maxCopias = 2, 4
    local totalCartas, totalCartasAtual = self.cartasTotais, 0
    local tipoCarta, numCopias

    for i = 1, #self.tiposCartas, 1 do
        tipoCarta = self.tiposCartas[i]
        numCopias = math.random(minCopias, maxCopias)
        totalCartasAtual = totalCartasAtual + numCopias
        copiasPorGrupo[tipoCarta] = numCopias
        print(string.format("[Tabuleiro] Carta: %s, NumCopias: %d, TotalCartasAtual: %d", tipoCarta.id, numCopias, totalCartasAtual))
    end

    -- Caso 1: Se totalCartasAtual > totalCartas, reduzir cópias de alguns tipos de carta
    local posCartaSorteada, tipoCartaSorteada
    if totalCartasAtual > totalCartas then
        print("[Tabuleiro] Entrou no 1º Caso: totalCartasAtual > totalCartas")
        while totalCartasAtual > totalCartas do
            posCartaSorteada = math.random(1, #self.tiposCartas)
            tipoCartaSorteada = self.tiposCartas[posCartaSorteada]
            if copiasPorGrupo[tipoCartaSorteada] > minCopias then
                print("[Tabuleiro] TotalCartasAtual:", totalCartasAtual)
                print("[Tabuleiro] Numero de Copias de:", tipoCartaSorteada.pathImagem, " = ", copiasPorGrupo[tipoCartaSorteada])
                print("[Tabuleiro] Removendo uma copia de :", tipoCartaSorteada.pathImagem)
                copiasPorGrupo[tipoCartaSorteada] = copiasPorGrupo[tipoCartaSorteada] - 1
                totalCartasAtual = totalCartasAtual - 1
                print("[Tabuleiro] Numero de Copias de:", tipoCartaSorteada.pathImagem, " = ", copiasPorGrupo[tipoCartaSorteada])
                print("[Tabuleiro] TotalCartasAtual:", totalCartasAtual)
            end
        end
    end

    -- Caso 2: Se totalCartasAtual < totalCartas, aumentar cópias de alguns tipos de carta
    if totalCartasAtual < totalCartas then
        print("[Tabuleiro] Entrou no 2º Caso: totalCartasAtual < totalCartas")
        while totalCartasAtual < totalCartas do
            posCartaSorteada = math.random(1, #self.tiposCartas)
            tipoCartaSorteada = self.tiposCartas[posCartaSorteada]
            if copiasPorGrupo[tipoCartaSorteada] < maxCopias then
                print("[Tabuleiro] TotalCartasAtual:", totalCartasAtual)
                print("[Tabuleiro] Numero de Copias de:", tipoCartaSorteada.pathImagem, " = ", copiasPorGrupo[tipoCartaSorteada])
                print("[Tabuleiro] Gerando mais uma copia de :", tipoCartaSorteada.pathImagem)
                copiasPorGrupo[tipoCartaSorteada] = copiasPorGrupo[tipoCartaSorteada] + 1
                totalCartasAtual = totalCartasAtual + 1
                print("[Tabuleiro] Numero de Copias de:", tipoCartaSorteada.pathImagem, " = ", copiasPorGrupo[tipoCartaSorteada])
                print("[Tabuleiro] TotalCartasAtual:", totalCartasAtual)
            end
        end
    end

    print("[Tabuleiro] Finalizando configuração de cópias. TotalCartasAtual =", totalCartasAtual)
    return copiasPorGrupo
end

function Tabuleiro:gerarCopiaUnica(tipoCarta)
    local carta = Carta:new(tipoCarta.id, tipoCarta.pathImagem)
    carta.numCopias = tipoCarta.numCopias
    carta.idGrupo = tipoCarta.id
    return carta
end

-- Utilizar outro método de embaralhamento
function Tabuleiro:embaralhar()
    for i = #self.cartas, 2, -1 do
        local j = love.math.random(i)
        self.cartas[i], self.cartas[j] = self.cartas[j], self.cartas[i]
    end
    print("[Tabuleiro] Cartas embaralhadas!")
end

function Tabuleiro:draw()
    local escala = 0.9

    local posTabuleiroX, posTabuleiroY = 50, 130
    local larguraFrame = self.imagemTabuleiro:getWidth() * escala
    local alturaFrame = self.imagemTabuleiro:getHeight() * escala

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.imagemTabuleiro, posTabuleiroX, posTabuleiroY, 0, escala, escala)

    local totalLarguraCartas = self.colunas * (self.tamanhoCarta + ESPACAMENTO) * escala - ESPACAMENTO * escala
    local totalAlturaCartas = self.linhas * (self.tamanhoCarta + ESPACAMENTO) * escala - ESPACAMENTO * escala

    local xInicial = posTabuleiroX + (larguraFrame - totalLarguraCartas) / 2
    local yInicial = posTabuleiroY + (alturaFrame - totalAlturaCartas) / 2

    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = xInicial + coluna * (self.tamanhoCarta + ESPACAMENTO) * escala
            local y = yInicial + linha * (self.tamanhoCarta + ESPACAMENTO) * escala

            local indice = linha * self.colunas + coluna + 1
            local carta = self.cartas[indice]

            if carta then
                local margem = carta.revelada and 2 or 6
                local cartaLargura = (self.tamanhoCarta * escala) - margem * 2
                local cartaAltura = (self.tamanhoCarta * escala) - margem * 2
                local cartaX = x + margem
                local cartaY = y + margem

                -- POSICIONAMENTO E DIMENSÃO
                carta:setPosicao(cartaX, cartaY, linha, coluna)
                carta.largura = cartaLargura
                carta.altura = cartaAltura

                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", x, y, self.tamanhoCarta * escala, self.tamanhoCarta * escala, 12, 12)
                carta:draw(cartaLargura, cartaAltura)
            end
        end
    end
end


-- TODO: Adaptar a implementação de inteligencia_maquina\tabuleiroTeste.lua para grupos
function Tabuleiro:removerCarta(carta)
    local indice = self:buscarIndiceCarta(carta)
    table.remove(self.cartas, indice)
end

-- Se a carta existe na lista de cartas do trabuleiro, retorna o índice da carta, nil caso contrário
function Tabuleiro:buscarIndiceCarta(carta)
    for i, cartaTab in ipairs(self.cartas) do
        if cartaTab == carta then
            return i
        end
    end

    return nil
end

function Tabuleiro:allCardsFound()
    local todasForamEncontradas = true
    for _, carta in ipairs(self.cartas) do
        if not carta.encontrada then
            todasForamEncontradas =  false
        end
    end
    return todasForamEncontradas
end

function Tabuleiro:removerGrupoEncontrado(listaGrupo)
    for _, carta in ipairs(listaGrupo) do
        carta.revelada = true
        carta.encontrada = true
    end
    self.cartasRestantes = self.cartasRestantes - #listaGrupo
end

function Tabuleiro:desvirarGrupo(listaGrupo)
    for _, carta in ipairs(listaGrupo) do
        if not carta.encontrada then
            carta.revelada = false
        end
    end
end

return Tabuleiro