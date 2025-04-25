local Carta = {}
Carta.__index = Carta

-- CONSTRUTOR
function Carta.novo(id, caminhoImagemFrente, caminhoImagemVerso, largura, altura)
    local imagemFrente = love.graphics.newImage(caminhoImagemFrente)
    local imagemVerso = love.graphics.newImage(caminhoImagemVerso)
    if not imagemFrente or not imagemVerso then
        print("Erro ao carregar as imagens.")
    end

    local nova = {
        id = id,
        imagemFrente = imagemFrente,
        imagemVerso = imagemVerso,
        isRevelada = false,
        largura = largura,
        altura = altura
    }
    setmetatable(nova, { __index = Carta })
    return nova
end


function Carta:alternarLado()
    self.isRevelada = not self.isRevelada
end

function Carta:setPosicao(x, y)
    self.x = x
    self.y = y
end

function Carta:clicada(mx, my)
    if mx >= self.x and mx <= self.x + self.largura and my >= self.y and my <= self.y + self.altura then
        return true
    end
    return false
end

-- LOVE2D
function Carta:draw()
    if self.isRevelada then
        if self.imagemFrente then
            love.graphics.draw(self.imagemFrente, self.x, self.y, 0, self.largura / self.imagemFrente:getWidth(), self.altura / self.imagemFrente:getHeight())
        else
            print("Erro: A imagem da frente não foi carregada corretamente!")
        end
    else
        if self.imagemVerso then
            love.graphics.draw(self.imagemVerso, self.x, self.y, 0, self.largura / self.imagemVerso:getWidth(), self.altura / self.imagemVerso:getHeight())
        else
            love.graphics.setColor(0.2, 0.6, 0.8)  -- Cor do verso da Carta
            love.graphics.rectangle("fill", self.x, self.y, self.largura, self.altura)  -- Desenha um retângulo como verso
            love.graphics.setColor(1, 1, 1)  -- Reseta a cor
        end
    end
end


return Carta
