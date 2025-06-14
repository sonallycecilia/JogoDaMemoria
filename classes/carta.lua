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
        cartasEspeciais = nil,
        ehEspecial = false,
        tiposEspeciais = {},
        taCongelada = false,

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

function Carta:marcarComoCombinada()
    self.encontrada = true
    self.revelada = true

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


function Carta:ativarPoder(partidaInstance, tabuleiroInstance) -- Use partidaInstance, tabuleiroInstance para consistência
    if self.ehEspecial and self.tipoEspecial then
        -- Chama a função correspondente em CartasEspeciais (seu módulo de poderes)
        if self.tipoEspecial == "Revelacao" then
            return CartasEspeciais:ativarRevelacao(tabuleiroInstance, partidaInstance)
        elseif self.tipoEspecial == "Congelamento" then
            return CartasEspeciais:ativarCongelamentoSelecao(partidaInstance) -- Mude o nome do método aqui também
        elseif self.tipoEspecial == "Bomba" then
            return CartasEspeciais:explode(partidaInstance, tabuleiroInstance)
        end

    end
    return false
end

return Carta