local Partida = require("classes.partida")
local Config = require("config")
local Botao = require("interface.botao")
local DataHora = require("classes.utils.dataHora")
local datahora = DataHora:new()
-- layers/layerPartida.lua

local LayerPartida = {}
LayerPartida.__index = LayerPartida

-- Essas variáveis realmente deveriam estar aqui no Layer, ou apenas em partida? e o Layer possuir uma instância de partida que armazena o que é necessário
function LayerPartida:new(manager, modoDeJogo, nivel)
    local self = setmetatable({}, LayerPartida)
    self.manager = manager
    self.proximaLayer = nil
    self.nomeJogador = "convidado" --Nome do jogador será informado ao final da partida
    self.partida = Partida:new(modoDeJogo, nivel)
    
    datahora:atualizar()
    self.dataInicio =  datahora:formatarData()
    self.horaInicio = datahora:formatarHora()
    self.dataFinal = nil
    self.horaFinal = nil

    self.cartasViradasNoTurno = {} 
    self.jogadorAtual = "jogador" or "maquina"--Jogador ou Máquina, jogador sempre começa jogando
    self.tempoParaVirarDeVolta = 1
    self.timerCartasViradas = 0 
    self.partidaFinalizada = false

    self.adversarioIA = require("inteligencia_maquina.adversario")
    self.adversarioIA:inicializarMemoria(self.partida.tabuleiro.linhas, self.partida.tabuleiro.colunas)

    self:load()
    return self
end

function LayerPartida:update(dt)
    -- Atualizações da partida, como animações ou tempo
    
    -- Lógica de tempo para o modo cooperativo
    if self.partida.modoDeJogo == "cooperativo" and not self.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then -- Adicionar verificar para saber se todo os pares foram encontrados
            self.partidaFinalizada = true
            -- Lógica de fim de jogo por tempo
            self:finalizarPartida()
        end
    end

    -- Lógica de tempo para o modo competitivo
    if self.modoDeJogo == "competitivo" and not self.partidaFinalizada then
        self.partida.tempoRestante = self.partida.tempoRestante - dt
        if self.partida.tempoRestante <= 0 then -- Adicionar verificar para saber se todo os pares foram encontrados
            self.partidaFinalizada = true
            -- Lógica de fim de jogo por tempo
            self:finalizarPartida()
        end
    end

    -- Lógica para desvirar as cartas após errar o par
    if #self.cartasViradasNoTurno > 0 and self.timerCartasViradas > 0 then
        self.timerCartasViradas = self.timerCartasViradas - dt
        if self.timerCartasViradas <= 0 then
            for _, carta in ipairs(self.cartasViradasNoTurno) do
                if carta.revelada then -- Desvira apenas se estiver revelada
                    carta:alternarLado()
                end
            end
            self.cartasViradasNoTurno = {}
            -- Troca de turno após o erro
            if self.jogadorAtual == "humano" then
                self.jogadorAtual = "maquina"
            else
                self.jogadorAtual = "humano"
            end
        end
    end

    -- Lógica para a jogada da máquina
    if self.jogadorAtual == "maquina" and not self.partidaFinalizada and #self.cartasViradasNoTurno == 0 then
        self:jogadaMaquina() -- TODO: implementar método que realiza as duas jogadas da máquina 
    end

    -- Verifica se todos os pares foram encontrados
    if self.partida.tabuleiro.cartasRestantes == 0 and not self.partidaFinalizada then
        self.partidaFinalizada = true
        self:finalizarPartida() -- TODO: implementar método de finalização, mostrar o ranking, colocar o nome do jogador...
    end
end

function LayerPartida:load()
    -- Carregue a imagem apenas uma vez
    self.imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
    
    -- frames de imagens
    self.imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro)
    self.imagemCarta = love.graphics.newImage(Config.frames.partida.carta)
    self.imagemScore = love.graphics.newImage(Config.frames.partida.score)
end

function LayerPartida:draw()
    love.graphics.clear(0, 0, 0, 0)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    -- Fundo centralizado
    local larguraImagem = self.imagemFundo:getWidth()
    local alturaImagem = self.imagemFundo:getHeight()
    local xFundo = (larguraTela - larguraImagem) / 2
    local yFundo = (alturaTela - alturaImagem) / 2
    love.graphics.draw(self.imagemFundo, xFundo, yFundo)

    -- ESCALAS ajustadas
    local escalaTabuleiro = 0.9
    local escalaScore = 0.8
    local escalaCarta = 0.8

    -- POSICIONAMENTO baseado na imagem
    local xTabuleiro = 50
    local yTabuleiro = 130

    local xScore = 990
    local yScore = 130

    local xCarta = 990
    local yCarta = 323

    -- Desenhar frames com escalas proporcionais
    love.graphics.draw(self.imagemTabuleiro, xTabuleiro, yTabuleiro, 0, escalaTabuleiro, escalaTabuleiro)
    love.graphics.draw(self.imagemScore, xScore, yScore, 0, escalaScore, escalaScore)
    love.graphics.draw(self.imagemCarta, xCarta, yCarta, 0, escalaCarta, escalaCarta)

    -- Desenhar tabuleiro do jogo (internamente deve respeitar o novo layout)
    self.partida.tabuleiro:draw()
