local carta = {}

-- CONSTRUTOR
function carta.novo(id, caminhoImagemFrente, caminhoImagemVerso)
    local imagemFrente = love.graphics.newImage(caminhoImagemFrente)
    local imagemVerso = love.graphics.newImage(caminhoImagemVerso)
    if not imagemFrente or not imagemVerso then
        print("Erro ao carregar as imagens.")
    end
    -- Cria a nova carta com dimensões fixas
    local nova = {
        id = id,
        imagemFrente = imagemFrente,
        imagemVerso = imagemVerso,
        revelada = false,
        largura = 250,
        altura = 310,
        x = 0,  -- Posição X da carta
        y = 0   -- Posição Y da carta
    }
    setmetatable(nova, { __index = carta })
    return nova
end


-- Método para alternar entre frente e verso ao clicar
function carta:alternar()
    self.revelada = not self.revelada
end

-- Função para verificar se a carta foi clicada
function carta:clicada(mx, my)
    -- Verifica se o clique está dentro dos limites da carta
    if mx >= self.x and mx <= self.x + self.largura and my >= self.y and my <= self.y + self.altura then
        return true
    end
    return false
end

-- LOVE2D
function carta:draw()
    if self.revelada then
        if self.imagemFrente then
            love.graphics.draw(self.imagemFrente, self.x, self.y, 0, self.largura / self.imagemFrente:getWidth(), self.altura / self.imagemFrente:getHeight())
        else
            print("Erro: A imagem da frente não foi carregada corretamente!")
        end
    else
        if self.imagemVerso then
            love.graphics.draw(self.imagemVerso, self.x, self.y, 0, self.largura / self.imagemVerso:getWidth(), self.altura / self.imagemVerso:getHeight())
        else
            love.graphics.setColor(0.2, 0.6, 0.8)  -- Cor do verso da carta
            love.graphics.rectangle("fill", self.x, self.y, self.largura, self.altura)  -- Desenha um retângulo como verso
            love.graphics.setColor(1, 1, 1)  -- Reseta a cor
        end
    end
end


return carta
