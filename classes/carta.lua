Carta = {}
Carta.__index = Carta --permite usar metodo com dois pontos

local ALTURA = 100
local LARGURA = 100
local VERSO = "midia/images/verso.png"

NAO_ENCONTRADA = -1
NAO_POSICIONADA = -1

-- CONSTRUTOR
function Carta:new(id, caminhoImagemFrente)
    local novaCarta = {
        id = id,
        largura = LARGURA,
        altura = ALTURA,
        pathImagem = caminhoImagemFrente, --precisa ficar pois pegamos o caminho da imagem
        imagemFrente = love.graphics.newImage(caminhoImagemFrente),
        imagemVerso = love.graphics.newImage(VERSO),
        revelada = false, -- se não for passado, assume false
        posX = NAO_POSICIONADA,
        posY = NAO_POSICIONADA,
        rodadaEncontrada = NAO_ENCONTRADA,
        probErro = 0
    }
    setmetatable(novaCarta, Carta) --permite o uso de :, ligando a metatable de cima
    return novaCarta
end

-- Função para alternar o estado de revelação da carta
function Carta:alternarLado()
    self.revelada = not self.revelada
end

-- Função para definir a posição da carta
function Carta:setPosicao(x, y)
    self.x = x
    self.y = y
end


-- Função para verificar se a carta foi clicada (verificação de clique)
function Carta:clicada(mx, my)
    return mx >= self.x and mx <= self.x + self.largura and
           my >= self.y and my <= self.y + self.altura
end

function Carta:onClick(mx, my)
    if self:clicada(mx, my) then
        self:alternarLado()
    end
end

-- Função para desenhar a carta (exibe a frente ou o verso dependendo do estado)
function Carta:draw()
    if self.revelada then
        self:drawImagem(self.imagemFrente)  -- Desenha a frente se revelada
    else
        self:drawImagem(self.imagemVerso)   -- Desenha o verso caso contrário
    end
end

-- Função auxiliar para desenhar a imagem da carta
function Carta:drawImagem(imagem)
    if imagem then
        love.graphics.draw(imagem, self.x, self.y, 0, self.largura / imagem:getWidth(), self.altura / imagem:getHeight())
    end
end

function Carta:poder()
    if self.id == 1 then
        -- Poder es
    end
end

return Carta
