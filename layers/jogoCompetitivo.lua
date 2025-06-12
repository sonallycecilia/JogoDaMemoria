-- layers/jogoCompetitivo.lua
local Partida = require("classes.partida")
local Config = require("config")

local JogoCompetitivo = {}

function JogoCompetitivo:new()
    local self = {}
    setmetatable(self, {__index = JogoCompetitivo})
    
    self.proximaLayer = nil
    self.partida = nil
    self.pausado = false
    
    return self
end

function JogoCompetitivo:iniciar(dificuldade)
    -- dificuldade: 1=fácil, 2=médio, 3=difícil, 4=extremo
    dificuldade = dificuldade or 1
    
    print("Iniciando competitivo - Dificuldade: " .. tostring(dificuldade))
    
    -- Cria nova partida competitiva
    self.partida = Partida:new("competitivo", dificuldade)
    self.pausado = false
    
    print("Partida competitiva criada: " .. tostring(self.partida ~= nil))
    if self.partida and self.partida.modoCompetitivo then
        print("Modo competitivo ativo: " .. tostring(self.partida.modoCompetitivo ~= nil))
    end
end

function JogoCompetitivo:update(dt)
    if not self.pausado and self.partida then
        self.partida:update(dt)
        
        -- Verifica se a partida terminou
        if self.partida.partidaFinalizada then
            -- Aguarda um tempo antes de voltar ao menu
            self.tempoEspera = (self.tempoEspera or 0) + dt
            if self.tempoEspera > 5 then -- Mais tempo para ver resultado
                self.proximaLayer = "menuPrincipal"
            end
        end
    end
end

function JogoCompetitivo:draw()
    if self.partida then
        -- DESENHA O FUNDO E FRAMES
        self:drawFundo()
        
        -- Desenha o tabuleiro
        self.partida.tabuleiro:draw()
        
        -- Desenha interface específica do competitivo
        self:drawInterfaceCompetitivo()
    else
        -- Debug: mostra se partida não foi criada
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print("ERRO: Partida competitiva não foi criada!", 100, 100)
        love.graphics.setColor(1, 1, 1)
    end
    
    if self.pausado then
        self:drawMenuPausa()
    end
end

function JogoCompetitivo:drawFundo()
    -- Desenha fundo igual ao jogoCooperativo
    love.graphics.clear(0, 0, 0, 0)
    
    local LARGURA_TELA = love.graphics.getWidth()
    local ALTURA_TELA = love.graphics.getHeight()
    
    -- Carrega as imagens se não foram carregadas
    if not self.imagensCarregadas then
        self.imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_PARTIDA)
        self.imagemTabuleiro = love.graphics.newImage(Config.frames.partida.tabuleiro)
        self.imagemCarta = love.graphics.newImage(Config.frames.partida.carta)
        self.imagemScore = love.graphics.newImage(Config.frames.partida.score)
        self.imagensCarregadas = true
    end
    
    -- Fundo principal
    local larguraImagem = self.imagemFundo:getWidth()
    local alturaImagem = self.imagemFundo:getHeight()
    local xFundo = (LARGURA_TELA - larguraImagem) / 2
    local yFundo = (ALTURA_TELA - alturaImagem) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.imagemFundo, xFundo, yFundo)
    
    -- Frames
    love.graphics.draw(self.imagemTabuleiro, 50, 130, 0, 0.9, 0.9)
    love.graphics.draw(self.imagemScore, 990, 130, 0, 0.8, 0.8)
    love.graphics.draw(self.imagemCarta, 990, 323, 0, 0.8, 0.8)
end

