CartasEspeciais = {}
CartasEspeciais.__index = CartasEspeciais

local tabuleiro = require("classes.tabuleiro")
local partida = require("classes.partida")

function CartasEspeciais:new(Carta)
    local cartaEspecial = {
      tamGrupo = Carta.nivel + 1,
      idGrupo = Carta.idGrupo 
    }
setmetatable(cartaEspecial, CartasEspeciais)
return cartaEspecial
end
-- para carta especial de revelação:
function CartasEspeciais:ativarRevelacao(tabuleiro, partida)
  local tamGrupo = partida.tamGrupo
  local cartasNaoViradas = {}
  
  for _, carta in ipairs(tabuleiro:getAllCartas()) do 
    if not carta.revelada and not carta.combinada and not carta.taCongelada then
      table.insert(cartasNaoViradas, carta)
    end
  end
  
  local encontrouGrupo = {}
  local valoresCartas = {}
  
  for _, card in ipairs(cartasNaoViradas) do
    valoresCartas[card.idGrupo] = (valoresCartas[card.idGrupo] or 0) + 1
  if valoresCartas[card.idGrupo] == tamGrupo then
    for _, c in ipairs(cartasNaoViradas) do
      if c.idGrupo == card.idGrupo then
        table.insert(encontrouGrupo, c)
      end
    end
  break
end
end
  if #encontrouGrupo == tamGrupo then
    for _, card in ipairs(encontrouGrupo) do
      card:alternarLado()
      card:cartaCombinada()
      tabuleiro:removerCarta(card)
    end --avisar a partida e a tabuleiro que foi removido
    print("Revelação Automática: Grupo encontrado e combinado!")
    return true
  end
return false
end

function CartasEspeciais.explode(partida, tabuleiro, bombCard)
  local contReveladas = 0
  local allCards = tabuleiro:getAllCards()
  
  local indexBomba =-1
  for i, card in ipairs(allCards) do
    if card == bombCard then 
      bombIndex = i
      break
    end
  end
  
  if bombIndex == -1 then
    return false
  end
end

local colunas= (bombIndex - 1) % tabuleiro.colunas
local row = math.floor((bombIndex - 1) / tabuleiro.colunas)

    -- Offsets para os vizinhos (inclui a própria carta bomba no centro como referência, que será excluída)
    local neighborOffsets = {
        {-1, -1}, {0, -1}, {1, -1},
        {-1,  0}, {0,  0}, {1,  0},
        {-1,  1}, {0,  1}, {1,  1} 
    }
  
  local cartasPraRevelar = {}
  for _, offset in ipairs(neighborOffsets) do
  local nCol = colunas + offset[1]
        local nRow = row + offset[2]

        -- Verifica se o vizinho está dentro dos limites do tabuleiro e não é a própria bomba
        if nCol >= 0 and nCol < tabuleiro.colunas and
           nRow >= 0 and nRow < tabuleiro.linhas and
           not (offset[1] == 0 and offset[2] == 0) then
            
            local neighborIndex = nRow * tabuleiro.colunas + nCol + 1
            local neighborCard = allCards[neighborIndex]
            if neighborCard and not neighborCard.revelada and not neighborCard.combinada and not neighborCard.isFrozen then
                table.insert(cartasPraRevelar, neighborCard)
            end
        end
    end  
  if #cartasPraRevelar > 4 then
    local cartasEscolhidas = {}
    for _, v in ipairs(cartasPraRevelar) do 
      table.insert(cartasEscolhidas, v) end
     for i = #cartasEscolhidas, 2, -1 do
            local j = math.random(i)
            cartasEscolhidas[i], cartasEscolhidas[j] = cartasEscolhidas[j], cartasEscolhidas[i]
        end
        cartasPraRevelar = {cartasEscolhidas[1], cartasEscolhidas[2], cartasEscolhidas[3], cartasEscolhidas[4]}
    end
    contReveladas = #cartasPraRevelar
  
  -- Revela as cartas temporariamente
    for _, card in ipairs(cartasPraRevelar) do
        card:alternarLado()
        love.timer.after(1, function()
          card:alternarLado()
          
      end)
    end