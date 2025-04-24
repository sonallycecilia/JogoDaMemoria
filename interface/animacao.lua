-- interface/Animacao.lua
local anim8 = require("anim8")

local Animacao = {}
Animacao.__index = Animacao

function Animacao.nova(caminho, largura, altura, frames, tempo)
    local self = setmetatable({}, Animacao)
    self.imagem = love.graphics.newImage(caminho)
    local grid = anim8.newGrid(largura, altura, self.imagem:getWidth(), self.imagem:getHeight())
    self.anim = anim8.newAnimation(grid(frames, 1), tempo)
    self.x = 0
    self.y = 0
    return self
end

function Animacao:setPosicao(x, y)
    self.x = x
    self.y = y
end

function Animacao:update(dt)
    self.anim:update(dt)
end

function Animacao:draw()
    self.anim:draw(self.imagem, self.x, self.y)
end

return Animacao
