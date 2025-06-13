local ESPACAMENTO = 10
local Carta = require("classes.carta")
local Config = require("config")

local Tabuleiro = {}
Tabuleiro.__index = Tabuleiro --permite utilizar o objeto como protótipo para outros


-- TODO: Alterar parâmetro dadosCartas para vetorCartas
function Tabuleiro:new(nivel, dadosCartas)
    local tabuleiro = {
    largura = 800,
    altura = 600,
    cartas = {},
    mapPares = {},
    tamanhoCarta = 100,
    linhas = 4, -- Definido pelo nível, mas provavelmente será fixo em 24
    colunas = 6, -- Definido pelo nível, mas provavelmente será fixo em 24
    cartasTotais = nil,
    cartasRestantes = nil,
    taxaErroBase = 30,
    erroBase = 30,
    nivel = nivel or 1,
    imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro),
    }
    setmetatable(tabuleiro, Tabuleiro) 

    self:definirLayout()
    self:ajustarTamanhoCarta()
    self:gerarCopiaDeCartas(dadosCartas)
    self:embaralhar()
    -- Adicionar método para adicionar a posX e poxY de cada carta
    -- após os pares serem gerados, sem isso a IA não funciona
    -- Embaralha as cartas depois de criadas
    return tabuleiro
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

function Tabuleiro:definirLayout()
    if self.nivel == 1 then
        self.colunas = 6
        self.linhas = 4
        -- 4x6 = 24 cartas = 12 pares perfeito!
    elseif self.nivel == 2 then
        self.colunas = 6
        self.linhas = 6
        -- 6x6 = 36 cartas = 18 pares
    elseif self.nivel == 3 then
        self.colunas = 7
        self.linhas = 7
        -- 7x7 = 49 cartas = 24 pares + 1 extra
    else
        self.colunas = 8
        self.linhas = 8
        -- 8x8 = 64 cartas = 32 pares (extremo)
    end
    
    print("[Tabuleiro] Nível " .. self.nivel .. ": " .. self.linhas .. "x" .. self.colunas .. " = " .. (self.linhas * self.colunas) .. " posições")
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

function Tabuleiro:gerarCopiaDeCartas(dadosCartas)
    local numCopia = self.nivel + 1  -- Nível 1 = 2 cópias
    local totalCartasNecessarias = self.linhas * self.colunas
    local cartasIndex = 1

    print("[Tabuleiro] Gerando cartas - Preciso de " .. totalCartasNecessarias .. " cartas")
    print("[Tabuleiro] Tenho " .. #dadosCartas .. " tipos diferentes")
    print("[Tabuleiro] Fazendo " .. numCopia .. " cópias de cada")

    while #self.cartas < totalCartasNecessarias do
        local cartaOriginal = dadosCartas[cartasIndex]
        for _ = 1, numCopia do
            local copia = self:gerarCopiaUnica(cartaOriginal)
            table.insert(self.cartas, copia)
        end
        cartasIndex = cartasIndex + 1
        if cartasIndex > #dadosCartas then
            cartasIndex = 1
        end
    end

    self.cartasRestantes = #self.cartas
    print("[Tabuleiro] Total de cartas criadas: " .. #self.cartas)
end

function Tabuleiro:gerarCopiaUnica(cartaOriginal)
    return Carta:new(cartaOriginal.id, cartaOriginal.pathImagem)
end

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

    -- Calcula o espaço total que as cartas ocupam
    local totalLarguraCartas = self.colunas * (self.tamanhoCarta + ESPACAMENTO) * escala - ESPACAMENTO * escala
    local totalAlturaCartas = self.linhas * (self.tamanhoCarta + ESPACAMENTO) * escala - ESPACAMENTO * escala

    -- Centraliza as cartas dentro do frame do tabuleiro
    local xInicial = posTabuleiroX + (larguraFrame - totalLarguraCartas) / 2
    local yInicial = posTabuleiroY + (alturaFrame - totalAlturaCartas) / 2

    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = xInicial + coluna * (self.tamanhoCarta + ESPACAMENTO) * escala
            local y = yInicial + linha * (self.tamanhoCarta + ESPACAMENTO) * escala

            local indice = linha * self.colunas + coluna + 1
            local carta = self.cartas[indice]

            if carta then
                local margemVerso = 6
                local margemFrente = 2

                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", x, y, self.tamanhoCarta * escala, self.tamanhoCarta * escala, 12, 12)

                local margem = carta.revelada and margemFrente or margemVerso

                local cartaLargura = (self.tamanhoCarta * escala) - margem * 2
                local cartaAltura = (self.tamanhoCarta * escala) - margem * 2
                local cartaX = x + margem
                local cartaY = y + margem

                carta:setPosicao(cartaX, cartaY)
                carta.largura = cartaLargura
                carta.altura = cartaAltura
                carta:draw(cartaLargura, cartaAltura)
            else
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle("fill", x, y, self.tamanhoCarta * escala, self.tamanhoCarta * escala, 12, 12)
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
    for _, carta in ipairs(self.cartas) do
        if not carta.encontrada then
            return false
        end
    end
    return true
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

function Tabuleiro:carregarCartas()
    local carta
    for i = 1, 12 do
        carta = Carta:new(i, Config.deck[i])
        table.insert(self.cartas, carta)
    end
    
    print("Carregadas " .. #self.cartas .. " tipos de cartas (IDs 1 a " .. (#self.cartas) .. ")")
end

return Tabuleiro