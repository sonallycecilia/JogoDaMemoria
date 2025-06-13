-- classes/modos/competitivo.lua
local Adversario = require("inteligencia_maquina.adversario")

local Competitivo = {}
Competitivo.__index = Competitivo

function Competitivo:new(partida)
    local self = setmetatable({}, Competitivo)
    
    self.partida = partida
    self.ia = Adversario:new()
    self.ia:inicializarMemoria(partida.tabuleiro.linhas, partida.tabuleiro.colunas)
    
    -- Sistema de turnos alternados
    self.jogadorAtual = "HUMANO"  -- "HUMANO" ou "IA"
    self.timerVezIA = 0
    self.intervaloPensamento = 1.5
    
    -- ✅ PROTEÇÃO: Flag para evitar múltiplas jogadas da IA
    self.iaEstaJogando = false
    
    -- Timer para cartas que não formaram grupo
    self.timerCartasViradas = 0
    self.tempoExibirCartas = 1.5
    
    -- Pontuação separada por jogador
    self.scoreHumano = 0
    self.scoreIA = 0
    self.gruposHumano = 0
    self.gruposIA = 0
    
    -- Sistema de streaks individuais
    self.streakHumano = 0
    self.streakIA = 0
    self.multiplicadorHumano = 1
    self.multiplicadorIA = 1
    
    -- Configurações baseadas no nível de dificuldade
    if partida.nivel == 1 then
        -- Fácil: pares, IA mais "burra" para dar chance ao humano
        self.cartasPorGrupo = 2
        self.tempoLimite = 240  -- 4 minutos
        self.modoVariavel = false
        self.chanceErroIA = 0.4  -- 40% chance da IA errar intencionalmente
        self.memoriaMaxIA = 4    -- IA lembra no máximo 4 posições
        self.chanceUsarMemoria = 0.40  -- 40% chance de usar memória
        self.intervaloPensamento = 2.5  -- IA pensa mais devagar
        print("Modo Competitivo - FÁCIL: IA relaxada, você tem boa chance!")
    elseif partida.nivel == 2 then
        -- Médio: trincas, IA um pouco mais competente
        self.cartasPorGrupo = 3
        self.tempoLimite = 300  -- 5 minutos
        self.modoVariavel = false
        self.chanceErroIA = 0.25  -- 25% chance da IA errar
        self.memoriaMaxIA = 8     -- IA lembra no máximo 8 posições
        self.chanceUsarMemoria = 0.60  -- 60% chance de usar memória
        self.intervaloPensamento = 2.0
        print("Modo Competitivo - MÉDIO: IA mais esperta, prepare-se!")
    elseif partida.nivel == 3 then
        -- Difícil: quadras, IA bem inteligente
        self.cartasPorGrupo = 4
        self.tempoLimite = 360  -- 6 minutos
        self.modoVariavel = false
        self.chanceErroIA = 0.10  -- 10% chance da IA errar
        self.memoriaMaxIA = 16    -- IA lembra no máximo 16 posições
        self.chanceUsarMemoria = 0.80  -- 80% chance de usar memória
        self.intervaloPensamento = 1.5
        print("Modo Competitivo - DIFÍCIL: IA muito competente!")
    else
        -- Extremo: combinações variáveis, IA expert com pouca margem de erro
        self.cartasPorGrupo = nil
        self.tempoLimite = 420  -- 7 minutos
        self.modoVariavel = true
        self.chanceErroIA = 0.05  -- 5% chance da IA errar
        self.memoriaMaxIA = 32    -- IA lembra muitas posições
        self.chanceUsarMemoria = 0.95  -- 95% chance de usar memória
        self.intervaloPensamento = 1.0  -- IA pensa muito rápido
        self.gruposDefinidos = self:definirGruposVariaveis()
        self:mostrarGruposObjetivo()
        print("Modo Competitivo - EXTREMO: IA especialista, boa sorte!")
    end
    
    -- Sistema de memória próprio da IA (limitado por nível)
    self.memoriaIA = {}
    self.contadorMemoriaIA = 0
    
    -- Atualiza o tempo da partida
    partida.tempoLimite = self.tempoLimite
    partida.tempoRestante = self.tempoLimite
    
    -- Garantir que todas as cartas iniciem viradas para baixo
    self:inicializarCartas()
    
    return self
end

function Competitivo:definirGruposVariaveis()
    -- Define quais cartas formam grupos de qual tamanho no modo extremo
    local grupos = {}
    
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

