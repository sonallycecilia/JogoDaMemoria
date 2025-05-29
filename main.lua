local Animacao = require("interface.animacao")
local Menu = require("interface.menu")

local Partida = require("classes.partida")

local Config = require("config")

if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

local menuPrincipal, animacao
local botoes = {}
local video
local videoSource
local botaoIniciarPartida, botaoConfiguracao, botaoSair
local imagemAtualFundo, imagemFundoPartida, imagemFundoTelaInicial

local partida
local song

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)

    video = love.graphics.newVideo("midia/videos/telaInicial.ogv")
    if not video then
        error("Falha ao carregar o vídeo!")
    else
        video:setLooping(true)
        video:play()
    end



    imagemFundoPartida = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    imagemFundoTelaInicial = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    
    --song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    --song:setLooping(true)
    --song:play()

    menuPrincipal = Menu:new()
end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y)
   --menuPrincipal:mousepressed(x, y, button)
end


function love.keypressed(key)
    if key == "x" then
        love.event.quit()
    end
end

function love.draw()
    ---love.graphics.clear(1, 1, 1, 1)
    local escalaTelaX = Config.janela.LARGURA_TELA / imagemFundoTelaInicial:getWidth()
    local escalaTelaY = Config.janela.ALTURA_TELA / imagemFundoTelaInicial:getHeight()

    love.graphics.draw(video, 100, 100)

    love.graphics.draw(imagemFundoTelaInicial, 0, 0, 0, escalaTelaX, escalaTelaY)
    --menuPrincipal:draw()
    animacao:draw()
end
