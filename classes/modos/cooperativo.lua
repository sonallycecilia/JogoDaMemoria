-- classes/modos/cooperativo.lua
local Adversario = require("inteligencia_maquina.adversario")

local Cooperativo = {}
Cooperativo.__index = Cooperativo

function Cooperativo:new(partida)
    local self = setmetatable({}, Cooperativo)
    
    self.partida = partida
    self.ia = Adversario:new()
    self.ia:inicializarMemoria(partida.tabuleiro.linhas, partida.tabuleiro.colunas)
    
    -- Configurações específicas do modo cooperativo e deveriam ser do competitivo também
    self.multiplicadorSequencia = 1
    self.paresConsecutivos = 0
    self.ultimoAcerto = false
    self.timerVezIA = 0
    self.intervaloPensamento = 1 -- Tá muito alto
    self.vezIA = false
    
    -- Timer para cartas que não formaram grupos
    self.timerCartasViradas = 0
    self.tempoExibirCartas = 1
    
    -- Controla quem fez a última jogada
    self.ultimaJogadaFoiIA = false
    
    -- Flag para controlar se IA deve jogar após desvirar
    self.iaDeveJogarAposDesvirar = false
    
    -- Flag para evitar múltiplas jogadas da IA
    self.iaEstaJogando = false
    
    -- Sistema de memória próprio da IA (mais confiável)
    self.memoriaIA = {}
    
    -- NOVO: Configurações baseadas no nível
    if partida.nivel == 1 then
        -- Fácil: pares (2 cartas)
        self.cartasPorGrupo = 2
        self.tempoLimite = 180  -- 3 minutos
        self.modoVariavel = false
        print("Modo Cooperativo - FACIL: Encontrem PARES (2 cartas iguais)")
    elseif partida.nivel == 2 then
        -- Médio: trincas (3 cartas)
        self.cartasPorGrupo = 3
        self.tempoLimite = 210  -- 3.5 minutos (3min e 30seg)
        self.modoVariavel = false
        print("Modo Cooperativo - MEDIO: Encontrem TRINCAS (3 cartas iguais)")
    elseif partida.nivel == 3 then
        -- Difícil: quadras (4 cartas)
        self.cartasPorGrupo = 4
        self.tempoLimite = 270  -- 4.5 minutos (4min e 30seg)
        self.modoVariavel = false
        print("Modo Cooperativo - DIFICIL: Encontrem QUADRAS (4 cartas iguais)")
    else
        -- Extremo: combinações variáveis
        self.cartasPorGrupo = nil  -- Será dinâmico
        self.tempoLimite = 360  -- 6 minutos
        self.modoVariavel = true
        self.gruposDefinidos = self:definirGruposVariaveis()
        print("Modo Cooperativo - EXTREMO: Combinações variaveis!")
        self:mostrarGruposObjetivo()
    end
    
    -- IA sempre inteligente no modo cooperativo 
    self.chanceUsarMemoria = 0.90
    
    -- Atualiza o tempo da partida
    partida.tempoLimite = self.tempoLimite
    partida.tempoRestante = self.tempoLimite
    
    -- Garantir que todas as cartas iniciem viradas para baixo
    self:inicializarCartas()
    
    print("Trabalhem juntos para encontrar todos os grupos em " .. math.floor(self.tempoLimite/60) .. " minutos!")
    
    return self
end

function Cooperativo:definirGruposVariaveis()
    -- Define quais cartas formam grupos de qual tamanho no modo extremo
    local grupos = {}
    
    -- 12 cartas diferentes: mistura de pares, trincas e quadras
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
    
    -- Total: 6+9+8+8 = 31 cartas (precisa ajustar tabuleiro)
    
    return grupos
end

function Cooperativo:mostrarGruposObjetivo()
    print("=== OBJETIVOS DO MODO EXTREMO ===")
    local nomeCartas = {"fada", "naly", "elfa", "draenei", "borboleta", "lua", "coracao", "espelho", "flor", "gato", "pocao", "planta"}
    
    for id, tamanho in pairs(self.gruposDefinidos) do
        local tipo = tamanho == 2 and "PAR" or (tamanho == 3 and "TRINCA" or "QUADRA")
        print("- " .. nomeCartas[id + 1] .. ": " .. tipo .. " (" .. tamanho .. " cartas)")
    end
    print("=================================")
