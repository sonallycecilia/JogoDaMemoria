-- inteligencia_maquina/adversarioCooperativo.lua
-- Versão específica para o modo cooperativo
math.randomseed(os.time())

local AdversarioCooperativo = {}
AdversarioCooperativo.__index = AdversarioCooperativo

function AdversarioCooperativo:new(nivel)
    local self = setmetatable({}, AdversarioCooperativo)
    
    self.memoria = {}
    self.paresEncontrados = 0
    self.nivel = nivel or 1
    
    -- Configurações de inteligência baseadas no nível
    local configInteligencia = {
        [1] = {probabilidadeMemoria = 0.85, probabilidadeAcerto = 0.90}, -- Fácil
        [2] = {probabilidadeMemoria = 0.75, probabilidadeAcerto = 0.80}, -- Médio  
        [3] = {probabilidadeMemoria = 0.65, probabilidadeAcerto = 0.70}, -- Difícil
        [4] = {probabilidadeMemoria = 0.55, probabilidadeAcerto = 0.60}  -- Extremo
    }
    
    local config = configInteligencia[nivel] or configInteligencia[1]
    self.probabilidadeMemoria = config.probabilidadeMemoria
    self.probabilidadeAcerto = config.probabilidadeAcerto
    
    -- Histórico de jogadas para melhorar estratégia
    self.historicoJogadas = {}
    self.cartasVistasRecentemente = {}
    
    return self
end

function AdversarioCooperativo:inicializarMemoria(linhas, colunas)
    self.linhas = linhas
    self.colunas = colunas
    
    for i = 1, linhas do
        self.memoria[i] = {}
        for j = 1, colunas do
            self.memoria[i][j] = nil
        end
    end
end

function AdversarioCooperativo:adicionarCartaMemoria(carta)
    if not carta or not carta.x or not carta.y then return end
    
    -- Converte posição visual para índices de grid
    local linha, coluna = self:posicaoParaIndices(carta.x, carta.y)
    
    if linha and coluna then
        if not self.memoria[linha] then self.memoria[linha] = {} end
        self.memoria[linha][coluna] = {
            id = carta.id,
            pathImagem = carta.pathImagem,
            posX = carta.x,
            posY = carta.y,
            tempoVista = love.timer.getTime(),
            encontrada = carta.encontrada
        }
        
        -- Adiciona ao histórico de cartas vistas recentemente
        table.insert(self.cartasVistasRecentemente, {
            id = carta.id,
            linha = linha,
            coluna = coluna,
            tempo = love.timer.getTime()
        })
        
        -- Mantém apenas as 10 cartas mais recentes
        if #self.cartasVistasRecentemente > 10 then
            table.remove(self.cartasVistasRecentemente, 1)
        end
    end
end

function AdversarioCooperativo:posicaoParaIndices(x, y)
    -- Calcula qual célula do grid baseado na posição
    local ESPACAMENTO = 10
    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()
    
    -- Estima tamanho da carta baseado no layout
    local larguraDisponivel = larguraTela - ((self.colunas + 1) * ESPACAMENTO)
    local alturaDisponivel = alturaTela - ((self.linhas + 1) * ESPACAMENTO)
    local tamanhoCarta = math.min(
        math.floor(larguraDisponivel / self.colunas),
        math.floor(alturaDisponivel / self.linhas)
    )
    
    local totalLargura = self.colunas * (tamanhoCarta + ESPACAMENTO) - ESPACAMENTO
    local totalAltura = self.linhas * (tamanhoCarta + ESPACAMENTO) - ESPACAMENTO
    local xInicial = (larguraTela - totalLargura) / 2
    local yInicial = (alturaTela - totalAltura) / 2
    
    -- Calcula linha e coluna
    local coluna = math.floor((x - xInicial) / (tamanhoCarta + ESPACAMENTO)) + 1
    local linha = math.floor((y - yInicial) / (tamanhoCarta + ESPACAMENTO)) + 1
    
    if linha >= 1 and linha <= self.linhas and coluna >= 1 and coluna <= self.colunas then
        return linha, coluna
    end
    
    return nil, nil
end

function AdversarioCooperativo:buscarParConhecido()
    local memoriaPorID = {}
    
    -- Agrupa cartas na memória por ID
    for i = 1, self.linhas do
        for j = 1, self.colunas do
            local cartaMemoria = self.memoria[i] and self.memoria[i][j]
            if cartaMemoria and not cartaMemoria.encontrada then
                local id = cartaMemoria.id
                memoriaPorID[id] = memoriaPorID[id] or {}
                table.insert(memoriaPorID[id], {
                    linha = i,
                    coluna = j,
                    dadosCarta = cartaMemoria
                })
            end
        end
    end
    
    -- Procura pares conhecidos, priorizando cartas vistas recentemente
    local melhorPar = nil
    local melhorPrioridade = -1
    
    for id, lista in pairs(memoriaPorID) do
        if #lista >= 2 then
            -- Calcula prioridade baseada em quão recentemente foram vistas
            local tempoTotal = 0
            for _, item in ipairs(lista) do
                tempoTotal = tempoTotal + (item.dadosCarta.tempoVista or 0)
            end
            local prioridade = tempoTotal / #lista
            
            if prioridade > melhorPrioridade then
                melhorPrioridade = prioridade
                melhorPar = {lista[1], lista[2]}
            end
        end
    end
    
    return melhorPar
