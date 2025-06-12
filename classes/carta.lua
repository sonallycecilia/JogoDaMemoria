local Carta = {}
Carta.__index = Carta

local ALTURA = 100
local LARGURA = 100
local VERSO = "midia/images/verso.png"

-- Talvez seja interessante utilizar um id para o grupo que a carta pertence, os pares, trincas ou quadras vão possuir o mesmo idGrupo
function Carta:new(id, caminhoImagemFrente)
    local novaCarta = {
        id = id,
        idGrupo = nil,
        largura = LARGURA,
        altura = ALTURA,
        pathImagem = caminhoImagemFrente,
        imagemFrente = love.graphics.newImage(caminhoImagemFrente),
        imagemVerso = love.graphics.newImage(VERSO),
        revelada = false, -- se não for passado, assume false
        posX = nil,
        posY = nil,
        rodadaEncontrada = nil,
        probErro = 0,
        encontrada = false
    }
    setmetatable(novaCarta, Carta)
    return novaCarta
end

function Carta:alternarLado()
    if not self.encontrada then
        self.revelada = not self.revelada
    end
end

function Carta:setPosicao(x, y)
    self.x = x
    self.y = y
end


-- Função para verificar se a carta foi clicada (verificação de clique na area)
function Carta:clicada(mx, my)
    return mx >= self.x and mx <= self.x + self.largura and
           my >= self.y and my <= self.y + self.altura
end

function Carta:draw(largura, altura)
    local imagem = (self.revelada or self.encontrada) and self.imagemFrente or self.imagemVerso
    if imagem then
        love.graphics.draw(imagem, self.x, self.y, 0,
            largura / imagem:getWidth(),
            altura / imagem:getHeight()
        )
    end
end

function Carta:poder()
    if self.id == 1 then
        -- Poder especial aqui
    end
end

return Carta
