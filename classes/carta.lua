local Carta = {}
Carta.__index = Carta

-- CONSTRUTOR
function Carta.novo(id, caminhoImagemFrente, caminhoImagemVerso, largura, altura)
    local nova = setmetatable({
        id = id,
        isRevelada = false,
        largura = largura,
        altura = altura
    }, Carta)

    nova:setImagemFrente(caminhoImagemFrente)
    nova:setImagemVerso(caminhoImagemVerso)
    
    return nova
end

-- Função para configurar a imagem da frente
function Carta:setImagemFrente(caminhoImagemFrente)
    local status, imagem = pcall(love.graphics.newImage, caminhoImagemFrente)
    if status then
        self.imagemFrente = imagem
    else
        self:gerarErro("Erro ao carregar imagem da frente", caminhoImagemFrente)
    end
end

-- Função para configurar a imagem do verso
function Carta:setImagemVerso(caminhoImagemVerso)
    local status, imagem = pcall(love.graphics.newImage, caminhoImagemVerso)
    if status then
        self.imagemVerso = imagem
    else
        self:gerarErro("Erro ao carregar imagem do verso", caminhoImagemVerso)
    end
end

-- Método para gerar erro com informações sobre a falha
function Carta:gerarErro(tipoErro, caminhoImagem)
    print(tipoErro .. ": " .. caminhoImagem)
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
        
    end
end

return Carta