function Competitivo:mostrarGruposObjetivo()
    print("=== OBJETIVOS DO MODO EXTREMO ===")
    local nomeCartas = {"fada", "naly", "elfa", "draenei", "borboleta", "lua", "coracao", "espelho", "flor", "gato", "pocao", "planta"}
    
    for id, tamanho in pairs(self.gruposDefinidos) do
        local tipo = tamanho == 2 and "PAR" or (tamanho == 3 and "TRINCA" or "QUADRA")
        print("- " .. nomeCartas[id + 1] .. ": " .. tipo .. " (" .. tamanho .. " cartas)")
    end
    print("=================================")
end

function Competitivo:obterTamanhoGrupoEsperado(idCarta)
    if self.modoVariavel then
        return self.gruposDefinidos[idCarta] or 2
    else
        return self.cartasPorGrupo
    end
end

function Competitivo:inicializarCartas()
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

function Competitivo:update(dt)
    -- Atualiza timer das cartas viradas (que não formaram grupo)
    if #self.partida.cartasViradasNoTurno > 0 and self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            self:desvirarCartas()
        end
    end
    
    -- ✅ PROTEÇÃO: Controla a vez da IA com verificações extras
    if self.jogadorAtual == "IA" and #self.partida.cartasViradasNoTurno == 0 and not self.iaEstaJogando then
        self.timerVezIA = self.timerVezIA + dt
        if self.timerVezIA >= self.intervaloPensamento then
            print("[Sistema] 🤖 Ativando jogada da IA...")
            self:jogadaIA()
            self.timerVezIA = 0
        end
    elseif self.iaEstaJogando then
        print("[Sistema] ⏳ IA ainda está jogando, aguardando...")
    end
end

