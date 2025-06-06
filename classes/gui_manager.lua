local GuiManager = {}

local menuState = {
    selectedMode = "Competitivo",
    selectedLevel = "Fácil",
    playerName = "Jogador 1",
    inputActive = false
}

local fonts = {}

-- Esta função carrega as fontes e deve ser chamada uma única vez em love.load()
function GuiManager.load_fonts()
    -- As fontes ainda precisam ser decididas:
    fonts.title = love.graphics.newFont("arquivo com a fonte", 12) -- path pra fonte, tamanho da fonte
    fonts.heading = love.graphics.newFont()
    fonts.text = love.graphics.newFont()
    fonts.small = love.graphics.newFont()
end

-- Função para desenhar o menu principal
-- onStartGameCallback e onShowTop5Callback são funções que o main.lua passou para o GuiManager para que ele saiba o que fazer quando os botões são clicados.

function GuiManager.draw_menu(onStartGameCallback, onShowTop5Callback)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, 1) -- Branco, mas definir cor
    love.graphics.print("Jogo da Memória", love.graphics.getWidth() / 2 - fonts.title:getWidth("Jogo da Memória") / 2, 50)

    local startY = 200

    -- Nome do Jogador
    love.graphics.setFont(fonts.heading)
    love.graphics.print("Nome do Jogador:", love.graphics.getWidth() / 2 - 150, startY)
    love.graphics.rectangle("line", love.graphics.getWidth() / 2, startY, 200, 30)
    love.graphics.setFont(fonts.text)
    love.graphics.print(menuState.playerName, love.graphics.getWidth() / 2 + 5, startY + 5)
    if menuState.inputActive then
        -- Desenha um cursor simples se o campo de input estiver ativo
        love.graphics.rectangle("fill", love.graphics.getWidth() / 2 + fonts.text:getWidth(menuState.playerName) + 5, startY + 5, 2, 20)
    end
    startY = startY + 50

    -- Modo de Jogo
    love.graphics.setFont(fonts.heading)
    love.graphics.print("Modo de Jogo:", love.graphics.getWidth() / 2 - 150, startY)
    local modes = {"Competitivo", "Cooperativo"}
    for i, mode in ipairs(modes) do
        local x = love.graphics.getWidth() / 2 + (i - 1) * 120
        love.graphics.setColor(menuState.selectedMode == mode and 0.5 or 1, 1, 1, 1) -- Destaca selecionado
        love.graphics.rectangle("fill", x, startY, 100, 30)
        love.graphics.setColor(0, 0, 0, 1) -- Texto preto
        love.graphics.print(mode, x + 10, startY + 5)
        love.graphics.setColor(1, 1, 1, 1) -- Reseta a cor
    end
    startY = startY + 50

    -- Nível de Dificuldade
    love.graphics.setFont(fonts.heading)
    love.graphics.print("Nível:", love.graphics.getWidth() / 2 - 150, startY)
    local levels = {"Fácil", "Médio", "Difícil", "Extremo"}
    for i, level in ipairs(levels) do
        local x = love.graphics.getWidth() / 2 + (i - 1) * 80
        love.graphics.setColor(menuState.selectedLevel == level and 0.5 or 1, 1, 1, 1)
        love.graphics.rectangle("fill", x, startY, 70, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(level, x + 5, startY + 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
    startY = startY + 80

    -- Botões de Ação
    love.graphics.setColor(0, 1, 0, 1) -- Verde para "Iniciar Jogo"
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 100, startY, 200, 40)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(fonts.heading)
    love.graphics.print("Iniciar Jogo", love.graphics.getWidth() / 2 - fonts.heading:getWidth("Iniciar Jogo") / 2, startY + 5)
    startY = startY + 60

    love.graphics.setColor(0, 0, 1, 1) -- Azul para "Ver Top 5"
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 100, startY, 200, 40)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Ver Top 5", love.graphics.getWidth() / 2 - fonts.heading:getWidth("Ver Top 5") / 2, startY + 5)
    love.graphics.setColor(1, 1, 1, 1)

    -- Armazena os callbacks para serem usados em mouse_pressed
    GuiManager.onStartGameCallback = onStartGameCallback
    GuiManager.onShowTop5Callback = onShowTop5Callback
end

-- Lida com cliques do mouse na tela de menu
function GuiManager.menu_mouse_pressed(x, y, button)
    local startY = 200
    -- Clicar no campo de nome do jogador
    if x >= love.graphics.getWidth() / 2 and x <= love.graphics.getWidth() / 2 + 200 and
       y >= startY and y <= startY + 30 then
        menuState.inputActive = true
    else
        menuState.inputActive = false
    end

    startY = startY + 50
    -- Seleção de Modo
    local modes = {"Competitivo", "Cooperativo"}
    for i, mode in ipairs(modes) do
        local buttonX = love.graphics.getWidth() / 2 + (i - 1) * 120
        if x >= buttonX and x <= buttonX + 100 and
           y >= startY and y <= startY + 30 then
            menuState.selectedMode = mode
            return -- Retorna após encontrar um clique
        end
    end
    startY = startY + 50

    -- Seleção de Nível
    local levels = {"Fácil", "Médio", "Difícil", "Extremo"}
    for i, level in ipairs(levels) do
        local buttonX = love.graphics.getWidth() / 2 + (i - 1) * 80
        if x >= buttonX and x <= buttonX + 70 and
           y >= startY and y <= startY + 30 then
            menuState.selectedLevel = level
            return
        end
    end
    startY = startY + 80

    -- Botão "Iniciar Jogo"
    if x >= love.graphics.getWidth() / 2 - 100 and x <= love.graphics.getWidth() / 2 + 100 and
       y >= startY and y <= startY + 40 then
        if GuiManager.onStartGameCallback then
            -- Chama o callback passando as seleções do jogador
            GuiManager.onStartGameCallback(menuState.selectedMode, menuState.selectedLevel, menuState.playerName)
        end
        return
    end
    startY = startY + 60

    -- Botão "Ver Top 5"
    if x >= love.graphics.getWidth() / 2 - 100 and x <= love.graphics.getWidth() / 2 + 100 and
       y >= startY and y <= startY + 40 then
        if GuiManager.onShowTop5Callback then
            GuiManager.onShowTop5Callback()
        end
        return
    end
