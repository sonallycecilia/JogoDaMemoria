local menuJogo = {}
menuJogo.__index = menuJogo

function menuJogo:new(manager)
    local self = setmetatable({}, menuJogo)
    self.manager = manager
    return self
end

function menuJogo:draw()
    love.graphics.clear(0, 0, 0.2, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Você está na tela do jogo!", 100, 100)
end

return menuJogo
