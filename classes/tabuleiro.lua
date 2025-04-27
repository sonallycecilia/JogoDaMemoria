Tabuleiro = {}
Tabuleiro.__index = Tabuleiro  -- Definindo a metatable para o Tabuleiro

local MIN_CARTAS = 24
local MAX_CARTAS = 48
local ESPACAMENTO = 10
local POS_X = 200
local POS_Y = 80

function Tabuleiro:new(nivel)
    local novo = {
        nivel = nivel or 1,
        largura = 800,
        altura = 600,
        cartas = {},
        tamanhoCarta = 100
    }
    setmetatable(novo, Tabuleiro)
    novo:definirLayout()  -- Configura o layout com base no nível
    return novo
end

-- Função que define o layout do tabuleiro com base no nível
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

    -- Posições iniciais
    self.x = POS_X
    self.y = POS_Y
end

-- Função para adicionar uma carta ao tabuleiro
function Tabuleiro:addCarta(carta)
    if #self.cartas < MAX_CARTAS then
        table.insert(self.cartas, carta)
    end
end

-- Função para desenhar o tabuleiro e as cartas
function Tabuleiro:draw()
    love.graphics.setColor(0, 0, 0)
    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = self.x + coluna * (self.tamanhoCarta + ESPACAMENTO)
            local y = self.y + linha * (self.tamanhoCarta + ESPACAMENTO)
            
            -- Desenhar a parte do tabuleiro
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, self.tamanhoCarta, self.tamanhoCarta)

            -- Verificar e desenhar a carta na posição
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
