-- classes/modos/solo.lua

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
    self.tempoExibirCartas = 2.0
    
    -- CONFIGURAÇÕES BASEADAS NO NÍVEL
    if partida.nivel == 1 then
        -- Fácil: pares (2 cartas)
        self.cartasPorGrupo = 2
        self.tempoLimite = 300  -- 5 minutos (mais tempo que cooperativo)
        self.modoVariavel = false
        print("Modo Solo - FÁCIL: Encontre PARES (2 cartas iguais)")
    elseif partida.nivel == 2 then
        -- Médio: trincas (3 cartas)
        self.cartasPorGrupo = 3
        self.tempoLimite = 360  -- 6 minutos
        self.modoVariavel = false
        print("Modo Solo - MÉDIO: Encontre TRINCAS (3 cartas iguais)")
    elseif partida.nivel == 3 then
        -- Difícil: quadras (4 cartas)
        self.cartasPorGrupo = 4
        self.tempoLimite = 420  -- 7 minutos
        self.modoVariavel = false
        print("Modo Solo - DIFÍCIL: Encontre QUADRAS (4 cartas iguais)")
    else
        -- Extremo: combinações variáveis
        self.cartasPorGrupo = nil  -- Será dinâmico
        self.tempoLimite = 480  -- 8 minutos
        self.modoVariavel = true
        self.gruposDefinidos = self:definirGruposVariaveis()
        print("Modo Solo - EXTREMO: Combinações variáveis!")
        self:mostrarGruposObjetivo()
    end
    
    -- Atualiza o tempo da partida
    partida.tempoLimite = self.tempoLimite
    partida.tempoRestante = self.tempoLimite
    
    -- Garantir que todas as cartas iniciem viradas para baixo
    self:inicializarCartas()
    
    print("Você tem " .. math.floor(self.tempoLimite/60) .. " minutos para encontrar todos os grupos!")
    
    return self
end

function Solo:definirGruposVariaveis()
    -- Define quais cartas formam grupos de qual tamanho no modo extremo
    local grupos = {}
    
    -- Mesma configuração do modo cooperativo
    -- 3 pares (6 cartas)
    grupos[0] = 2  -- fada: par
    grupos[1] = 2  -- naly: par  
    grupos[2] = 2  -- elfa: par
    
    -- 3 trincas (9 cartas)
    grupos[3] = 3  -- draenei: trinca
    grupos[4] = 3  -- borboleta: trinca
    grupos[5] = 3  -- lua: trinca
    
    -- 2 quadras (8 cartas)
    grupos[6] = 4  -- coracao: quadra
    grupos[7] = 4  -- espelho: quadra
    
    -- Restantes são pares para completar
    grupos[8] = 2  -- flor: par
    grupos[9] = 2  -- gato: par
    grupos[10] = 2 -- pocao: par
    grupos[11] = 2 -- planta: par
    
    return grupos
end

function Solo:mostrarGruposObjetivo()
    print("=== OBJETIVOS DO MODO EXTREMO ===")
    local nomeCartas = {"fada", "naly", "elfa", "draenei", "borboleta", "lua", "coracao", "espelho", "flor", "gato", "pocao", "planta"}
    
    for id, tamanho in pairs(self.gruposDefinidos) do
        local tipo = tamanho == 2 and "PAR" or (tamanho == 3 and "TRINCA" or "QUADRA")
        print("- " .. nomeCartas[id + 1] .. ": " .. tipo .. " (" .. tamanho .. " cartas)")
    end
    print("=================================")
end

function Solo:obterTamanhoGrupoEsperado(idCarta)
    if self.modoVariavel then
        return self.gruposDefinidos[idCarta] or 2  -- Default para par se não definido
    else
        return self.cartasPorGrupo
    end
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
    
    if carta.encontrada then
        print("Carta já foi encontrada")
        return false
    end
    
    if carta.revelada then
        print("Carta já está revelada")
        return false
    end
    
    -- No modo extremo, o limite é dinâmico baseado na primeira carta
    local limiteCartas
    if self.modoVariavel then
        if #self.partida.cartasViradasNoTurno == 0 then
            -- Primeira carta define o tipo de grupo esperado
            limiteCartas = self:obterTamanhoGrupoEsperado(carta.id)
            self.grupoAtualEsperado = limiteCartas
            local tipoGrupo = (limiteCartas == 2 and "PAR" or (limiteCartas == 3 and "TRINCA" or "QUADRA"))
            print("[Extremo] Primeira carta ID " .. carta.id .. " - Objetivo: " .. tipoGrupo)
        else
            limiteCartas = self.grupoAtualEsperado or 2  -- Default se não definido
        end
    else
        limiteCartas = self.cartasPorGrupo or 2  -- Default se não definido
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
    local primeiraCartaId = cartasViradas[1].id
    local grupoFormado = true
    
    -- Verifica se todas as cartas têm o mesmo ID
    for i = 2, #cartasViradas do
        if cartasViradas[i].id ~= primeiraCartaId then
            grupoFormado = false
            break
        end
    end
    
    -- No modo extremo, verifica se o tamanho está correto
    if self.modoVariavel and grupoFormado then
        local tamanhoEsperado = self:obterTamanhoGrupoEsperado(primeiraCartaId)
        if #cartasViradas ~= tamanhoEsperado then
            print("[Sistema] ERRO: Carta ID " .. primeiraCartaId .. " precisa de " .. tamanhoEsperado .. " cartas, mas você revelou " .. #cartasViradas)
            grupoFormado = false
        end
    end
    
    local tipoGrupo
    if #cartasViradas == 2 then
        tipoGrupo = "PAR"
    elseif #cartasViradas == 3 then
        tipoGrupo = "TRINCA"
    elseif #cartasViradas == 4 then
        tipoGrupo = "QUADRA"
    else
        tipoGrupo = "GRUPO"
    end
    
    print("[Sistema] Verificando " .. tipoGrupo .. " - ID:", primeiraCartaId, "Total cartas:", #cartasViradas)
    
    if grupoFormado then
        -- Grupo encontrado!
        print("[Sistema] " .. tipoGrupo .. " ENCONTRADO!")
        self:processarGrupoEncontrado(cartasViradas)
        -- Reset para próximo grupo no modo extremo
        if self.modoVariavel then
            self.grupoAtualEsperado = nil
        end
    else
        -- Não formou grupo - mostra cartas e depois desvira
        print("[Sistema] Não formou " .. tipoGrupo .. ", mostrando cartas por", self.tempoExibirCartas, "segundos")
        self.timerCartasViradas = self.tempoExibirCartas
        self.ultimoAcerto = false
        self.gruposConsecutivos = 0
        self.multiplicadorSequencia = 1
        
        -- Reset para próximo grupo no modo extremo
        if self.modoVariavel then
            self.grupoAtualEsperado = nil
        end
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
        self.multiplicadorSequencia = math.min(self.multiplicadorSequencia + 0.5, 5) -- Max 5x
    else
        self.gruposConsecutivos = 1
        self.multiplicadorSequencia = 1
    end
    
    -- Calcula pontuação com bonificação por sequência (mais pontos por mais cartas)
    local pontosGrupo = #grupo * 50  -- Par=100, Trinca=150, Quadra=200
    local bonusSequencia = math.floor(pontosGrupo * (self.multiplicadorSequencia - 1))
    local pontosTotal = pontosGrupo + bonusSequencia
    
    self.partida.score = self.partida.score + pontosTotal
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