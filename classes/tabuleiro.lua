local ESPACAMENTO = 10
local POS_X = 175
local POS_Y = 145

local Tabuleiro = {
    nivel = 1,
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
}
Tabuleiro.__index = Tabuleiro --permite utilizar o objeto como protótipo para outros


-- TODO: Alterar parâmetro dadosCartas para vetorCartas
function Tabuleiro:new(nivel, dadosCartas)
    self = {
        nivel = nivel or 1,
        linhas = 4, -- Definido pelo nível, mas provavelmente será fixo em 24
        colunas = 6, -- Definido pelo nível, mas provavelmente será fixo em 24
        taxaErroBase = 30,
        erroBase = 30,
    }
    setmetatable(self, Tabuleiro) 

    -- Gerar as cópias das cartas conforme o nível
    self:gerarCopiaDeCartas(dadosCartas)

    -- Adicionar método para adicionar a posX e poxY de cada carta
    -- após os pares serem gerados, sem isso a IA não funciona

    -- Embaralha as cartas depois de criadas
    self:embaralhar()

    -- Define o layout do tabuleiro
    self:definirLayout()

    return self
end

-- Testar para saber se o método está funcionando corretamente
function Tabuleiro:gerarCopiaDeCartas(dadosCartas)
    -- Número de cópias de acordo com o nível (nível 1 = 2 cópias, nível 2 = 3 cópias, etc.)
    local numCopia  
    if self.nivel >= FACIL and self.nivel <= DIFICIL then
        numCopia = self.nivel + 1
    end
    if self.nivel == EXTREMO then
        -- TODO: Criar uma função para calcular o numéro de cópias aleatória de cada carta
        numCopia = {} -- A quantidade de cópias de cada carta é variável, cara índice representa uma carta e o valor a sua respectiva quantidade de cópias
    end

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

return Tabuleiro