end

function Cooperativo:obterTamanhoGrupoEsperado(idCarta)
    if self.modoVariavel then
        return self.gruposDefinidos[idCarta] or 2  -- Default para par se não definido
    else
        return self.cartasPorGrupo
    end
end

function Cooperativo:inicializarCartas()
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

function Cooperativo:update(dt)
    -- Atualiza timer das cartas viradas (que não formaram par)
    if #self.partida.cartasViradasNoTurno > 0 and self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            self:desvirarCartas()
            print("[Sistema] Cartas desviradas, volta para HUMANO")
        end
    end
    
    -- Controla a vez da IA com verificações extras
    if self.vezIA and #self.partida.cartasViradasNoTurno == 0 and not self.iaEstaJogando then
        self.timerVezIA = self.timerVezIA + dt
        if self.timerVezIA >= self.intervaloPensamento then
            print("[Sistema] Ativando jogada da IA cooperativa...")
            self:jogadaIA()
            self.timerVezIA = 0
            -- SEMPRE desativa IA após jogar, independente do resultado
            self.vezIA = false
            print("[Sistema] IA jogou, SEMPRE volta para humano")
        end
    elseif self.iaEstaJogando then
        print("[Sistema] IA ainda está jogando, aguardando...")
    end
end

function Cooperativo:cliqueCarta(carta)
    -- Debug: verificar estado da carta
    print("Clique na carta - ID:", carta.id, "Revelada:", carta.revelada, "Encontrada:", carta.encontrada)
    
    -- Só permite clique se não é vez da IA e a carta não foi encontrada
    if self.vezIA then
        print("É vez da IA, aguarde...")
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
    
    -- MARCA: Esta jogada é do HUMANO
    self.ultimaJogadaFoiIA = false
    
    -- Revela a carta SEMPRE
    carta.revelada = true
    table.insert(self.partida.cartasViradasNoTurno, carta)
    
    -- IA memoriza as cartas do humano também
    self:adicionarCartaMemoriaIA(carta)
    print("[IA] Memorizei a carta do humano:", carta.id)
    
    print("Carta revelada! Total de cartas viradas:", #self.partida.cartasViradasNoTurno .. "/" .. limiteCartas)
    
    -- Se virou todas as cartas necessárias, verifica se formam grupo
    if #self.partida.cartasViradasNoTurno == limiteCartas then
        self:verificarGrupo()
    end
    
    return true
end

function Cooperativo:verificarGrupo()
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
        -- Não formou grupo - mostra cartas e depois ativa IA APENAS se foi o humano que errou
        print("[Sistema] Não formou " .. tipoGrupo .. ", mostrando cartas por", self.tempoExibirCartas, "segundos")
        self.timerCartasViradas = self.tempoExibirCartas
        self.ultimoAcerto = false
        self.paresConsecutivos = 0
        self.multiplicadorSequencia = 1
        
        -- Reset para próximo grupo no modo extremo
        if self.modoVariavel then
            self.grupoAtualEsperado = nil
        end
        
        -- Só ativa IA se foi o HUMANO que errou
        if not self.ultimaJogadaFoiIA then
            print("[Sistema] Humano errou - IA sera ativada apos desvirar")
            self.iaDeveJogarAposDesvirar = true
        else
            print("[Sistema] IA errou - volta para humano")
            self.iaDeveJogarAposDesvirar = false
        end
    end
end

function Cooperativo:processarGrupoEncontrado(grupo)
    -- Marca as cartas como encontradas
    for _, carta in ipairs(grupo) do
        carta.encontrada = true
        carta.revelada = true
    end
    
    -- Atualiza estatísticas de sequência
    if self.ultimoAcerto then
        self.paresConsecutivos = self.paresConsecutivos + 1
        self.multiplicadorSequencia = math.min(self.multiplicadorSequencia + 0.5, 5) -- Max 5x
    else
        self.paresConsecutivos = 1
        self.multiplicadorSequencia = 1
    end
    
    -- Calcula pontuação com bonificação por sequência (mais pontos por mais cartas)
    local pontosGrupo = #grupo * 50  -- Par=100, Trinca=150, Quadra=200, Quintupla=250
    local bonusSequencia = math.floor(pontosGrupo * (self.multiplicadorSequencia - 1))
    local pontosTotal = pontosGrupo + bonusSequencia
    
    self.partida.score:adicionarPontuacao(pontosTotal)
    self.ultimoAcerto = true
    
    -- Remove as cartas do tabuleiro
    self.partida.tabuleiro:removerGrupoEncontrado(grupo)
    self.partida.cartasViradasNoTurno = {}
    
    -- Feedback para os jogadores
    local tipoGrupo
    if #grupo == 2 then
        tipoGrupo = "Par"
    elseif #grupo == 3 then
        tipoGrupo = "Trinca"
    elseif #grupo == 4 then
        tipoGrupo = "Quadra"
    else
        tipoGrupo = "Quintupla"
    end
    
    if self.paresConsecutivos > 1 then
        print("Excelente! " .. self.paresConsecutivos .. " grupos consecutivos! Multiplicador: " .. string.format("%.1f", self.multiplicadorSequencia) .. "x (+" .. bonusSequencia .. " pontos bonus)")
    else
        print(tipoGrupo .. " encontrado! +" .. pontosGrupo .. " pontos")
    end
    
    -- IMPORTANTE: SEMPRE volta para o humano após encontrar grupo (seja humano ou IA)
    self.vezIA = false
    self.timerVezIA = 0
    print("[Sistema] Grupo encontrado, SEMPRE volta para o humano")
end

function Cooperativo:desvirarCartas()
    for _, carta in ipairs(self.partida.cartasViradasNoTurno) do
        if not carta.encontrada then
            carta.revelada = false
        end
    end
    self.partida.cartasViradasNoTurno = {}
    
    -- Só ativa IA se foi marcado para jogar
    if self.iaDeveJogarAposDesvirar then
        self.vezIA = true
        self.timerVezIA = 0
        self.iaDeveJogarAposDesvirar = false
        print("[Sistema] Ativando IA após desvirar")
    else
        print("[Sistema] Não ativando IA - volta para humano")
    end
end

function Cooperativo:selecionarCartaInteligente(ignorarCarta)
    -- Seleciona cartas não encontradas, priorizando cantos e bordas
    local cartasDisponiveis = {}
    
    for _, carta in ipairs(self.partida.tabuleiro.cartas) do
        if not carta.encontrada and carta ~= ignorarCarta and not carta.revelada then
            table.insert(cartasDisponiveis, carta)
        end
    end
    
    if #cartasDisponiveis == 0 then
        print("[IA] NENHUMA CARTA DISPONÍVEL!")
        return nil
    end
    
    local cartaSelecionada = cartasDisponiveis[math.random(1, #cartasDisponiveis)]
    print("[IA] Carta aleatória selecionada: ID", cartaSelecionada.id)
    return cartaSelecionada
end

function Cooperativo:adicionarCartaMemoriaIA(carta)
    -- Verifica se a memória foi inicializada
    if not self.memoriaIA then
        self.memoriaIA = {}
    end
    
    -- Sistema de memória próprio (mais confiável)
    local chave = carta.id
    
    if not self.memoriaIA[chave] then
        self.memoriaIA[chave] = {}
    end
    
    -- Adiciona a carta à lista desse ID
    table.insert(self.memoriaIA[chave], {
        carta = carta,
        posX = carta.x,
        posY = carta.y,
        tempoVista = love.timer.getTime(),
        reveladaPor = self.ultimaJogadaFoiIA and "IA" or "Humano"
    })
    
    -- Remove duplicatas (se a mesma carta for vista várias vezes)
    local novaLista = {}
    local cartasVistas = {}
    for _, item in ipairs(self.memoriaIA[chave]) do
        local chaveUnica = item.posX .. "_" .. item.posY
        if not cartasVistas[chaveUnica] and not item.carta.encontrada then
            table.insert(novaLista, item)
            cartasVistas[chaveUnica] = true
        end
    end
    self.memoriaIA[chave] = novaLista
    
    print("[IA] Memorizei carta ID " .. carta.id .. " (Total dessa carta na memória: " .. #self.memoriaIA[chave] .. ")")
    
    -- Verifica se agora tem um par
    if #self.memoriaIA[chave] >= 2 then
        print("[IA] IMPORTANTE: Agora sei onde estão " .. #self.memoriaIA[chave] .. " cartas ID " .. carta.id .. "!")
    end
    
    -- Também adiciona à memória original da IA
    self.ia:adicionarCartaMemoria(carta)
end

function Cooperativo:buscarGrupoNaMemoria()
    -- Verifica se a memória foi inicializada
    if not self.memoriaIA then
        self.memoriaIA = {}
        return {}
    end
    
    -- Busca na memória própria por grupos disponíveis
    for id, listaCartas in pairs(self.memoriaIA) do
        local tamanhoNecessario = self.modoVariavel and self:obterTamanhoGrupoEsperado(id) or self.cartasPorGrupo
        
        if #listaCartas >= tamanhoNecessario then
            -- Encontra cartas disponíveis deste ID
            local cartasDisponiveis = {}
            for _, item in ipairs(listaCartas) do
                -- Só verifica se não está encontrada e não revelada
                if not item.carta.encontrada and not item.carta.revelada then
                    table.insert(cartasDisponiveis, item.carta)
                end
            end
            
            if #cartasDisponiveis >= tamanhoNecessario then
                local tipoGrupo = tamanhoNecessario == 2 and "PAR" or (tamanhoNecessario == 3 and "TRINCA" or "QUADRA")
                print("[IA] GRUPO ENCONTRADO NA MEMORIA! ID:", id, "Tipo:", tipoGrupo)
                local grupo = {}
                for i = 1, tamanhoNecessario do
                    table.insert(grupo, cartasDisponiveis[i])
                end
                return grupo
            end
        end
    end
    
    print("[IA] Não encontrei grupos completos na minha memória")
    return {}
end

function Cooperativo:buscarParParaCarta(cartaAlvo)
    -- Busca na memória própria se há outra carta com o mesmo ID
    if not self.memoriaIA or not self.memoriaIA[cartaAlvo.id] then
        return nil
    end
    
    for _, item in ipairs(self.memoriaIA[cartaAlvo.id]) do
        if item.carta ~= cartaAlvo and not item.carta.encontrada and not item.carta.revelada then
            return item.carta
        end
    end
    
    return nil
end

function Cooperativo:mostrarEstadoMemoria()
    -- Verifica se a memória foi inicializada
    if not self.memoriaIA then
        self.memoriaIA = {}
    end
    
    print("[IA] === ESTADO DA MINHA MEMÓRIA ===")
    local temMemoria = false
    for id, lista in pairs(self.memoriaIA) do
        local disponiveis = 0
        for _, item in ipairs(lista) do
            if not item.carta.encontrada then
                disponiveis = disponiveis + 1
            end
        end
        if disponiveis > 0 then
            print("[IA] ID " .. id .. ": " .. disponiveis .. " cartas lembradas")
            temMemoria = true
        end
    end
    if not temMemoria then
        print("[IA] Memória vazia")
    end
    print("[IA] ================================")
end

function Cooperativo:jogadaIA()
    print("[IA] === INICIANDO MINHA JOGADA ===")
    
    -- Verifica se realmente é vez da IA
    if not self.vezIA then
        print("[IA] ERRO: Não é minha vez! vezIA:", self.vezIA)
        return
    end
    
    -- Verifica se pode jogar
    if #self.partida.cartasViradasNoTurno > 0 then
        print("[IA] ERRO: Ainda ha " .. #self.partida.cartasViradasNoTurno .. " cartas viradas")
        return
    end
    
    -- Marca que IA está jogando para evitar múltiplas chamadas
    if self.iaEstaJogando then
        print("[IA] ERRO: Ja estou jogando! Evitando chamada dupla")
        return
    end
    self.iaEstaJogando = true
    
    if self.modoVariavel then
        print("[IA] Modo extremo - analisando objetivos...")
    else
        print("[IA] Preciso virar " .. self.cartasPorGrupo .. " cartas")
    end
    
    self:mostrarEstadoMemoria()
    
    -- MARCA: Esta jogada é da IA
    self.ultimaJogadaFoiIA = true
    
    local cartas = {}
    
    -- PRIMEIRO: Busca grupo conhecido na MINHA memória (sempre tenta usar memória no cooperativo)
    local usarMemoria = math.random() < self.chanceUsarMemoria
    
    if usarMemoria then
        cartas = self:buscarGrupoNaMemoria()
        
        if #cartas > 0 then
            print("[IA] Formar o grupo que já conheço: ID " .. cartas[1].id)
        else
            cartas = {}  -- Limpa se não conseguiu grupo completo
        end
    else
        print("[IA] Não usar memória desta vez (explorando)")
    end
    
    -- SEGUNDO: Se não tem grupo conhecido, escolhe uma carta e define tamanho
    if #cartas == 0 then
        print("[IA] Jogar de forma exploratória...")
        
        local primeiraCarta = self:selecionarCartaInteligente()
        if not primeiraCarta then
            print("[IA] ERRO: Não consegui encontrar primeira carta")
            self.iaEstaJogando = false  
            return
        end
        
        local tamanhoGrupo = self.modoVariavel and self:obterTamanhoGrupoEsperado(primeiraCarta.id) or self.cartasPorGrupo
        
        table.insert(cartas, primeiraCarta)
        print("[IA] Primeira carta ID " .. primeiraCarta.id .. " - Preciso de " .. tamanhoGrupo .. " cartas")
        
        -- Busca o resto do grupo
        for i = 2, tamanhoGrupo do
            local carta = self:selecionarCartaInteligente()
            if carta then
                table.insert(cartas, carta)
                print("[IA] Adicionei carta " .. i .. ": ID " .. carta.id)
            else
                print("[IA] Não consegui encontrar carta " .. i)
            end
        end
    end
    
    if #cartas == 0 then
        print("[IA] ERRO: Nao consegui encontrar cartas suficientes")
        self.iaEstaJogando = false  
        return
    end
    
    -- Verifica se há cartas duplicadas na seleção
    local cartasUnicas = {}
    for _, carta in ipairs(cartas) do
        local chave = carta.x .. "_" .. carta.y
        if cartasUnicas[chave] then
            print("[IA] ERRO: Carta duplicada detectada! Posicao:", carta.x, carta.y)
            self.iaEstaJogando = false
            return
        end
        cartasUnicas[chave] = true
    end
    
    print("[IA] 🎮 Virando " .. #cartas .. " cartas:")
    for i, carta in ipairs(cartas) do
        print("  Carta " .. i .. ": ID " .. carta.id .. " Pos:", carta.x, carta.y)
        
        -- Verifica se carta já estava revelada
        if carta.revelada then
            print("ERRO CRITICO: Carta já estava revelada!")
            self.iaEstaJogando = false
            return
        end
        
        -- Verifica se carta já está no turno
        for _, cartaTurno in ipairs(self.partida.cartasViradasNoTurno) do
            if cartaTurno == carta then
                print("ERRO CRÍTICO: Carta ja esta em cartasViradasNoTurno!")
                self.iaEstaJogando = false
                return
            end
        end
    end
    
    -- Executa a jogada da IA
    for _, carta in ipairs(cartas) do
        carta.revelada = true
        self:adicionarCartaMemoriaIA(carta)
        table.insert(self.partida.cartasViradasNoTurno, carta)
    end
    
    -- Confirma quantas cartas foram realmente adicionadas
    print("[IA] Adicionei " .. #self.partida.cartasViradasNoTurno .. " cartas ao turno")
    
    -- No modo extremo, define o grupo esperado
    if self.modoVariavel then
        self.grupoAtualEsperado = #cartas
    end
    
    -- Verifica se formou grupo através da função padrão
    self:verificarGrupo()
    
    -- Libera flag no final
    self.iaEstaJogando = false
    print("[IA] === TERMINEI MINHA JOGADA ===")
end

function Cooperativo:getStatus()
    return {
        modo = "Cooperativo - Fácil",
        multiplicador = self.multiplicadorSequencia,
        paresConsecutivos = self.paresConsecutivos,
        vezIA = self.vezIA,
        tempoRestante = math.ceil(self.partida.tempoRestante)
    }
end

return Cooperativo