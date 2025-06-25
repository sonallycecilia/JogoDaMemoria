CartasEspeciais = {}

local function getCartaAtIndex(tabuleiro, r, c)
  if r >= 0 and r < tabuleiro.linhas and c >= 0 and c < tabuleiro.colunas then
    local index = r * tabuleiro.colunas + c + 1
    return tabuleiro.cartas[index]
  end
  return nil
end

-- para carta especial de revelação:
function CartasEspeciais:ativarRevelacao(tabuleiro, partida)
  
  local cartasNaoViradas = {}
  
  for _, carta in ipairs(tabuleiro.cartas) do 
    if not carta.revelada and not carta.combinada then
      table.insert(cartasNaoViradas, carta)
    end
  end

  local gruposEncontrados = {}
  
  for _, card in ipairs(cartasNaoViradas) do
    if card.idGrupo and card.idGrupo ~= "especiais" then
        gruposEncontrados[card.idGrupo] = gruposEncontrados[card.idGrupo] or {}
        table.insert(gruposEncontrados[card.idGrupo], card)
    end
end

  local grupoParaCombinar = nil
for idGrupo, grupoDeCartas in pairs(gruposEncontrados) do
    if idGrupo then
        local tamanhoNecessario = partida.modoCompetitivo:obterTamanhoGrupoEsperado(idGrupo)

    if #grupoDeCartas >= tamanhoNecessario then 
      grupoParaCombinar = {}
      for i = 1, tamanhoNecessario do 
        table.insert(grupoParaCombinar, grupoDeCartas[i])
      end
      break -- Encontrou um grupo de cartas completo
  end
end
if grupoParaCombinar and #grupoParaCombinar>0 then
    for _, carta in ipairs(grupoParaCombinar) do
        if not carta.encontrada then
            carta:alternarLado()
            carta.revelada = false -- opcional já setado no alternarLado
        end
    end

    partida.cartasReveladasPelaIA = grupoParaCombinar
    partida.timerRevelacaoIA = 2
    print("Revelação Automática: Grupo: " .. grupoParaCombinar[1].idGrupo .. " encontrado e combinado!")
    partida.modoCompetitivo:processarGrupoEncontrado(grupoParaCombinar, "HUMANO")
    return true
else
    print("Revelação Automática: nenhum grupo completo encontrado")
    return false
end
end
end
-- codigo para ativar carta de bomba:
function CartasEspeciais.explode(partida, tabuleiro, bombCard)
    local cartasPraRevelar = {}

    if not tabuleiro or not tabuleiro.linhas or not tabuleiro.colunas or not tabuleiro.cartas then
        print("[BOMBA] ERRO: Tabuleiro malformado na explosão")
        return false
    end

    local bombRow, bombCol = -1, -1
    for r = 0, tabuleiro.linhas - 1 do
        for c = 0, tabuleiro.colunas - 1 do
            local cartaAtual = getCartaAtIndex(tabuleiro, r, c)
            if cartaAtual == bombCard then
                bombRow = r
                bombCol = c
                break
            end
        end
        if bombRow ~= -1 then break end
    end

    if bombRow == -1 then
        print("BOMBA: ERRO, bombCard não está no tabuleiro")
        return false
    end

    local neighborOffsets = {
        {0, -1}, -- Acima
        {0,  1}, -- Abaixo
        {-1, 0}, -- Esquerda
        {1,  0}  -- Direita
    }

    for _, offset in ipairs(neighborOffsets) do
        local nCol = bombCol + offset[1]
        local nRow = bombRow + offset[2]
        local neighborCard = getCartaAtIndex(tabuleiro, nRow, nCol)
        if neighborCard and not neighborCard.encontrada then
            if not neighborCard.revelada then
                table.insert(cartasPraRevelar, neighborCard)
            else
                -- Se a carta já estava revelada (por seleção do jogador), ignore-a.
                print("BOMBA: Ignorando carta já revelada na posição:", nRow, nCol)
            end
        end
    end

    if #cartasPraRevelar > 0 then
        print("BOMBA: Revelando " .. #cartasPraRevelar .. " cartas temporariamente.")
        -- Revela as cartas que a bomba deve virar
        for _, card in ipairs(cartasPraRevelar) do
            card:alternarLado()         -- Vira a carta para mostrar (se estava oculta)
            card.bombFlipped = true       -- Marca que ela foi virada pela bomba
        end

        partida.bombaCartas = cartasPraRevelar
        partida.timerBomba = partida.tempoParaVirarAposBomba or 1.5
        return true
    else
        print("BOMBA: Nenhuma carta para revelar.")
        return false
    end
end
function CartasEspeciais:ativarCongelamento(tabuleiro, partida, cartaCongelamento)
    print("[Congelamento] Poder de Congelamento ativado!")

    -- Seleciona cartas candidatas: não reveladas, não encontradas, não especiais e não congeladas
    local candidatos = {}
    for _, carta in ipairs(tabuleiro.cartas) do
        if not carta.revelada and not carta.encontrada and not carta.ehEspecial and not carta.congelada then
            table.insert(candidatos, carta)
        end
    end

    if #candidatos < 3 then
        print("[Congelamento] Número insuficiente de cartas para congelar. Encontradas: " .. #candidatos)
        return false
    end

    local cartasParaCongelar = {}
    for i = 1, 3 do
        local idx = math.random(1, #candidatos)
        local cartaSelecionada = table.remove(candidatos, idx)
        cartaSelecionada.congelada = true   -- Marca a carta como congelada
        table.insert(cartasParaCongelar, cartaSelecionada)
    end

    -- Armazena as cartas congeladas na partida para serem descongeladas após o turno da IA
    partida.cartasCongeladas = cartasParaCongelar

    print("[Congelamento] " .. #cartasParaCongelar .. " cartas congeladas.")
    return true
end

return CartasEspeciais