local cartaEspecial = require "cartaEspecial"
Carta = {}
Carta.__index = Carta --permite usar metodo com dois pontos

local ALTURA = 100
local LARGURA = 100
local VERSO = "midia/images/verso.png"

function Carta:new(id, caminhoImagemFrente, ehEspecial, tipoEspecial)
    local novaCarta = {
        id = id,
        idGrupo = nil,
        largura = LARGURA,
        altura = ALTURA,
        pathImagem = caminhoImagemFrente, --precisa ficar pois pegamos o caminho da imagem
        imagemFrente = love.graphics.newImage(caminhoImagemFrente),
        imagemVerso = love.graphics.newImage(VERSO),
        revelada = false, -- se não for passado, assume false
        posX = nil,
        posY = nil,
        rodadaEncontrada = nil,
        probErro = 0,
        ehEspecial = ehEspecial or false,
        tipoEspecial = tipoEspecial,
        taCongelada = false
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


-- Função para verificar se a carta foi clicada (verificação de clique na area)
function Carta:clicada(mx, my)
   Carta.revelada = true
    return mx >= self.x and mx <= self.x + self.largura and
           my >= self.y and my <= self.y + self.altura

end

-- function Carta:onClick(mx, my)
--     if self:clicada(mx, my) then
--         self:alternarLado()
--     end
-- end

-- Função para desenhar a carta (exibe a frente ou o verso dependendo do estado)
function Carta:draw()
    if self.revelada then
        self:drawImagem(self.imagemFrente)  -- Desenha a frente se revelada
        if self.ehEspecial then
            -- Desenha um brilho ou borda especial para cartas especiais reveladas
            love.graphics.setColor(1, 0.8, 0, 1) -- Cor amarela/laranja para destaque
            love.graphics.rectangle("line", self.x, self.y, self.largura, self.altura)
            love.graphics.setColor(1, 1, 1, 1) -- Reseta a cor
        end
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

function Carta:poder(partidaInstance, tabuleiroInstance)
    if self.ehEspecial and self.tipoEspecial then
        if self.tipoEspecial == "Revelacao" then
            return cartaEspecial.apply_revelation(partidaInstance, tabuleiroInstance)
        elseif self.tipoEspecial == "Congelamento" then
            -- O congelamento é um poder que requer input do jogador para selecionar a carta alvo
            return cartaEspecial.activate_freeze_selection(partidaInstance, tabuleiroInstance)
        elseif self.tipoEspecial == "Bomba" then
            -- A bomba revela cartas ao redor dela, e a própria bomba é o ponto de referência
            return cartaEspecial.apply_bomb(partidaInstance, tabuleiroInstance, self)
        end
    end
    return false -- Retorna falso se não ativou nenhum poder ou não é especial
end



return Carta
