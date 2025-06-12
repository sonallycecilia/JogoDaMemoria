-- classes/special_cards.lua
local SpecialCards = {}
local Config = require("config") -- Para acessar configurações como tempos de dicas, etc.

-- Poder 1: Revelação Automática
-- Revela automaticamente um par, trinca ou quadra.
-- Retorna true se um grupo foi revelado e combinado, false caso contrário.
function SpecialCards.apply_revelation(partidaInstance, tabuleiroInstance)
    local groupSize = partidaInstance.groupSize -- O tamanho do grupo atual do jogo (pares, trincas, quadras)
    local unflippedCards = {}
    for _, card in ipairs(tabuleiroInstance:get_all_cards()) do
        if not card.revelada and not card.combinada then
            table.insert(unflippedCards, card)
        end
    end

    if #unflippedCards < groupSize then
        print("Revelação Automática: Não há cartas suficientes para formar um grupo.")
        return false -- Não há cartas suficientes para revelar um grupo
    end

    -- Tenta encontrar um grupo completo (pares, trincas, quadras)
    local foundGroup = {}
    local valueCounts = {}
    for _, card in ipairs(unflippedCards) do
        valueCounts[card.id] = (valueCounts[card.id] or 0) + 1
        if valueCounts[card.id] == groupSize then
            -- Encontrou um grupo completo com o 'card.id'
            for _, c in ipairs(unflippedCards) do
                if c.id == card.id then
                    table.insert(foundGroup, c)
                end
            end
            break -- Encontrou um grupo completo, para a busca
        end
    end

    if #foundGroup == groupSize then
        -- Virar e combinar as cartas do grupo encontrado
        for _, card in ipairs(foundGroup) do
            card:virar()
            card:marcarComoCombinada() -- Marca como combinada para removê-las da interação
            tabuleiroInstance:removerRevelada(card) -- Remove da memória da IA
        end
        partidaInstance.matchesFound = partidaInstance.matchesFound + 1 -- Aumenta o contador de grupos encontrados
        Scoring.add_points_for_match(groupSize) -- Adiciona pontos pela combinação
        print("Revelação Automática: Grupo encontrado e combinado!")
        return true
    end

    print("Revelação Automática: Não foi possível encontrar um grupo completo.")
    return false -- Não foi possível encontrar um grupo completo para revelar
end

-- Poder 2 - Parte 1: Congelamento (Ativa o modo de seleção do jogador)
-- Sinaliza à partida que o jogador humano precisa selecionar uma carta para congelar.
-- Retorna true para indicar que a seleção está ativa.
function SpecialCards.activate_freeze_selection(partidaInstance, tabuleiroInstance)
    partidaInstance.awaitingFreezeSelection = true -- Define a flag na instância da Partida
    partidaInstance.freezeTargetCard = nil -- Limpa qualquer alvo anterior
    print("Congelamento: Selecione uma carta para congelar para o seu oponente.")
    -- A GUI precisará mostrar uma mensagem na tela para o jogador.
    return true -- Indica que o poder foi ativado (e espera input)
end

-- Poder 2 - Parte 2: Congelamento (Aplica o efeito na carta alvo selecionada)
-- targetCard: A instância da carta que o jogador selecionou para congelar.
-- partidaInstance: Instância da partida para gerenciar o estado do congelamento.
function SpecialCards.apply_freeze(partidaInstance, targetCard)
    targetCard.taCongelada = true -- Marca a carta como congelada
    partidaInstance.frozenCard = targetCard -- Guarda a referência da carta congelada na Partida
    partidaInstance.freezeDuration = 1 -- Congela por 1 turno do oponente (ou defina em Config)

    print("Congelamento: Carta " .. targetCard.id .. " congelada por " .. partidaInstance.freezeDuration .. " turno(s).")
    return true
end

-- Poder 3: Bomba
-- Revela as 4 cartas que estão ao redor da carta bomba.
-- bombCard: A instância da carta especial "Bomba" que foi virada.
function SpecialCards.apply_bomb(partidaInstance, tabuleiroInstance, bombCard)
    local revealedCount = 0
    local allCards = tabuleiroInstance:get_all_cards()

    -- Encontra o índice da carta bomba no array linearizado de cartas do tabuleiro
    local bombIndex = -1
    for i, card in ipairs(allCards) do
        if card == bombCard then
            bombIndex = i
            break
        end
    end

    if bombIndex == -1 then
        print("Bomba: Carta bomba não encontrada no tabuleiro.")
        return false
    end

    -- Obter a linha e coluna da carta bomba
    -- Ajuste para 0-indexed para cálculos de grid
    local col = (bombIndex - 1) % tabuleiroInstance.colunas
    local row = math.floor((bombIndex - 1) / tabuleiroInstance.colunas)

    -- Coordenadas dos vizinhos (inclui a própria carta bomba no centro como referência)
    local neighborOffsets = {
        {-1, -1}, {0, -1}, {1, -1}, -- Acima
        {-1,  0}, {0,  0}, {1,  0}, -- Mesmo nível (0,0 é a própria bomba)
        {-1,  1}, {0,  1}, {1,  1}  -- Abaixo
    }

    local cardsToReveal = {}
    for _, offset in ipairs(neighborOffsets) do
        local nCol = col + offset[1]
        local nRow = row + offset[2]

        -- Verifica se o vizinho está dentro dos limites do tabuleiro e não é a própria bomba
        if nCol >= 0 and nCol < tabuleiroInstance.colunas and
           nRow >= 0 and nRow < tabuleiroInstance.linhas and
           not (offset[1] == 0 and offset[2] == 0) then -- Não é a própria bomba
            
            local neighborIndex = nRow * tabuleiroInstance.colunas + nCol + 1
            local neighborCard = allCards[neighborIndex]

            -- Se a carta vizinha existe, não está virada e não foi combinada
            if neighborCard and not neighborCard.revelada and not neighborCard.combinada then
                table.insert(cardsToReveal, neighborCard)
                revealedCount = revealedCount + 1
            end
        end
    end

    -- Revela as cartas temporariamente
    for _, card in ipairs(cardsToReveal) do
        card:virar()
        tabuleiroInstance:adicionarRevelada(card) -- Adiciona à memória da IA temporariamente
        love.timer.after(Config.TEMPOS.TEMPO_DICA_REVELADA, function()
            if not card.combinada and card.revelada then -- Desvira apenas se não foi combinada durante a pausa
                card:desvirar()
                tabuleiroInstance:removerRevelada(card) -- Remover da memória da IA se não for combinada
            end
        end)
    end

    -- A carta bomba em si é combinada após a ativação (e pode ser removida do tabuleiro visualmente)
    bombCard:marcarComoCombinada()
    tabuleiroInstance:removerRevelada(bombCard) -- Remove da memória da IA
    partidaInstance.matchesFound = partidaInstance.matchesFound + 1 -- A bomba conta como um match

    print("Bomba: Reveladas " .. revealedCount .. " cartas ao redor!")
    return true
end

return SpecialCards