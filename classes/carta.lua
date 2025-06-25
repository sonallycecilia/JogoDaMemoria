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
        revelada = false, -- ALTERADO PARA TESTES
        posX = nil,
        posY = nil,
        rodadaEncontrada = nil,
        probErro = 0,
        encontrada = false,
        iconeEspecial = nil,
        ehEspecial = false,
        tipoEspecial = nil,
        numCopias = 0 -- Será definido em tabuleiro

    }
    setmetatable(novaCarta, Carta)
    return novaCarta
end

function Carta:alternarLado()
    if not self.encontrada then
        self.revelada = not self.revelada
    end
end

function Carta:setEspecial(tipo, iconePath)
    self.ehEspecial = true;
    self.tipoEspecial = tipo;
    if iconePath then 
        self.iconeEspecial = love.graphics.newImage(iconePath)
    end
    self.idGrupo = "especiais";
end

function Carta:marcarComoCombinada(carta)
    self.encontrada = true
    self.revelada = true

end

function Carta:setPosicao(x, y)
    self.x = x
    self.y = y
end


-- Função para verificar se a carta foi clicada (verificação de clique na area)
function Carta:clicada(mx, my)
    local dentro = mx >= self.x and mx <= self.x + self.largura and
                   my >= self.y and my <= self.y + self.altura

    if self.ehEspecial then
        return dentro and not self.encontrada
    else
        return dentro and not self.revelada and not self.encontrada
    end
end

function Carta:draw(largura, altura)
    local imagem = (self.revelada or self.encontrada) and self.imagemFrente or self.imagemVerso
    if imagem then
        love.graphics.draw(imagem, self.x, self.y, 0,
            largura / imagem:getWidth(),
            altura / imagem:getHeight()
        )
    end
    if self.ehEspecial and self.iconeEspecial and (self.revelada or self.encontrada) then
        local escalaX = self.largura / self.iconeEspecial:getWidth()
        local escalaY = self.altura / self.iconeEspecial:getHeight()
        love.graphics.draw(self.iconeEspecial, self.x, self.y, 0, escalaX, escalaY)
    end
    if self.dica then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", self.x, self.y, self.largura, self.altura)
        love.graphics.setColor(1, 1, 1)
        self.dica = false
    end
end

function Carta:obterTipoEspecial()
    if self.ehEspecial then
        return self.tipoEspecial
    else
        return nil
    end
end


return Carta