function JogoCompetitivo:drawInterfaceCompetitivo()
    if not self.partida then return end
    
    local largura = love.graphics.getWidth()
    local info = self.partida:getStatusInfo()
    
    -- Painel de informações no canto superior direito
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", largura - 280, 10, 270, 180)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    
    local x, y = largura - 270, 20
    
    -- Título
    love.graphics.setColor(1, 0.8, 0) -- Dourado para competitivo
    love.graphics.print("MODO COMPETITIVO", x, y)
    love.graphics.setColor(1, 1, 1)
    y = y + 25
    
    -- Tempo
    love.graphics.print("Tempo: " .. math.floor(info.tempo / 60) .. ":" .. string.format("%02d", info.tempo % 60), x, y)
    y = y + 20
    
    -- Placar
    love.graphics.setColor(0.2, 1, 0.2) -- Verde para humano
    love.graphics.print("VOCÊ: " .. (info.scoreHumano or 0) .. " pts", x, y)
    y = y + 20
    
    love.graphics.setColor(1, 0.2, 0.2) -- Vermelho para IA
    love.graphics.print("IA: " .. (info.scoreIA or 0) .. " pts", x, y)
    y = y + 20
    
    love.graphics.setColor(1, 1, 1)
    
    -- Grupos encontrados
    love.graphics.print("Grupos: " .. (info.gruposHumano or 0) .. " x " .. (info.gruposIA or 0), x, y)
    y = y + 20
    
    -- Vez do jogador
    if info.jogadorAtual == "HUMANO" then
        love.graphics.setColor(0.2, 1, 0.2) -- Verde
        love.graphics.print(">>> SUA VEZ! <<<", x, y)
    else
        love.graphics.setColor(0.2, 0.8, 1) -- Azul
        love.graphics.print(">>> VEZ DA IA <<<", x, y)
    end
    love.graphics.setColor(1, 1, 1)
    y = y + 25
    
    -- Status da competição
    if info.scoreHumano and info.scoreIA then
        if info.scoreHumano > info.scoreIA then
            love.graphics.setColor(0.2, 1, 0.2) -- Verde
            love.graphics.print("VOCÊ ESTÁ GANHANDO!", x, y)
        elseif info.scoreIA > info.scoreHumano then
            love.graphics.setColor(1, 0.2, 0.2) -- Vermelho
            love.graphics.print("IA ESTÁ GANHANDO!", x, y)
        else
            love.graphics.setColor(1, 1, 0.2) -- Amarelo
            love.graphics.print("EMPATE!", x, y)
        end
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Alerta de tempo baixo
    if info.tempo <= 30 and info.tempo > 0 then
        love.graphics.setColor(1, 0.2, 0.2) -- Vermelho
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.print("TEMPO BAIXO!", largura/2 - 60, 50)
        love.graphics.setColor(1, 1, 1)
    end
end

function JogoCompetitivo:drawMenuPausa()
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()
    
    -- Fundo escuro
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, largura, altura)
    
    -- Menu de pausa
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(30))
    
    local opcoes = {"Continuar", "Reiniciar", "Menu Principal"}
    local inicioY = altura/2 - (#opcoes * 25)
    
    for i, opcao in ipairs(opcoes) do
        local y = inicioY + (i-1) * 50
        local x = largura/2 - love.graphics.getFont():getWidth(opcao)/2
        love.graphics.print(opcao, x, y)
    end
end

function JogoCompetitivo:mousepressed(x, y, button)
    print("JogoCompetitivo:mousepressed chamado - x:" .. x .. " y:" .. y .. " button:" .. button)
    
    if self.pausado then
        return self:cliquePausa(x, y, button)
    end
    
    if self.partida and not self.partida.partidaFinalizada then
        print("Passando clique para partida competitiva...")
        local resultado = self.partida:mousepressed(x, y, button)
        print("Resultado do clique na partida:", resultado)
        return resultado
    end
    
    print("Clique não foi processado (partida finalizada ou não existe)")
    return false
end

function JogoCompetitivo:cliquePausa(x, y, button)
    if button ~= 1 then return false end
    
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()
    local opcoes = {"Continuar", "Reiniciar", "Menu Principal"}
    local inicioY = altura/2 - (#opcoes * 25)
    
    for i, opcao in ipairs(opcoes) do
        local yOpcao = inicioY + (i-1) * 50
        local fonte = love.graphics.newFont(30)
        local xOpcao = largura/2 - fonte:getWidth(opcao)/2
        local larguraOpcao = fonte:getWidth(opcao)
        local alturaOpcao = fonte:getHeight()
        
        if x >= xOpcao and x <= xOpcao + larguraOpcao and 
           y >= yOpcao and y <= yOpcao + alturaOpcao then
            
            if i == 1 then -- Continuar
                self.pausado = false
            elseif i == 2 then -- Reiniciar
                self:iniciar(self.partida.nivel)
                self.pausado = false
            elseif i == 3 then -- Menu Principal
                self.proximaLayer = "menuPrincipal"
            end
            
            return true
        end
    end
    
    return false
end

function JogoCompetitivo:keypressed(key)
    if key == "escape" or key == "p" then
        if self.partida and not self.partida.partidaFinalizada then
            self.pausado = not self.pausado
        end
    elseif key == "r" and love.keyboard.isDown("lctrl") then
        -- Ctrl+R para reiniciar rapidamente
        if self.partida then
            self:iniciar(self.partida.nivel)
        end
    end
end

-- Funções helper para diferentes dificuldades
function JogoCompetitivo:iniciarFacil()
    self:iniciar(1)
end

function JogoCompetitivo:iniciarMedio()
    self:iniciar(2)
end

function JogoCompetitivo:iniciarDificil()
    self:iniciar(3)
end

function JogoCompetitivo:iniciarExtremo()
    self:iniciar(4)
end

return JogoCompetitivo