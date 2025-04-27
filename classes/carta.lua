Carta = {}
Carta.__index = Carta

-- CONSTRUTOR
function Carta:new(id, caminhoImagemFrente, caminhoImagemVerso, largura, altura)
    local novaCarta = {
        id = id,
        revelada = false,  -- Estado da carta (revelada ou não)
        largura = largura,
        altura = altura,
        imagemFrente = love.graphics.newImage(caminhoImagemFrente),  -- Imagem da frente da carta
        imagemVerso = love.graphics.newImage(caminhoImagemVerso)     -- Imagem do verso da carta
    }
    setmetatable(novaCarta, Carta)  -- Definir a metatabela corretamente
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
    return mx >= self.x and mx <= self.x + self.largura and my >= self.y and my <= self.y + self.altura
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

return Carta
