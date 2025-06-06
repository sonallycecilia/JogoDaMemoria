-- main.lua
-- Carregando seus módulos existentes
local LayerManager = require("layers.layerManager")
local Animacao = require("interface.animacao")

-- Carregando os módulos essenciais do jogo da memória
local Config = require("config")
local Partida = require("classes.partida") -- Renomeado de GameManager para Partida
local GuiManager = require("classes.gui_manager")
local DbManager = require("classes.database_manager")

-- Configuração do debugger para VS Code
if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end

-- Instâncias globais que o main gerencia
local manager = LayerManager:new() -- Seu gerenciador de camadas
local animacao_heart -- Sua animação de coração

-- Imagens de fundo globais (carregadas em love.load)
local initialScreenImage
local gameScreenImage
local menuFrameImage -- Para o fundo do menu (se for um frame diferente do fundo da tela inicial)

-- Dimensões da tela (obtidas em love.load)
local screenWidth
local screenHeight

function love.load()
    love.window.setTitle("Jogo da Memória")
    -- Define as dimensões da janela do jogo a partir das configurações
    love.window.setMode(Config.JANELA.LARGURA_PADRAO, Config.JANELA.ALTURA_PADRAO, { fullscreen = false, resizable = false })

    -- Obtém as dimensões reais da tela após love.window.setMode
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Carrega as imagens de fundo usando os caminhos do Config
    initialScreenImage = love.graphics.newImage(Config.JANELA.IMAGEM_TELA_INICIAL)
    gameScreenImage = love.graphics.newImage(Config.JANELA.IMAGEM_TELA_PARTIDA)
    menuFrameImage = love.graphics.newImage(Config.frames.menu.imagemPath)

    -- Inicializa o banco de dados do Top5
    DbManager.init_db()

    -- Carrega todas as fontes necessárias para a interface gráfica
    GuiManager.load_fonts()

    -- Inicializa sua animação de coração
    animacao_heart = Animacao.nova("midia/sprites/heart_sprite.png", 64, 64, '1-7', 0.1)
    -- Ajuste a posição da animação para ser relativa à tela, se necessário
    animacao_heart:setPosicao(screenWidth - 100, 10) -- Exemplo: canto superior direito

    -- Define a camada inicial do jogo (ex: "menuPrincipal")
    manager:setLayer("menuPrincipal")

    -- Exemplo de música (comentado para não interferir nos testes iniciais)
    -- local song = love.audio.newSource("midia/audio/loop-8-28783.mp3", "stream")
    -- song:setLooping(true)
    -- song:play()
end

function love.update(dt)
    -- Atualiza a animação global
    animacao_heart:update(dt)

    -- Atualiza a camada atual do LayerManager
    manager:update(dt)

    -- Lógica para transição de camadas:
    local layerAtual = manager.currentLayer
    if layerAtual and layerAtual.proximaLayer then
        -- Se a camada atual indicou uma próxima camada, faz a transição
        -- A camada que inicia o jogo (ex: 'gameSelection') deverá criar a instância de Partida
        -- e passá-la como um argumento para a camada 'game_play'.
        manager:setLayer(layerAtual.proximaLayer, layerAtual.partidaInstance) -- Passa a instância da partida se houver
        layerAtual.proximaLayer = nil -- Limpa a flag de próxima camada
        layerAtual.partidaInstance = nil -- Limpa a referência da instância da partida
    end
end

function love.mousepressed(x, y, button)
    manager:mousepressed(x, y, button) -- Direciona o clique para a camada ativa
end

function love.mousemoved(x, y, dx, dy)
    manager:mousemoved(x, y, dx, dy) -- Direciona o movimento do mouse para a camada ativa
end

function love.keypressed(key)
    manager:keypressed(key) -- Direciona o evento de tecla para a camada ativa

    -- Lógica de saída global
    if (key == "escape") or (key == "q") then
        love.event.quit()
    end
end

function love.draw()
    -- Desenha a imagem de fundo principal, dependendo da camada atual
    local currentLayerName = manager.currentLayerName
    if currentLayerName == "menuPrincipal" or currentLayerName == "gameSelection" or currentLayerName == "top5" then
        love.graphics.draw(initialScreenImage, 0, 0, 0, screenWidth / initialScreenImage:getWidth(), screenHeight / initialScreenImage:getHeight())
        love.graphics.draw(menuFrameImage, (screenWidth - menuFrameImage:getWidth() * Config.scaleX) / 2, (screenHeight - menuFrameImage:getHeight() * Config.scaleY) / 2, 0, Config.scaleX, Config.scaleY)
    elseif currentLayerName == "game_play" then -- Assumindo que sua camada de partida se chamará "game_play"
        love.graphics.draw(gameScreenImage, 0, 0, 0, screenWidth / gameScreenImage:getWidth(), screenHeight / gameScreenImage:getHeight())
    end

    -- Desenha o conteúdo da camada atual (menus, tabuleiro do jogo, ranking)
    manager:draw()

    -- Desenha sua animação global (ex: o coração)
    animacao_heart:draw()
end