end

-- Talvez esse método seja muito lento
function LayerPartida:mousepressed(x, y, button)
    local indice, carta
    -- Tratar cliques nas cartas
    -- button == 1 é o botão esquerdo do mouse 
    if button == 1 and self.jogadorAtual == "humano" and #self.cartasViradasNoTurno < self.partida.maximoTentativas then
        for linha = 1, 10, 1 do
            for coluna = 1, 10, 1 do
                -- Itera sobre um vetor como se fosse uma matriz 
                indice = (linha-1) * self.partida.tabuleiro.colunas + coluna
                carta = self.partida.tabuleiro.cartas[indice]
                if carta and not carta.revelada and carta:clicada(x,y) then
                    carta:alternarLado()
                    table.insert(self.cartasViradasNoTurno, carta)
                    self.adversarioIA:adicionarCartaMemoria(carta, self.partida.rodadaAtual)

                    if #self.cartasViradasNoTurno == self.partida.maximoTentativas then
                        self:verificaGrupoCartas()
                    end
                    return -- Sai após a carta clicada ter sido encontrada, é melhor tratar isso com um while, refatorar depois
                end
            end
        end
    end
end

function LayerPartida:verificaGrupoCartas()
    local grupoFormado = true -- É mais fácil verificar a condição de não serem um grupo
    local imgPrimeiraCarta = self.cartasViradasNoTurno[1].imagemFrente

    for i = 2, #self.cartasViradasNoTurno, 1 do
        if self.cartasViradasNoTurno[i].imagemFrente ~= imgPrimeiraCarta then
            grupoFormado = false
            break; -- Clean code? Pra que? O importante é funcionar, laço "bonito" é preciosismo 
        end
    end

    -- Transferir essa responsabilidade para um método validaGrupoFormado()
    if grupoFormado then
        -- ACERTOU
        self.partida.score = self.partida.score + #self.cartasViradasNoTurno * 100 -- Cada carta vale 100 pontos
        for _, carta in ipairs(self.cartasViradasNoTurno) do
            self.partida.tabuleiro:removerGrupoEncontrado(self.cartasViradasNoTurno)
        end
        self.cartasViradasNoTurno = {}
    else
        -- ERROU
        self.timerCartasViradas = self.tempoParaVirarDeVolta -- Timer para desvirar
    end

    -- Troca de turno se errou, ou se o humano já jogou e acertou
    if not grupoFormado or self.partida.modoDeJogo == "competitivo" then
        if #self.cartasViradasNoTurno == 0 then
            self:trocaJogadorAtual()
        end
    end
end

function LayerPartida:trocaJogadorAtual()
    if self.jogadorAtual == "jogador" then
        self.jogadorAtual = "maquina"
    end
    if self.jogadorAtual == "maquina" then
        self.jogadorAtual = "jogador"
    end
end

function LayerPartida:finalizarPartida()
    print("Partida finalizada!") -- debug
    local modoDeJogo = self.partida.modoDeJogo
    local dificuldade = self.partida.nivel -- Substituir 1, 2, 3, 4 por FACIL, MEDIO, DIFICIL, EXTREMO. Utilizar a classe nivelDeJogo
    local pontuacao = self.partida.score
    local dataInicio = self.dataInicio
    local horaInicio = self.horaInicio
    local dataFinal = datahora:formatarData()
    local horaFinal = dataHora:formatarHora()
    
    local nomeJogador = nil
    -- Abrir Nova janela para o jogador adicionar o nome
    -- local nomejogador = self.manager:setLayar("telaNomeJogador"):inputNome()
    
    -- TODO: dar merge com o que foi feito no BD 
    Ranking:adicionarResultado(nomeJogador, dataInicio, horaInicio, dataFinal, horaFinal, pontuacao, dificuldade, modoDeJogo )

    -- TODO: criar rankingLayer e adiconar ao layersMap
    self.manager:setLayer("rankingLayer")
end

function LayerPartida:mousemoved(x, y, dx, dy)
    -- Se quiser hover ou efeitos de destaque. Sem tempo pra isso, vai ter não
end

return LayerPartida
