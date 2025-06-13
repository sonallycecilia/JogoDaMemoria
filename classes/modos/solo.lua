-- classes/modos/solo.lua
require("classes.niveldeJogoEnum")

local Solo = {}
Solo.__index = Solo

function Solo:new(partida)
    local self = setmetatable({}, Solo)
    self.partida = partida
    -- Configurações específicas do modo solo
    self.multiplicadorSequencia = 1
    self.gruposConsecutivos = 0
    self.ultimoAcerto = false
    -- Timer para cartas que não formaram par/trinca
    self.timerCartasViradas = 0
    self.tempoExibirCartas = 1
    -- CONFIGURAÇÕES BASEADAS NO NÍVEL
    if self.partida.nivel == FACIL then
        -- Fácil: pares (2 cartas)
        self.tempoLimite = 300  -- 5 minutos (mais tempo que cooperativo)
        self.modoVariavel = false
        print("Modo Solo - FÁCIL: Encontre PARES (2 cartas iguais)")
    end
    if self.partida.nivel == MEDIO then
        -- Médio: trincas (3 cartas)
        self.tempoLimite = 360  -- 6 minutos
        self.modoVariavel = false
        print("Modo Solo - MÉDIO: Encontre TRINCAS (3 cartas iguais)")
    end
    if self.partida.nivel == DIFICIL then
        -- Difícil: quadras (4 cartas)
        self.tempoLimite = 420  -- 7 minutos
        self.modoVariavel = false
        print("Modo Solo - DIFÍCIL: Encontre QUADRAS (4 cartas iguais)")
    end
    if self.partida.nivel == EXTREMO then
        -- Extremo: combinações variáveis
        self.tempoLimite = 480  -- 8 minutos
        self.modoVariavel = true
        self.tamGrupoAtualEsperado = 0 -- tam do grupo da primeira carta que for virada
        print("Modo Solo - EXTREMO: Combinações variáveis!")
        self:mostrarGruposObjetivo()
    end
    -- Atualiza o tempo da partida
    self.partida.tempoLimite = self.tempoLimite
    self.partida.tempoRestante = self.tempoLimite
    -- Garantir que todas as cartas iniciem viradas para baixo
    self:inicializarCartas()
    print("Você tem " .. math.floor(self.tempoLimite/60) .. " minutos para encontrar todos os grupos!")
    return self
end

function Solo:mostrarGruposObjetivo()
    print("=== OBJETIVOS DO MODO EXTREMO ===")
    local nomeCartas = {"fada", "naly", "elfa", "draenei", "borboleta", "lua", "coracao", "espelho", "flor", "gato", "pocao", "planta"}
    local numCopias

    for indice, carta in pairs(self.partida.tabuleiro.tiposCartas) do
        numCopias = carta.numCopias
        local tipo = (carta.numCopias == 2 and "PAR") or (carta == 3 and "TRINCA") or (carta.numCopias == 4 and "QUADRA")
        print("-", nomeCartas[indice], ":", tipo, "(", numCopias, "cartas)")
    end
    print("=================================")
end