end

-- Lida com entrada de teclado no menu (para o nome do jogador)
function GuiManager.menu_key_pressed(key)
    if menuState.inputActive then
        if key == "backspace" then
            menuState.playerName = string.sub(menuState.playerName, 1, #menuState.playerName - 1)
        elseif key == "return" or key == "kpenter" then
            menuState.inputActive = false
        elseif string.len(key) == 1 and key:match("%a") then -- Apenas letras (para nomes)
            menuState.playerName = menuState.playerName .. key
        end
    end
end

-- Retorna o estado atual do menu (seleções do jogador)
function GuiManager.get_menu_state()
    return menuState
end

-- Desenha as informações da partida durante o jogo
function GuiManager.draw_game_info(currentPlayerType, elapsedTime, score, hints, hintCooldown)
    love.graphics.setFont(fonts.text)
    love.graphics.setColor(1, 1, 1, 1) -- Branco

    love.graphics.print("Jogador: " .. currentPlayerType, 20, 20)
    love.graphics.print(string.format("Tempo: %.1f", elapsedTime), 20, 50)
    love.graphics.print("Pontuação: " .. score, 20, 80)
    love.graphics.print("Dicas: " .. hints, 20, 110)
    if hintCooldown > 0 then
        love.graphics.print(string.format("Dica em %.1f s", hintCooldown), 20, 140)
    end
end

-- Exibe uma dica temporariamente (as cartas são viradas pelo GameManager/Partida)
function GuiManager.show_temporary_hint(cards)
    -- Esta função apenas informa que a dica foi dada, a lógica de virar/desvirar está na Partida.
    -- Aqui você pode tocar um som de dica, ou mostrar uma mensagem pop-up.
    print("Dica: cartas reveladas temporariamente!")
    for _, card in ipairs(cards) do
        print("- " .. card.id)
    end
end

-- Desenha a tela de fim de jogo
function GuiManager.draw_game_over_screen(finalScore, mode, level, time)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 0, 0, 1) -- Vermelho
    local text = "FIM DE JOGO!"
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.title:getWidth(text) / 2, love.graphics.getHeight() / 2 - 50)

    love.graphics.setFont(fonts.heading)
    love.graphics.setColor(1, 1, 1, 1) -- Branco
    text = "Sua Pontuação: " .. finalScore
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.heading:getWidth(text) / 2, love.graphics.getHeight() / 2 + 20)
    text = "Modo: " .. mode .. " | Nível: " .. level
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.heading:getWidth(text) / 2, love.graphics.getHeight() / 2 + 50)
    text = string.format("Tempo: %.1f segundos", time)
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.heading:getWidth(text) / 2, love.graphics.getHeight() / 2 + 80)
end

-- Desenha a tela do Top 5
function GuiManager.draw_top5(scores, onBackToMenuCallback)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(0, 0.7, 0, 1) -- Verde escuro
    local text = "TOP 5 - Jogo da Memória"
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.title:getWidth(text) / 2, 50)

    love.graphics.setFont(fonts.heading)
    love.graphics.setColor(1, 1, 1, 1) -- Branco
    local header = "Nome           Modo           Nível          Pontuação      Tempo        Data/Hora"
    love.graphics.print(header, 50, 150)

    local startY = 180
    love.graphics.setFont(fonts.text)
    if #scores == 0 then
        text = "Nenhuma pontuação registrada ainda."
        love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.text:getWidth(text) / 2, startY + 20)
    else
        for i, score in ipairs(scores) do
            local line = string.format("%-15s%-15s%-15s%-15d%-12.1f%s",
                score.name, score.mode, score.level, score.score, score.time, score.date_time)
            love.graphics.print(line, 50, startY + (i - 1) * 30)
        end
    end

    love.graphics.setColor(0, 0, 1, 1) -- Azul para "Voltar"
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 75, love.graphics.getHeight() - 80, 150, 40)
    love.graphics.setColor(0, 0, 0, 1) -- Texto preto
    love.graphics.setFont(fonts.heading)
    text = "Voltar"
    love.graphics.print(text, love.graphics.getWidth() / 2 - fonts.heading:getWidth(text) / 2, love.graphics.getHeight() - 75)
    love.graphics.setColor(1, 1, 1, 1)

    -- Armazena o callback para ser usado em top5_mouse_pressed
    GuiManager.onBackToMenuCallback = onBackToMenuCallback
end

-- Lida com cliques do mouse na tela do Top 5
function GuiManager.top5_mouse_pressed(x, y, button)
    -- Botão "Voltar"
    if x >= love.graphics.getWidth() / 2 - 75 and x <= love.graphics.getWidth() / 2 + 75 and
       y >= love.graphics.getHeight() - 80 and y <= love.graphics.getHeight() - 40 then
        if GuiManager.onBackToMenuCallback then
            GuiManager.onBackToMenuCallback()
        end
    end
end

return GuiManager