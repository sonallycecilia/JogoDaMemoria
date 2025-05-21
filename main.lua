local Animacao = require("interface.animacao")
<<<<<<< HEAD
local MenuPrincipal = require("interface.telas.menuPrincipal")
local Partida = require("classes.partida")

local Config = require("config")
local love = require("love")
=======
local Tabuleiro = require("classes.tabuleiro")
local Menu = require("interface.menu")
>>>>>>> main

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

<<<<<<< HEAD
    menuPrincipal = MenuPrincipal:new()
    partida = Partida:new("modoDejogo", 3)
=======
    --carregando imagens das cartas
    local cartas = {
        Carta:new(1, "midia/images/cartas/fada.png"),
        Carta:new(2, "midia/images/cartas/naly.png"),
        Carta:new(3, "midia/images/cartas/elfa.png"),
        Carta:new(4, "midia/images/cartas/draenei.png"),
        Carta:new(5, "midia/images/cartas/rogue.png"),
        Carta:new(6, "midia/images/cartas/lua.png"),
        Carta:new(7, "midia/images/cartas/coracao.png"),
        Carta:new(8, "midia/images/cartas/bomba.png"),
        Carta:new(9, "midia/images/cartas/flor.png"),
        Carta:new(10, "midia/images/cartas/gato.png"),
        Carta:new(11, "midia/images/cartas/pocao.png"),
        Carta:new(12, "midia/images/cartas/planta.png"),

    }

    menu = Menu:new()
    tabuleiro = Tabuleiro:new(1, cartas)
>>>>>>> main
    
end

function love.update(dt)
    animacao:update(dt)
end

<<<<<<< HEAD
function love.mousepressed(x, y, button)
    local jogadas = 2
    if partida and partida.tabuleiro and partida.tabuleiro.cartas then
        for _, carta in ipairs(partida.tabuleiro.cartas) do
            if carta:clicada(x, y) and jogadas <= 0 then
                carta:alternarLado()
                carta:poder()
            end
        end
=======
function love.mousepressed(x, y)
    for _, carta in ipairs(tabuleiro.cartas) do
        carta:onClick(x, y)
>>>>>>> main
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
