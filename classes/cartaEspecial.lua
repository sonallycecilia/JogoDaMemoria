local cartasEspeciais = {}
local Config = require("config")
local Score = require("classes.score")
local partida = require("classes.partida")
local tabuleiro = require("classes.tabuleiro")

-- Poder 1: Revelação Automática
function cartasEspeciais.revelaCartas(partida, tabuleiro)
    local grupos = tabuleiro.numCopia
    local naoReveladas = {}
    for _, carta in ipairs(tabuleiro:gerarCopiasComEspeciais()) do
        if not Carta.revelada and not Carta.combinada then
            table.insert(naoReveladas, Carta)
        end
    end 

    if #naoReveladas < grupos then
        print("Revelação Automática: Não há cartas suficientes para formar um grupo.")
        return false -- Não há cartas suficientes para revelar um grupo
    end

    -- Tenta encontrar um grupo completo (pares, trincas, quadras)
    function cartasEspeciais.encontrarGrupo()
    GrupoEncontrado = {}
    local valueCounts = {}
    for _, carta in ipairs(naoReveladas) do
        valueCounts[carta.id] = (valueCounts[carta.id] or 0) + 1
        if valueCounts[carta.id] == grupos then
            -- Encontrou um grupo completo com o 'carta.id'
            for _, c in ipairs(naoReveladas) do
                if c.id == carta.id then
                    table.insert(GrupoEncontrado, c)
                end
            end
            break -- Encontrou um grupo completo, para a busca
        end
    end
    return GrupoEncontrado
end

-- Poder 2 - Parte 1: Congelamento (Ativa o modo de seleção do jogador)
-- Sinaliza à partida que o jogador humano precisa selecionar uma carta para congelar.
-- Retorna true para indicar que a seleção está ativa.
function cartasEspeciais.activate_freeze_selection(partida, tabuleiro)
    partida.awaitingFreezeSelection = true -- Define a flag na instância da Partida
    partida.freezeTargetCard = nil -- Limpa qualquer alvo anterior
    print("Congelamento: Selecione uma carta para congelar para o seu oponente.")
    -- A GUI precisará mostrar uma mensagem na tela para o jogador.
    return true -- Indica que o poder foi ativado (e espera input)
end

-- Poder 2 - Parte 2: Congelamento (Aplica o efeito na carta alvo selecionada)
-- targetCard: A instância da carta que o jogador selecionou para congelar.
-- partidaInstance: Instância da partida para gerenciar o estado do congelamento.
-- mudar em partida pra que a ia nao possa selecionar carta congelada
function cartasEspeciais.congelaCarta(partida, cartaEscolhida)
    cartaEscolhida.taCongelada = true -- Marca a carta como congelada
    partida.cartaCongelada = cartaEscolhida -- Guarda a referência da carta congelada na Partida
    partida.tempoGelo = 1 -- Congela por 1 turno do oponente (ou defina em Config)

    print("Congelamento: Carta " .. cartaEscolhida.id .. " congelada por " .. partida.tempoGelo .. " turno.")
    return true
end

-- Poder 3: Bomba
-- Revela as 4 cartas que estão ao redor da carta bomba.
-- bombCard: A instância da carta especial "Bomba" que foi virada.
function cartasEspeciais.explode(partida, tabuleiro, bomba)
    local revealedCount = 0
    local allCards = tabuleiro:get_all_cards()

    -- Encontra o índice da carta bomba no array linearizado de cartas do tabuleiro
    local bombIndex = -1
    for i, card in ipairs(allCards) do
        if card == bomba then
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
    local col = (bombIndex - 1) % tabuleiro.colunas
    local row = math.floor((bombIndex - 1) / tabuleiro.colunas)

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
        if nCol >= 0 and nCol < tabuleiro.colunas and
           nRow >= 0 and nRow < tabuleiro.linhas and
           not (offset[1] == 0 and offset[2] == 0) then -- Não é a própria bomba
            
            local neighborIndex = nRow * tabuleiro.colunas + nCol + 1
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
        tabuleiro:adicionarRevelada(card) -- Adiciona à memória da IA temporariamente
        love.timer.after(Config.tempoRevelada, function()
            if not card.combinada and card.revelada then -- Desvira apenas se não foi combinada durante a pausa
                card:desvirar()
                tabuleiro:removerRevelada(card) -- Remover da memória da IA se não for combinada
            end
        end)
    end

    -- A carta bomba em si é combinada após a ativação (e pode ser removida do tabuleiro visualmente)
    bomba:marcarComoCombinada()
    tabuleiro:removerRevelada(bomba) -- Remove da memória da IA
    partida.matchesFound = partida.matchesFound + 1 -- A bomba conta como um match

    print("Bomba: Reveladas " .. revealedCount .. " cartas ao redor!")
    return true
end

return cartasEspeciais