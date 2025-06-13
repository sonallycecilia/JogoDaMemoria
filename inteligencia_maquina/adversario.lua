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
    for i = 1, linhas*colunas do
        self.memoria[i] = SEM_CARTA
    end
end

function Adversario:adicionarCartaMemoria(carta)
    local x, y = carta.posX, carta.posY
    if not x or not y then return end
    if not carta.revelada then return end

    if not self.memoria[x] then self.memoria[x] = {} end
    self.memoria[x][y] = carta
end

function Adversario:buscarParConhecido()
    local memoriaPorID = {}

    for i = 1, #self.memoria do
        for j = 1, #self.memoria[i] do
            local carta = self.memoria[i][j]
            if carta and not carta.encontrada then
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