end

function AdversarioCooperativo:selecionarCartaInteligente(tabuleiro, ignorarCarta)
    local cartasDisponiveis = {}
    
    -- Coleta cartas disponíveis
    for _, carta in ipairs(tabuleiro.cartas) do
        if not carta.encontrada and carta ~= ignorarCarta then
            table.insert(cartasDisponiveis, carta)
        end
    end
    
    if #cartasDisponiveis == 0 then return nil end
    
    -- Estratégia: prioriza cartas próximas às vistas recentemente
    local cartaComPrioridade = {}
    
    for _, carta in ipairs(cartasDisponiveis) do
        local prioridade = self:calcularPrioridadeCarta(carta)
        table.insert(cartaComPrioridade, {carta = carta, prioridade = prioridade})
    end
    
    -- Ordena por prioridade (maior primeiro)
    table.sort(cartaComPrioridade, function(a, b) 
        return a.prioridade > b.prioridade 
    end)
    
    -- Adiciona um elemento de aleatoriedade para não ser muito previsível
    local indiceMax = math.min(3, #cartaComPrioridade)
    local indiceEscolhido = math.random(1, indiceMax)
    
    return cartaComPrioridade[indiceEscolhido].carta
end

function AdversarioCooperativo:calcularPrioridadeCarta(carta)
    local prioridade = 0
    
    -- Prioridade maior para cartas com pares conhecidos na memória
    local temPar = self:verificaSeTemParNaMemoria(carta.id)
    if temPar then
        prioridade = prioridade + 100
    end
    
    -- Prioridade menor para cartas vistas muito recentemente (evita repetição)
    for _, cartaVista in ipairs(self.cartasVistasRecentemente) do
        if cartaVista.id == carta.id then
            local tempoDecorrido = love.timer.getTime() - cartaVista.tempo
            if tempoDecorrido < 5 then -- Últimos 5 segundos
                prioridade = prioridade + 50
            end
        end
    end
    
    -- Adiciona aleatoriedade para evitar comportamento muito mecânico
    prioridade = prioridade + math.random(1, 20)
    
    return prioridade
end

function AdversarioCooperativo:verificaSeTemParNaMemoria(idCarta)
    local contador = 0
    
    for i = 1, self.linhas do
        for j = 1, self.colunas do
            local cartaMemoria = self.memoria[i] and self.memoria[i][j]
            if cartaMemoria and cartaMemoria.id == idCarta and not cartaMemoria.encontrada then
                contador = contador + 1
                if contador >= 2 then
                    return true
                end
            end
        end
    end
    
    return false
end

function AdversarioCooperativo:realizarJogadaCooperativa(tabuleiro)
    -- Primeiro, tenta usar memória se possível
    local usarMemoria = math.random() < self.probabilidadeMemoria
    local primeira, segunda = nil, nil
    
    if usarMemoria then
        local parConhecido = self:buscarParConhecido()
        if parConhecido then
            -- Converte informações da memória de volta para cartas do tabuleiro
            primeira = self:encontrarCartaPorPosicao(tabuleiro, parConhecido[1])
            segunda = self:encontrarCartaPorPosicao(tabuleiro, parConhecido[2])
        end
    end
    
    -- Se não encontrou par na memória, faz seleção inteligente
    if not primeira or not segunda then
        primeira = self:selecionarCartaInteligente(tabuleiro)
        if primeira then
            -- Tenta encontrar par para a primeira carta
            segunda = self:buscarParParaCarta(tabuleiro, primeira)
            if not segunda then
                segunda = self:selecionarCartaInteligente(tabuleiro, primeira)
            end
        end
    end
    
    return primeira, segunda
end

function AdversarioCooperativo:encontrarCartaPorPosicao(tabuleiro, infoMemoria)
    for _, carta in ipairs(tabuleiro.cartas) do
        local linha, coluna = self:posicaoParaIndices(carta.x, carta.y)
        if linha == infoMemoria.linha and coluna == infoMemoria.coluna and not carta.encontrada then
            return carta
        end
    end
    return nil
end

function AdversarioCooperativo:buscarParParaCarta(tabuleiro, cartaAlvo)
    for i = 1, self.linhas do
        for j = 1, self.colunas do
            local cartaMemoria = self.memoria[i] and self.memoria[i][j]
            if cartaMemoria and cartaMemoria.id == cartaAlvo.id and not cartaMemoria.encontrada then
                local carta = self:encontrarCartaPorPosicao(tabuleiro, {linha = i, coluna = j})
                if carta and carta ~= cartaAlvo then
                    return carta
                end
            end
        end
    end
    return nil
end

function AdversarioCooperativo:registrarResultadoJogada(primeira, segunda, sucesso)
    -- Registra o resultado para aprender com os padrões
    table.insert(self.historicoJogadas, {
        carta1Id = primeira.id,
        carta2Id = segunda.id,
        sucesso = sucesso,
        tempo = love.timer.getTime()
    })
    
    -- Mantém apenas as últimas 20 jogadas
    if #self.historicoJogadas > 20 then
        table.remove(self.historicoJogadas, 1)
    end
    
    if sucesso then
        self.paresEncontrados = self.paresEncontrados + 1
    end
end

return AdversarioCooperativo