local Config = require("config")
local Frame = {}
local Frame_mt = { __index = Frame }

-- O construtor agora recebe apenas uma tabela de configurações
function Frame:new(configTable, x, y, scaleX, scaleY)
    
    local novoFrame = {
        --posição do frame
        x = x or Config.x,
        y = y or Config.y,
        -- largura e altura do frame
        largura = Config.largura,
        altura = Config.altura,
        --imagem do frame
        imagemPath = configTable.imagemPath,
        image = nil, -- aqui já chamamos de "image"
        
        -- Pega as escalas da config, com padrão 1.0 se não definidas
        scaleX = scaleX or Config.scaleX or 1.0,
        scaleY = scaleY or Config.scaleY or 1.0,
    }
    
    if novoFrame.imagemPath then
        novoFrame.image = love.graphics.newImage(novoFrame.imagemPath)
    end
    
    setmetatable(novoFrame, Frame_mt)
    
    return novoFrame
end

-- Novo método para definir a escala do frame
function Frame:setScale(newScaleX, newScaleY)
    self.scaleX = newScaleX
    self.scaleY = newScaleY
end

-- Método para desenhar o frame
function Frame:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.largura, self.altura)
    end
end

return Frame