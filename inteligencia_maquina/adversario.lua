-- inteligencia_maquina/adversario.lua
math.randomseed(os.time())

local SEM_CARTA = -1

local Adversario = {}
Adversario.__index = Adversario

function Adversario:new()
    local self = setmetatable({}, Adversario)
    self.memoria = {}
    self.paresEncontrados = 0
    return self
end

function Adversario:inicializarMemoria(linhas, colunas)
    self.memoriaLinhas = linhas 
    self.memoriaColunas = colunas 
    self.memoria = {}

  
    for r = 0, linhas - 1 do
        self.memoria[r] = {}
        for c = 0, colunas - 1 do
            self.memoria[r][c] = nil 
        end
    end
    print("[IA] Memória inicializada para " .. linhas .. "x" .. colunas .. " slots.")
end

function Adversario:adicionarCartaMemoria(carta)
    -- ✅ USAR AS COORDENADAS DE GRID (row, col)
    local row = carta.row
    local col = carta.col

    -- ✅ Adicione verificações de segurança:
    if row == nil or col == nil then
        print("[IA][AVISO] Tentativa de adicionar carta sem row/col à memória. Pulando. Carta ID:", carta.id)
        return -- A IA não pode memorizar esta carta sem suas coordenadas de grid.
    end
    if carta.ehEspecial then -- A IA não precisa memorizar cartas especiais para combinação.
        return
    end
    -- if not carta.revelada then return end -- Se essa check for para a IA só memorizar cartas que ela virou, mantenha.

    -- Garante que a sub-tabela da linha exista
    if not self.memoria[row] then
        self.memoria[row] = {}
        print(string.format("[IA][DEBUG] Criada nova linha de memória: %d", row))
    end

    -- Armazena o objeto da carta real na posição correta da matriz
    self.memoria[row][col] = carta
    print(string.format("[IA] Adicionado à memória: ID %s em (%d, %d)", carta.id, row, col))
end

function Adversario:buscarParConhecido()
    local memoriaPorID = {}

    -- ✅ Itera sobre a matriz 2D
    for r = 0, self.memoriaLinhas - 1 do
        for c = 0, self.memoriaColunas - 1 do
            local carta = self.memoria[r] and self.memoria[r][c]
            if carta and not carta.encontrada and not carta.revelada and not carta.ehEspecial then
                local id = carta.id
                memoriaPorID[id] = memoriaPorID[id] or {}
                table.insert(memoriaPorID[id], carta)
            end
        end
    end

    for _, lista in pairs(memoriaPorID) do
        if #lista >= 2 then
            return lista[1], lista[2]
        end
    end
    return nil, nil
end

function Adversario:selecionarCartaAleatoria(tabuleiro, ignorarCarta)
    local tentativas = 0
    local maxTentativas = 100
    local carta

    repeat
        local i = math.random(1, #tabuleiro.cartas)
        carta = tabuleiro.cartas[i]
        tentativas = tentativas + 1
    until carta and not carta.encontrada and carta ~= ignorarCarta or tentativas >= maxTentativas

    return carta
end

function Adversario:buscarPar(tabuleiro, cartaAlvo)
    if not cartaAlvo then return nil end

    for i = 1, #self.memoria do
        for j = 1, #self.memoria[i] do
            local carta = self.memoria[i][j]
            if carta and carta ~= cartaAlvo and not carta.encontrada and carta.id == cartaAlvo.id then
                return carta
            end
        end
    end

    return nil
end

function Adversario:realizarJogada(tabuleiro, partida)
    local primeira, segunda = self:buscarParConhecido()

    -- Probabilidade de agir "inteligente" (70%)
    local usarMemoria = primeira and segunda and math.random() < 0.7

    if not usarMemoria then
        primeira = self:selecionarCartaAleatoria(tabuleiro)
        if not primeira then return end
        segunda = self:buscarPar(tabuleiro, primeira)
            or self:selecionarCartaAleatoria(tabuleiro, primeira)
    end

    if not primeira or not segunda then return end

    primeira.revelada = true
    segunda.revelada = true
    self:adicionarCartaMemoria(primeira)
    self:adicionarCartaMemoria(segunda)

    if primeira.id == segunda.id then
        primeira.encontrada = true
        segunda.encontrada = true
        tabuleiro:removerGrupoEncontrado({primeira, segunda})
        self.paresEncontrados = self.paresEncontrados + 1
        partida.cartasViradasNoTurno = {}
        print("[IA] Acertou um par")
    else
        partida.cartasViradasNoTurno = {primeira, segunda}
        partida.timerCartasViradas = 1
    end
end

return Adversario
