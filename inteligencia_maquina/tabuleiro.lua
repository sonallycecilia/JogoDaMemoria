local Carta = require("classes.carta")
local Tabuleiro = {}
Tabuleiro.__index = Tabuleiro

local ESPACAMENTO = 10

function Tabuleiro:new(nivel, dadosCartas)
    local novoTabuleiro = {
        nivel = nivel or 1,
        cartas = {},
        mapPares = {},
        tamanhoCarta = 100,
        linhas = 4,
        colunas = 6,
        cartasTotais = 0,
        cartasRestantes = 0,
        taxaErroBase = 30,
        erroBase = 30,
    }
    setmetatable(novoTabuleiro, Tabuleiro)

    novoTabuleiro:definirLayout()
    novoTabuleiro:ajustarTamanhoCarta()
    novoTabuleiro:gerarCopiaDeCartas(dadosCartas)
    novoTabuleiro:embaralhar()

    return novoTabuleiro
end

function Tabuleiro:definirLayout()
    if self.nivel == 1 then
        self.colunas = 5
        self.linhas = 5
        self.max_cartas = 24
    elseif self.nivel == 2 then
        self.colunas = 6
        self.linhas = 6
        self.max_cartas = 36
    else
        self.colunas = 7
        self.linhas = 7
        self.max_cartas = 48
    end
end

function Tabuleiro:ajustarTamanhoCarta()
    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    local espacosHorizontais = (self.colunas + 1) * ESPACAMENTO
    local espacosVerticais = (self.linhas + 1) * ESPACAMENTO

    local larguraDisponivel = larguraTela - espacosHorizontais
    local alturaDisponivel = alturaTela - espacosVerticais

    local larguraCarta = math.floor(larguraDisponivel / self.colunas)
    local alturaCarta = math.floor(alturaDisponivel / self.linhas)

    self.tamanhoCarta = math.min(larguraCarta, alturaCarta)
end

function Tabuleiro:gerarCopiaDeCartas(dadosCartas)
    local numCopia = self.nivel + 1
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
    return Carta:new(cartaOriginal.id, cartaOriginal.pathImagem)
end

function Tabuleiro:embaralhar()
    for i = #self.cartas, 2, -1 do
        local j = love.math.random(i)
        self.cartas[i], self.cartas[j] = self.cartas[j], self.cartas[i]
    end
end

function Tabuleiro:draw()
    local totalLargura = self.colunas * (self.tamanhoCarta + ESPACAMENTO) - ESPACAMENTO
    local totalAltura = self.linhas * (self.tamanhoCarta + ESPACAMENTO) - ESPACAMENTO

    local xInicial = 65   -- alinhado com a moldura marrom esquerda
    local yInicial = 135  -- topo do espaço útil

    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = xInicial + coluna * (self.tamanhoCarta + ESPACAMENTO)
            local y = yInicial + linha * (self.tamanhoCarta + ESPACAMENTO)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, self.tamanhoCarta, self.tamanhoCarta, 12, 12)

            local indice = linha * self.colunas + coluna + 1
            local carta = self.cartas[indice]
            if carta then
                carta:setPosicao(x, y)
                carta.largura = self.tamanhoCarta
                carta.altura = self.tamanhoCarta
                carta:draw(self.tamanhoCarta, self.tamanhoCarta)
            end
        end
    end
end

function Tabuleiro:allCardsFound()
    for _, carta in ipairs(self.cartas) do
        if not carta.revelada then
            return false -- Ainda há cartas ocultas
        end
    end
    return true -- Todas as cartas foram reveladas
end

function Tabuleiro:removerGrupoEncontrado(listaGrupo)
    -- TODO
end

return Tabuleiro
