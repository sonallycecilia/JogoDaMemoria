Tabuleiro = {}
Tabuleiro.__index = Tabuleiro --permite chamadas com self

local ESPACAMENTO = 10
local POS_X = 175
local POS_Y = 145

function Tabuleiro:new(nivel, dadosCartas)
    local novo = {
        nivel = nivel or 1,
        largura = 800,
        altura = 600,
        cartas = {},
        tamanhoCarta = 100
    }
    setmetatable(novo, Tabuleiro)

    -- Gerar as cópias das cartas conforme o nível
    novo:gerarCopiaDeCartas(dadosCartas)

    -- Embaralha as cartas depois de criadas
    novo:embaralhar()

    -- Define o layout do tabuleiro
    novo:definirLayout()

    return novo
end

function Tabuleiro:gerarCopiaDeCartas(dadosCartas)
    if self.nivel == 1 or self.nivel == 3 then
        table.insert(self.cartas, Carta:new(13, "midia/images/cartas/cogumelo.png")) -- Não gera cópias para os níveis 1 e 2
    end
    -- Número de cópias de acordo com o nível (nível 1 = 2 cópias, nível 2 = 3 cópias, etc.)
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
    return Carta:new(cartaOriginal.id, cartaOriginal.pathImagem)
end

function Tabuleiro:definirLayout()
    -- Define o layout do tabuleiro com base no nível
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

    -- Posições iniciais
    self.x = POS_X
    self.y = POS_Y
end

function Tabuleiro:embaralhar()
    -- Fisher-Yates shuffle para embaralhar as cartas
    for i = #self.cartas, 2, -1 do
        local j = love.math.random(i)  -- Random index entre 1 e i
        -- Trocar as cartas nas posições i e j
        self.cartas[i], self.cartas[j] = self.cartas[j], self.cartas[i]
    end
end

function Tabuleiro:draw()
    -- Função para desenhar o tabuleiro e as cartas
    love.graphics.setColor(0, 0, 0)
    for linha = 0, self.linhas - 1 do
        for coluna = 0, self.colunas - 1 do
            local x = self.x + coluna * (self.tamanhoCarta + ESPACAMENTO)
            local y = self.y + linha * (self.tamanhoCarta + ESPACAMENTO)

            -- Desenhar a parte do tabuleiro
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, self.tamanhoCarta, self.tamanhoCarta, 12, 12)

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
