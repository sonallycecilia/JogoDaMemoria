local Carta = require("classes.carta")
local Animacao = require("interface.animacao")
local MenuPrincipal = require("interface.telas.menuPrincipal")
local Partida = require("classes.partida")
local Config = require("config")
local love = require("love")

if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

local menuPrincipal
local imagemFundoPartida, imagemFundoTelaInicial
local carta, animacao, partida, song

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    imagemFundoPartida = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    imagemFundoTelaInicial = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    
    --song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    --song:setLooping(true)
    --song:play()

    menuPrincipal = MenuPrincipal:new()
    partida = Partida:new("modoDejogo", 3)
    
end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y, button)
    local jogadas = 2
    if partida and partida.tabuleiro and partida.tabuleiro.cartas then
        for _, carta in ipairs(partida.tabuleiro.cartas) do
            if carta:clicada(x, y) then
                carta:alternarLado()
                carta:poder()     
            end
        end
    end

   --menuPrincipal:mousepressed(x, y, button)
end


function love.keypressed(key)
    if key == "w" then
        
    end

end

function love.draw()
    ---love.graphics.clear(1, 1, 1, 1)
    local escalaTelaX = Config.janela.LARGURA_TELA / imagemFundoTelaInicial:getWidth()
    local escalaTelaY = Config.janela.ALTURA_TELA / imagemFundoTelaInicial:getHeight()

    love.graphics.draw(imagemFundoTelaInicial, 0, 0, 0, escalaTelaX, escalaTelaY)
    
    --menuPrincipal:draw()
    
    if partida then
        partida.tabuleiro:draw()
    end
    animacao:draw()
end