function Solo:inicializarCartas()
    -- Garante que todas as cartas iniciem no estado correto
    for _, carta in ipairs(self.partida.tabuleiro.cartas) do
        carta.revelada = false
        carta.encontrada = false
    end
    
    -- DEBUG: Mostra quantas cartas de cada ID existem
    print("[DEBUG] === ANÁLISE DO TABULEIRO ===")
    local contadorIDs = {}
    for _, carta in ipairs(self.partida.tabuleiro.cartas) do
        contadorIDs[carta.id] = (contadorIDs[carta.id] or 0) + 1
    end
    
    for id, quantidade in pairs(contadorIDs) do
        print("[DEBUG] ID " .. id .. ": " .. quantidade .. " cartas")
    end
    print("[DEBUG] Total de cartas: " .. #self.partida.tabuleiro.cartas)
    print("[DEBUG] ================================")
end

-- Conexao com o Love deveria ser feito pelo Layer
function Solo:update(dt)
    -- Atualiza timer das cartas viradas (que não formaram grupo)
    if #self.partida.cartasViradasNoTurno > 0 and self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            self:desvirarCartas()
            print("[Sistema] Cartas desviradas, continue jogando")
        end
    end
end

function Solo:cliqueCarta(carta)
    -- Debug: verificar estado da carta
    print("Clique na carta - ID:", carta.id, "Revelada:", carta.revelada, "Encontrada:", carta.encontrada)
    
    
    if carta.revelada then
        print("Carta já está revelada")
        return false
    end
    if carta.encontrada then
        print("Carta já foi encontrada")
        return false
    end
    
    
    -- No modo extremo, o limite é dinâmico baseado na primeira carta
    local limiteCartas
    if self.modoVariavel then
        if #self.partida.cartasViradasNoTurno == 0 then
            -- Primeira carta define o tipo de grupo esperado
            limiteCartas = carta.numCopias
            self.tamGrupoAtualEsperado = limiteCartas
            local tipoGrupo = (limiteCartas == 2 and "PAR" or (limiteCartas == 3 and "TRINCA") or (limiteCartas == 4 and "QUADRA"))
            print("[Extremo] Primeira carta ID " .. carta.id .. " - Objetivo: " .. tipoGrupo)
        else
            limiteCartas = self.tamGrupoAtualEsperado or 2  -- Default se não definido
        end
    end
    if not self.modoVariavel then
        limiteCartas = carta.numCopias or 2  -- Default se não definido
    end
    
    -- Não permite mais cartas que o necessário por turno
    if #self.partida.cartasViradasNoTurno >= limiteCartas then
        print("Já tem " .. limiteCartas .. " cartas viradas, aguarde...")
        return false
    end
    
    -- Revela a carta
    carta.revelada = true
    table.insert(self.partida.cartasViradasNoTurno, carta)
    
    print("Carta revelada! Total de cartas viradas:", #self.partida.cartasViradasNoTurno .. "/" .. limiteCartas)
    
    -- Se virou todas as cartas necessárias, verifica se formam grupo
    if #self.partida.cartasViradasNoTurno == limiteCartas then
        self:verificarGrupo()
    end
    
    return true
end

function Solo:verificarGrupo()
    local cartasViradas = self.partida.cartasViradasNoTurno
    local primeiraCarta = cartasViradas[1]
    local grupoFormado = true
    
    -- Verifica se todas as cartas têm o mesmo ID
    for i = 2, #cartasViradas do
        if cartasViradas[i].id ~= primeiraCarta.id then
            grupoFormado = false
            break
        end
    end
    
    -- No modo extremo, verifica se o tamanho está correto
    if self.modoVariavel and grupoFormado then
        local tamanhoEsperado = primeiraCarta.numCopias
        if #cartasViradas ~= tamanhoEsperado then
            print("[Sistema] ERRO: Carta ID " .. primeiraCarta.id .. " precisa de " .. tamanhoEsperado .. " cartas, mas você revelou " .. #cartasViradas)
            grupoFormado = false
        end
    end
    
    local tipoGrupo
    if #cartasViradas == 2 then
        tipoGrupo = "PAR"
    end
    if #cartasViradas == 3 then
        tipoGrupo = "TRINCA"
    end
    if #cartasViradas == 4 then
        tipoGrupo = "QUADRA"
    end
    if #cartasViradas > 4 or #cartasViradas < 2 then
        tipoGrupo = "GRUPO" -- Se entrou aqui algo deu errado
    end
    
    print("[Sistema] Verificando " .. tipoGrupo .. " - ID:", primeiraCarta, "Total cartas:", #cartasViradas)
    
    if grupoFormado then
        -- Grupo encontrado!
        print("[Sistema] " .. tipoGrupo .. " ENCONTRADO!")
        self:processarGrupoEncontrado(cartasViradas)
        -- Reset para próximo grupo no modo extremo
    end
    if not grupoFormado then
        -- Não formou grupo - mostra cartas e depois desvira
        print("[Sistema] Não formou " .. tipoGrupo .. ", mostrando cartas por", self.tempoExibirCartas, "segundos")
        self.timerCartasViradas = self.tempoExibirCartas
        self.ultimoAcerto = false
        self.gruposConsecutivos = 0
        self.multiplicadorSequencia = 1
    end

    -- Reset para próximo grupo no modo extremo
    if self.modoVariavel then
        self.tamGrupoAtualEsperado = nil
    end

end

function Solo:processarGrupoEncontrado(grupo)
    -- Marca as cartas como encontradas
    for _, carta in ipairs(grupo) do
        carta.encontrada = true
        carta.revelada = true
    end
    
    -- Atualiza estatísticas de sequência
    if self.ultimoAcerto then
        self.gruposConsecutivos = self.gruposConsecutivos + 1
        -- REMOVER LIMITAÇÃO DE MULTIPLICADOR DE 5X
        self.multiplicadorSequencia = math.min(self.multiplicadorSequencia + 0.5, 5) -- Max 5x
    end
    if not self.ultimoAcerto then
        self.gruposConsecutivos = 1
        self.multiplicadorSequencia = 1
    end
    
    -- Calcula pontuação com bonificação por sequência (mais pontos por mais cartas)
    local pontosGrupo = #grupo * 50  -- Par=100, Trinca=150, Quadra=200
    local bonusSequencia = math.floor(pontosGrupo * (self.multiplicadorSequencia - 1))
    local pontosTotal = pontosGrupo + bonusSequencia
    
    self.partida.score:adicionarAoScore(pontosTotal)
    self.ultimoAcerto = true
    
    -- Remove as cartas do tabuleiro
    self.partida.tabuleiro:removerGrupoEncontrado(grupo)
    self.partida.cartasViradasNoTurno = {}
    
    -- Feedback para o jogador
    local tipoGrupo
    if #grupo == 2 then
        tipoGrupo = "Par"
    elseif #grupo == 3 then
        tipoGrupo = "Trinca"
    elseif #grupo == 4 then
        tipoGrupo = "Quadra"
    else
        tipoGrupo = "Grupo"
    end
    
    if self.gruposConsecutivos > 1 then
        print("Excelente! " .. self.gruposConsecutivos .. " grupos consecutivos! Multiplicador: " .. string.format("%.1f", self.multiplicadorSequencia) .. "x (+" .. bonusSequencia .. " pontos bonus)")
    else
        print(tipoGrupo .. " encontrado! +" .. pontosGrupo .. " pontos")
    end
end

function Solo:desvirarCartas()
    for _, carta in ipairs(self.partida.cartasViradasNoTurno) do
        if not carta.encontrada then
            carta.revelada = false
        end
    end
    self.partida.cartasViradasNoTurno = {}
    print("[Sistema] Continue jogando...")
end

-- ✅ NOVA FUNÇÃO: Interface visual para modo solo
function Solo:drawInterface()
    if not self.partida then return end
    
    local largura = love.graphics.getWidth()
    local info = self:getStatus()
    
    -- Painel de informações no canto superior direito
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", largura - 250, 10, 240, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    
    local x, y = largura - 240, 20
    
    -- Título
    love.graphics.setColor(0.2, 0.8, 1) -- Azul para solo
    love.graphics.print("MODO SOLO", x, y)
    love.graphics.setColor(1, 1, 1)
    y = y + 25
    
    -- Tempo
    love.graphics.print("Tempo: " .. math.floor(info.tempoRestante / 60) .. ":" .. string.format("%02d", info.tempoRestante % 60), x, y)
    y = y + 20
    
    -- Pontuação
    local pontuacao = self.partida.score and self.partida.score.pontuacao or 0
    love.graphics.print("Pontos: " .. pontuacao, x, y)
    y = y + 20
    
    -- Informações específicas do solo
    if info.multiplicador and info.multiplicador > 1 then
        love.graphics.setColor(0.2, 1, 0.2) -- Verde
        love.graphics.print("Mult: " .. string.format("%.1f", info.multiplicador) .. "x", x, y)
        love.graphics.setColor(1, 1, 1)
        y = y + 20
    end
    
    if info.gruposConsecutivos and info.gruposConsecutivos > 1 then
        love.graphics.setColor(1, 1, 0.2) -- Amarelo
        love.graphics.print("Sequência: " .. tostring(info.gruposConsecutivos), x, y)
        love.graphics.setColor(1, 1, 1)
        y = y + 20
    end
    
    -- Alerta de tempo baixo
    if info.tempoRestante <= 30 and info.tempoRestante > 0 then
        love.graphics.setColor(1, 0.2, 0.2) -- Vermelho
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.print("TEMPO BAIXO!", largura/2 - 60, 50)
        love.graphics.setColor(1, 1, 1)
    end
end

function Solo:getStatus()
    local modoTexto
    if self.partida.nivel == 1 then
        modoTexto = "Solo - Fácil"
    elseif self.partida.nivel == 2 then
        modoTexto = "Solo - Médio"
    elseif self.partida.nivel == 3 then
        modoTexto = "Solo - Difícil"
    else
        modoTexto = "Solo - Extremo"
    end
    
    return {
        modo = modoTexto,
        multiplicador = self.multiplicadorSequencia,
        gruposConsecutivos = self.gruposConsecutivos,
        tempoRestante = math.ceil(self.partida.tempoRestante)
    }
end

return Solo