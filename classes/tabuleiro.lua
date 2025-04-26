local Tabuleiro = {}
Tabuleiro.__index = Tabuleiro

local MIN_CARTAS = 24
local MAX_CARTAS = 48
local ESPACAMENTO = 10

function Tabuleiro.novo(nivel)
    local novo = setmetatable({}, Tabuleiro)
    novo.nivel = nivel or 1
    novo.largura = 800
    novo.altura = 600
    novo.cartas = {}
    novo.tamanhoCarta = 100
    
    novo:definirLayout()
    return novo
end

function Tabuleiro:definirLayout()
    if self.nivel == 1 then
        self.colunas = 5
        self.linhas = 5
    elseif self.nivel == 2 then
        self.colunas = 6
        self.linhas = 6
    else
        self.colunas = 7
        self.linhas = 7
    end

    -- Centraliza o tabuleiro com base no número de cartas e seus tamanhos
    local totalLargura = self.colunas * self.tamanhoCarta + (self.colunas - 1) * ESPACAMENTO
    local totalAltura = self.linhas * self.tamanhoCarta + (self.linhas - 1) * ESPACAMENTO
    self.x = 200
    self.y = 80
end

function Tabuleiro:setPosicao(x, y)
    self.posicao = {x = x, y = y}
end

function Tabuleiro:addCarta(carta)
    if #self.cartas < MAX_CARTAS then
        table.insert(self.cartas, carta)
    end
end

function Tabuleiro:draw()
    love.graphics.setColor(0, 0, 0)
    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = self.x + coluna * (self.tamanhoCarta + ESPACAMENTO)
            local y = self.y + linha * (self.tamanhoCarta + ESPACAMENTO)
            
            -- cores e formato
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, self.tamanhoCarta, self.tamanhoCarta)

            local indice = linha * self.colunas + coluna + 1
            local carta = self.cartas[indice]
            if carta then
                carta:setPosicao(x, y)
                carta:draw(self.tamanhoCarta, self.tamanhoCarta)
            end
        end
    end
end

return Tabuleiro
