Carta = {}
Carta.__index = Carta

-- CONSTRUTOR
function Carta.novo(id, caminhoImagemFrente, caminhoImagemVerso, largura, altura)
    local nova = setmetatable({
        id = id,
        isRevelada = false,
        largura = largura,
        altura = altura,
        imagemFrente = love.graphics.newImage(caminhoImagemFrente),  -- Carregar a imagem da frente
        imagemVerso = love.graphics.newImage(caminhoImagemVerso)     -- Carregar a imagem do verso
    }, Carta)
    return nova
end

-- Função para alternar o lado da carta
function Carta:alternarLado()
    self.isRevelada = not self.isRevelada
end

-- Função para configurar a posição da carta
function Carta:setPosicao(x, y)
    self.x = x
    self.y = y
end

-- Função para verificar se a carta foi clicada
function Carta:clicada(mx, my)
    return mx >= self.x and mx <= self.x + self.largura and my >= self.y and my <= self.y + self.altura
end

-- Função para desenhar a carta (frente ou verso)
function Carta:draw()
    if self.isRevelada then
        self:desenharImagem(self.imagemFrente, "frente")
    else
        self:desenharImagem(self.imagemVerso, "verso")
    end
end

-- Função auxiliar para desenhar a imagem
function Carta:desenharImagem(imagem, tipo)
    if imagem then
        love.graphics.draw(imagem, self.x, self.y, 0, self.largura / imagem:getWidth(), self.altura / imagem:getHeight())
    else
        print("Erro: Imagem não carregada")
    end
end

return Carta