function Competitivo:cliqueCarta(carta)
    -- ✅ VERIFICAÇÃO INICIAL
    if not carta then
        print("ERRO: Carta é nil")
        return false
    end
    
    -- Debug: verificar estado da carta
    print("Clique na carta - ID:", carta.id, "Revelada:", carta.revelada, "Encontrada:", carta.encontrada)
    
    -- Verifica se há cartas sendo exibidas (não pode clicar durante exibição)
    if self.timerCartasViradas > 0 then
        print("Aguarde as cartas serem desviradas...")
        return false
    end
    
    -- Só permite clique se é vez do humano
    if self.jogadorAtual ~= "HUMANO" then
        print("Não é sua vez! Aguarde a IA jogar...")
        return false
    end
    
    if carta.encontrada then
        print("Carta já foi encontrada")
        return false
    end
    
    if carta.revelada then
        print("Carta já está revelada")
        return false
    end
    
    -- Determina limite de cartas baseado no modo/primeira carta
    local limiteCartas
    if self.modoVariavel then
        if #self.partida.cartasViradasNoTurno == 0 then
            limiteCartas = self:obterTamanhoGrupoEsperado(carta.id)
            self.grupoAtualEsperado = limiteCartas
            local tipoGrupo = (limiteCartas == 2 and "PAR" or (limiteCartas == 3 and "TRINCA" or "QUADRA"))
            print("[Extremo] Primeira carta ID " .. carta.id .. " - Objetivo: " .. tipoGrupo)
        else
            limiteCartas = self.grupoAtualEsperado or 2
        end
    else
        limiteCartas = self.cartasPorGrupo or 2
    end
    
    -- Verifica limite de cartas por turno
    if #self.partida.cartasViradasNoTurno >= limiteCartas then
        print("Já tem " .. limiteCartas .. " cartas viradas, aguarde...")
        return false
    end
    
    -- Revela a carta
    carta.revelada = true
    table.insert(self.partida.cartasViradasNoTurno, carta)
    
    -- IA observa a jogada do humano
    self:adicionarCartaMemoriaIA(carta)
    
    print("[HUMANO] Carta revelada! Total: " .. #self.partida.cartasViradasNoTurno .. "/" .. limiteCartas)
    
    -- Verifica se completou o grupo
    if #self.partida.cartasViradasNoTurno == limiteCartas then
        self:verificarGrupo("HUMANO")
    end
    
    return true
end

function Competitivo:verificarGrupo(jogador)
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
    
    -- No modo extremo, verifica tamanho correto
    if self.modoVariavel and grupoFormado then
        local tamanhoEsperado = self:obterTamanhoGrupoEsperado(primeiraCartaId)
        if #cartasViradas ~= tamanhoEsperado then
            print("[Sistema] ERRO: Carta ID " .. primeiraCartaId .. " precisa de " .. tamanhoEsperado .. " cartas")
            grupoFormado = false
        end
    end
    
    local tipoGrupo = #cartasViradas == 2 and "PAR" or (#cartasViradas == 3 and "TRINCA" or "QUADRA")
    
    if grupoFormado then
        print("[" .. jogador .. "] " .. tipoGrupo .. " ENCONTRADO!")
        self:processarGrupoEncontrado(cartasViradas, jogador)
        -- Jogador continua se acertou
        print("[Sistema] " .. jogador .. " continua jogando!")
    else
        print("[" .. jogador .. "] Errou! Não formou " .. tipoGrupo)
        self.timerCartasViradas = self.tempoExibirCartas
        self:resetarStreaks(jogador)
        -- Próximo jogador vai jogar após desvirar
    end
    
    -- Reset do modo extremo
    if self.modoVariavel then
        self.grupoAtualEsperado = nil
    end
end

function Competitivo:processarGrupoEncontrado(grupo, jogador)
    -- Marca cartas como encontradas
    for _, carta in ipairs(grupo) do
        carta.encontrada = true
        carta.revelada = true
    end
    
    -- Atualiza estatísticas do jogador específico
    if jogador == "HUMANO" then
        self.streakHumano = self.streakHumano + 1
        self.gruposHumano = self.gruposHumano + 1
        self.multiplicadorHumano = math.min(1 + (self.streakHumano - 1) * 0.3, 3) -- Max 3x
    else -- IA
        self.streakIA = self.streakIA + 1
        self.gruposIA = self.gruposIA + 1
        self.multiplicadorIA = math.min(1 + (self.streakIA - 1) * 0.3, 3) -- Max 3x
    end
    
    -- Calcula pontuação
    local pontosBase = #grupo * 50  -- Par=100, Trinca=150, Quadra=200
    local multiplicador = jogador == "HUMANO" and self.multiplicadorHumano or self.multiplicadorIA
    local bonusStreak = math.floor(pontosBase * (multiplicador - 1))
    local pontosTotal = pontosBase + bonusStreak
    
    -- Adiciona pontos ao jogador (usando o sistema do modo solo)
    if jogador == "HUMANO" then
        self.scoreHumano = self.scoreHumano + pontosTotal
        -- Também atualiza o score da partida para compatibilidade
        if self.partida.score then
            if type(self.partida.score) == "table" and self.partida.score.adicionarAoScore then
                self.partida.score:adicionarAoScore(pontosTotal)
            else
                self.partida.score = (self.partida.score or 0) + pontosTotal
            end
        end
    else
        self.scoreIA = self.scoreIA + pontosTotal
    end
    
    -- Remove cartas do tabuleiro
    self.partida.tabuleiro:removerGrupoEncontrado(grupo)
    self.partida.cartasViradasNoTurno = {}
    
    -- Feedback
    local tipoGrupo = #grupo == 2 and "Par" or (#grupo == 3 and "Trinca" or "Quadra")
    local streak = jogador == "HUMANO" and self.streakHumano or self.streakIA
    
    if streak > 1 then
        print("[" .. jogador .. "] " .. tipoGrupo .. " encontrado! Streak de " .. streak .. "! Multiplicador: " .. string.format("%.1f", multiplicador) .. "x (+" .. bonusStreak .. " bonus)")
    else
        print("[" .. jogador .. "] " .. tipoGrupo .. " encontrado! +" .. pontosBase .. " pontos")
    end
    
    self:mostrarPlacar()
end

function Competitivo:resetarStreaks(jogador)
    if jogador == "HUMANO" then
        self.streakHumano = 0
        self.multiplicadorHumano = 1
    else
        self.streakIA = 0
        self.multiplicadorIA = 1
    end
end

function Competitivo:desvirarCartas()
    for _, carta in ipairs(self.partida.cartasViradasNoTurno) do
        if not carta.encontrada then
            carta.revelada = false
        end
    end
    self.partida.cartasViradasNoTurno = {}
    
    -- Alterna jogador
    if self.jogadorAtual == "HUMANO" then
        self.jogadorAtual = "IA"
        print("Vez da IA")
    else
        self.jogadorAtual = "HUMANO"
        print("Sua vez!")
    end
end

function Competitivo:adicionarCartaMemoriaIA(carta)
    -- ✅ VERIFICAÇÃO DE SEGURANÇA ROBUSTA
    if not carta then
        print("[IA] ERRO: Carta é nil")
        return
    end
    
    if not carta.id then
        print("[IA] ERRO: Carta.id é nil")
        return
    end
    
    if type(carta.id) ~= "number" then
        print("[IA] ERRO: Carta.id não é número:", type(carta.id), carta.id)
        return
    end
    
    -- Sistema de memória limitado baseado no nível
    if not self.memoriaIA then
        self.memoriaIA = {}
    end
    
    if not self.contadorMemoriaIA then
        self.contadorMemoriaIA = 0
    end
    
    local chave = tostring(carta.id)  -- ✅ FORÇA CONVERSÃO PARA STRING
    
    -- ✅ VERIFICAÇÃO DUPLA: Garante que a chave existe antes de usar table.insert
    if not self.memoriaIA[chave] then
        self.memoriaIA[chave] = {}
    end
    
    -- ✅ VERIFICAÇÃO TRIPLA: Confirma que ainda é uma tabela
    if type(self.memoriaIA[chave]) ~= "table" then
        print("[IA] ERRO: memoriaIA[" .. chave .. "] não é tabela:", type(self.memoriaIA[chave]))
        self.memoriaIA[chave] = {}
    end
    
    -- Verifica limite de memória
    if self.contadorMemoriaIA >= self.memoriaMaxIA then
        -- Remove memória mais antiga
        self:removerMemoriaAntiga()
        
        -- ✅ RECONFIRMA após remover memória antiga
        if not self.memoriaIA[chave] then
            self.memoriaIA[chave] = {}
        end
    end
    
    -- ✅ VERIFICAÇÃO FINAL antes do table.insert
    if not self.memoriaIA[chave] or type(self.memoriaIA[chave]) ~= "table" then
        print("[IA] ERRO CRÍTICO: Não consegui garantir tabela válida para chave", chave)
        self.memoriaIA[chave] = {}
    end
    
    -- Agora tenta inserir com proteção adicional
    local novoItem = {
        carta = carta,
        posX = carta.x or 0,
        posY = carta.y or 0,
        tempoVista = love.timer.getTime()
    }
    
    -- ✅ INSERÇÃO PROTEGIDA
    local sucesso, erro = pcall(function()
        table.insert(self.memoriaIA[chave], novoItem)
    end)
    
    if not sucesso then
        print("[IA] ERRO ao inserir na memória:", erro)
        self.memoriaIA[chave] = {novoItem}  -- Força criação da lista
    end
    
    self.contadorMemoriaIA = self.contadorMemoriaIA + 1
    
    -- Remove duplicatas (com verificação de segurança)
    if self.memoriaIA[chave] and type(self.memoriaIA[chave]) == "table" then
        local novaLista = {}
        local cartasVistas = {}
        for _, item in ipairs(self.memoriaIA[chave]) do
            if item and item.carta and item.posX and item.posY then
                local chaveUnica = item.posX .. "_" .. item.posY
                if not cartasVistas[chaveUnica] and not item.carta.encontrada then
                    table.insert(novaLista, item)
                    cartasVistas[chaveUnica] = true
                end
            end
        end
        self.memoriaIA[chave] = novaLista
    end
    
    -- Também usa a memória original da IA (com verificação)
    if self.ia and self.ia.adicionarCartaMemoria then
        self.ia:adicionarCartaMemoria(carta)
    end
end

function Competitivo:removerMemoriaAntiga()
    -- Remove a memória mais antiga para manter o limite
    local maisAntiga = nil
    local tempoMaisAntigo = math.huge
    local chaveRemover = nil
    local indiceRemover = nil
    
    for id, lista in pairs(self.memoriaIA) do
        for i, item in ipairs(lista) do
            if item.tempoVista < tempoMaisAntigo then
                tempoMaisAntigo = item.tempoVista
                maisAntiga = item
                chaveRemover = id
                indiceRemover = i
            end
        end
    end
    
    if maisAntiga then
        table.remove(self.memoriaIA[chaveRemover], indiceRemover)
        if #self.memoriaIA[chaveRemover] == 0 then
            self.memoriaIA[chaveRemover] = nil
        end
        self.contadorMemoriaIA = self.contadorMemoriaIA - 1
    end
end

function Competitivo:buscarGrupoNaMemoria()
    if not self.memoriaIA then
        return {}
    end
    
    for id, listaCartas in pairs(self.memoriaIA) do
        local tamanhoNecessario = self.modoVariavel and self:obterTamanhoGrupoEsperado(id) or self.cartasPorGrupo
        
        if #listaCartas >= tamanhoNecessario then
            local cartasDisponiveis = {}
            for _, item in ipairs(listaCartas) do
                -- ✅ CORREÇÃO MELHORADA: Só verifica se não está encontrada e não revelada
                if not item.carta.encontrada and not item.carta.revelada then
                    table.insert(cartasDisponiveis, item.carta)
                end
            end
            
            if #cartasDisponiveis >= tamanhoNecessario then
                local grupo = {}
                for i = 1, tamanhoNecessario do
                    table.insert(grupo, cartasDisponiveis[i])
                end
                print("[IA] 🎯 GRUPO ENCONTRADO NA MEMÓRIA! ID:", id, "Cartas:", #grupo)
                return grupo
            end
        end
    end
    
    return {}
end

function Competitivo:selecionarCartaInteligente(ignorarCarta)
    local cartasDisponiveis = {}
    
    for _, carta in ipairs(self.partida.tabuleiro.cartas) do
        if not carta.encontrada and carta ~= ignorarCarta and not carta.revelada then
            table.insert(cartasDisponiveis, carta)
        end
    end
    
    if #cartasDisponiveis == 0 then
        print("[IA] ⚠️ NENHUMA CARTA DISPONÍVEL!")
        return nil
    end
    
    local cartaSelecionada = cartasDisponiveis[math.random(1, #cartasDisponiveis)]
    print("[IA] 🎲 Carta aleatória selecionada: ID", cartaSelecionada.id, "Pos:", cartaSelecionada.x, cartaSelecionada.y)
    return cartaSelecionada
end

function Competitivo:jogadaIA()
    print("[IA] === MINHA VEZ ===")
    
    -- ✅ PROTEÇÃO 1: Verifica se realmente é vez da IA
    if self.jogadorAtual ~= "IA" then
        print("[IA] ❌ ERRO: Não é minha vez! Jogador atual:", self.jogadorAtual)
        return
    end
    
    -- ✅ PROTEÇÃO 2: Verifica se pode jogar
    if #self.partida.cartasViradasNoTurno > 0 then
        print("[IA] ❌ ERRO: Ainda há " .. #self.partida.cartasViradasNoTurno .. " cartas viradas")
        return
    end
    
    -- ✅ PROTEÇÃO 3: Marca que IA está jogando para evitar múltiplas chamadas
    if self.iaEstaJogando then
        print("[IA] ❌ ERRO: Já estou jogando! Evitando chamada dupla")
        return
    end
    self.iaEstaJogando = true
    
    local cartas = {}
    
    -- Decide se vai usar memória ou errar intencionalmente
    local usarMemoria = math.random() > self.chanceErroIA and math.random() < self.chanceUsarMemoria
    
    if usarMemoria then
        cartas = self:buscarGrupoNaMemoria()
        if #cartas > 0 then
            print("[IA] 🧠 Usando memória para formar grupo ID " .. cartas[1].id)
        else
            print("[IA] 🤔 Memória não tem grupos completos")
        end
    else
        if math.random() <= self.chanceErroIA then
            print("[IA] 😵 Decidindo errar intencionalmente (nível " .. self.partida.nivel .. ")")
        else
            print("[IA] 🎲 Decidindo explorar ao invés de usar memória")
        end
    end
    
    -- Se não tem grupo na memória ou decidiu errar, joga aleatório
    if #cartas == 0 then
        print("[IA] 🎯 Jogando de forma exploratória...")
        
        local primeiraCarta = self:selecionarCartaInteligente()
        if not primeiraCarta then
            print("[IA] ERRO: Não encontrei cartas disponíveis")
            self.iaEstaJogando = false  -- ✅ LIBERA proteção
            return
        end
        
        local tamanhoGrupo = self.modoVariavel and self:obterTamanhoGrupoEsperado(primeiraCarta.id) or self.cartasPorGrupo
        table.insert(cartas, primeiraCarta)
        
        print("[IA] 📝 Primeira carta ID " .. primeiraCarta.id .. " - Preciso de " .. tamanhoGrupo .. " cartas")
        
        -- Completa o grupo
        for i = 2, tamanhoGrupo do
            local carta = self:selecionarCartaInteligente()
            if carta then
                table.insert(cartas, carta)
                print("[IA] 📝 Adicionei carta " .. i .. ": ID " .. carta.id)
            else
                print("[IA] ⚠️ Não consegui encontrar carta " .. i)
            end
        end
    end
    
    if #cartas == 0 then
        print("[IA] ERRO: Não consegui encontrar cartas suficientes")
        self.iaEstaJogando = false  -- ✅ LIBERA proteção
        return
    end
    
    -- ✅ PROTEÇÃO 4: Verifica se há cartas duplicadas na seleção
    local cartasUnicas = {}
    for _, carta in ipairs(cartas) do
        local chave = carta.x .. "_" .. carta.y
        if cartasUnicas[chave] then
            print("[IA] ❌ ERRO: Carta duplicada detectada! Posição:", carta.x, carta.y)
            self.iaEstaJogando = false
            return
        end
        cartasUnicas[chave] = true
    end
    
    -- Executa a jogada
    print("[IA] 🎮 Revelando " .. #cartas .. " cartas:")
    for i, carta in ipairs(cartas) do
        print("  Carta " .. i .. ": ID " .. carta.id .. " Pos:", carta.x, carta.y)
        
        -- ✅ PROTEÇÃO 5: Verifica se carta já estava revelada
        if carta.revelada then
            print("  ⚠️  ERRO CRÍTICO: Carta já estava revelada!")
            self.iaEstaJogando = false
            return
        end
        
        -- ✅ PROTEÇÃO 6: Verifica se carta já está no turno
        for _, cartaTurno in ipairs(self.partida.cartasViradasNoTurno) do
            if cartaTurno == carta then
                print("  ⚠️  ERRO CRÍTICO: Carta já está em cartasViradasNoTurno!")
                self.iaEstaJogando = false
                return
            end
        end
        
        carta.revelada = true
        self:adicionarCartaMemoriaIA(carta)
        table.insert(self.partida.cartasViradasNoTurno, carta)
    end
    
    -- ✅ PROTEÇÃO 7: Confirma quantas cartas foram realmente adicionadas
    print("[IA] ✅ Adicionei " .. #self.partida.cartasViradasNoTurno .. " cartas ao turno")
    
    -- Define grupo esperado no modo extremo
    if self.modoVariavel then
        self.grupoAtualEsperado = #cartas
    end
    
    -- Verifica se formou grupo
    self:verificarGrupo("IA")
    
    -- ✅ PROTEÇÃO 8: Libera flag no final
    self.iaEstaJogando = false
    print("[IA] === TERMINEI MINHA JOGADA ===")
end

function Competitivo:mostrarPlacar()
    print("=== PLACAR ===")
    print("VOCÊ: " .. self.scoreHumano .. " pontos (" .. self.gruposHumano .. " grupos)")
    print("IA:   " .. self.scoreIA .. " pontos (" .. self.gruposIA .. " grupos)")
    
    if self.scoreHumano > self.scoreIA then
        print("Você está GANHANDO!")
    elseif self.scoreIA > self.scoreHumano then
        print("IA está ganhando...")
    else
        print("EMPATE!")
    end
    print("==============")
end

function Competitivo:obterResultadoFinal()
    local vencedor = "EMPATE"
    if self.scoreHumano > self.scoreIA then
        vencedor = "HUMANO"
    elseif self.scoreIA > self.scoreHumano then
        vencedor = "IA"
    end
    
    return {
        vencedor = vencedor,
        scoreHumano = self.scoreHumano,
        scoreIA = self.scoreIA,
        gruposHumano = self.gruposHumano,
        gruposIA = self.gruposIA
    }
end

function Competitivo:getStatus()
    local modoTexto
    if self.partida.nivel == 1 then
        modoTexto = "Competitivo - Fácil"
    elseif self.partida.nivel == 2 then
        modoTexto = "Competitivo - Médio"
    elseif self.partida.nivel == 3 then
        modoTexto = "Competitivo - Difícil"
    else
        modoTexto = "Competitivo - Extremo"
    end
    
    return {
        modo = modoTexto,
        jogadorAtual = self.jogadorAtual,
        scoreHumano = self.scoreHumano,
        scoreIA = self.scoreIA,
        gruposHumano = self.gruposHumano,
        gruposIA = self.gruposIA,
        tempoRestante = math.ceil(self.partida.tempoRestante)
    }
end

return Competitivo