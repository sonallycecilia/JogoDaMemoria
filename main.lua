local Animacao = require("interface.animacao")
local Menu = require("interface.menu")
local Frame = require("interface.frame")
local Botao = require("interface.botao")
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

local animacao
local botoes = {}
local botaoIniciarJogo, botaoConfiguracao, botaoConquistas, botaoCreditos, botaoSkins, botaoSair
local imagemAtualFundo, imagemFundoPartida, imagemFundoTelaInicial

local partida
local song

function love.load()
    animacao = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    animacao:setPosicao(850, 0)


    imagemFundoPartida = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    imagemFundoTelaInicial = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    
    --song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    --song:setLooping(true)
    --song:play()

        --Botões
    botaoIniciarJogo = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.iniciarJogo,
                    80, 500,
                    0.5, 0.5,
                    function()
                        partida = Partida:new(Config.deck)
    end)

    botaoConfiguracao = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.configuracoes,
                    80, 560,
                    0.5, 0.5,
                    function()
                        print("Configurações")
    end)

    botaoConquistas = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.conquistas,
                    80, 620,
                    0.5, 0.5,
                    function()
                        print("Conquistas")
    end)

    botaoCreditos = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.creditos,
                    80, 680,
                    0.5, 0.5,
                    function()
                        print("Créditos")
    end)

    botaoSkins = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.skins,
                    80, 740,
                    0.5, 0.5,
                    function()
                        print("Skins")
    end)

    botaoSair = Botao:new(Config,
                    Config.botoes.imagemPath.menuPrincipal.sair,
                    1400, 740,
                    0.5, 0.5,
                    function()
                        love.event.quit()
    end)

    table.insert(botoes, botaoIniciarJogo)
    table.insert(botoes, botaoConfiguracao)
    table.insert(botoes, botaoConquistas)
    table.insert(botoes, botaoCreditos)
    table.insert(botoes, botaoSkins)
    table.insert(botoes, botaoSair)

end

function love.update(dt)
    animacao:update(dt)
end

function love.mousepressed(x, y, button)
    if button == 1 then -- botão esquerdo
        for _, botao in ipairs(botoes) do
            botao:clicar()
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    for _, botao in ipairs(botoes) do
        botao:update(x, y)
    end
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

    love.graphics.draw(imagemFundoTelaInicial, 0, 0, 0, escalaTelaX, escalaTelaY)
    
    -- desenhando botoes
    for _, botao in ipairs(botoes) do
        botao:draw()
    end
    --animacao:draw()
end
