-- layers/jogoCooperativo.lua
local Partida = require("classes.partida")
local Config = require("config")

local JogoCooperativo = {}

function JogoCooperativo:new()
    local self = {}
    setmetatable(self, {__index = JogoCooperativo})
    
    self.proximaLayer = nil
    self.partida = nil
    self.pausado = false
    
    return self
end

function JogoCooperativo:iniciar(dificuldade)
    -- dificuldade: 1=fácil, 2=médio, 3=difícil, 4=extremo
    dificuldade = dificuldade or 1
    
    print("Iniciando cooperativo - Dificuldade: " .. tostring(dificuldade))
    
    -- Cria nova partida cooperativa
    self.partida = Partida:new("cooperativo", dificuldade)
    self.pausado = false
    
    -- Obtém configuração específica
    local config = Config.getCooperativoConfig(dificuldade)
    print("Partida criada: " .. tostring(self.partida ~= nil))
end

function JogoCooperativo:update(dt)
    if not self.pausado and self.partida then
        self.partida:update(dt)
        
        -- Verifica se a partida terminou
        if self.partida.partidaFinalizada then
            -- Aguarda um tempo antes de voltar ao menu
            self.tempoEspera = (self.tempoEspera or 0) + dt
            if self.tempoEspera > 3 then
                self.proximaLayer = "menuPrincipal"
            end
        end
    end
end

function JogoCooperativo:draw()
    if self.partida then
        -- DESENHA O FUNDO E FRAMES COMO NO PARTIDA LAYER
        self:drawFundo()
        
        -- Desenha o tabuleiro
        self.partida.tabuleiro:draw()
        
        -- Desenha interface adicional do cooperativo
        self:drawInterfaceCooperativo()
    else
        -- Debug: mostra se partida não foi criada
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print("ERRO: Partida não foi criada!", 100, 100)
        love.graphics.setColor(1, 1, 1)
    end
    
    if self.pausado then
        self:drawMenuPausa()
    end
end

function JogoCooperativo:drawFundo()
    -- Desenha fundo igual ao partidaLayer
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

function JogoCooperativo:drawInterfaceCooperativo()
    if not self.partida then return end
    
    local largura = love.graphics.getWidth()
    local info = self.partida:getStatusInfo()
    
    -- Painel de informações no canto superior direito
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", largura - 250, 10, 240, 120)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    
    local x, y = largura - 240, 20
    
    love.graphics.print("MODO COOPERATIVO", x, y)
    y = y + 20
    
    love.graphics.print("Tempo: " .. math.floor(info.tempo / 60) .. ":" .. string.format("%02d", info.tempo % 60), x, y)
    y = y + 20
    
    love.graphics.print("Pontos: " .. tostring(info.score), x, y)
    y = y + 20
    
    -- Informações específicas do cooperativo
    if info.multiplicador and info.multiplicador > 1 then
        love.graphics.setColor(0.2, 1, 0.2) -- Verde
        love.graphics.print("Mult: " .. string.format("%.1f", info.multiplicador) .. "x", x, y)
        love.graphics.setColor(1, 1, 1)
        y = y + 20
    end
    
    if info.paresConsecutivos and info.paresConsecutivos > 1 then
        love.graphics.setColor(1, 1, 0.2) -- Amarelo
        love.graphics.print("Sequência: " .. tostring(info.paresConsecutivos), x, y)
        love.graphics.setColor(1, 1, 1)
        y = y + 20
    end
    
    if info.vezIA then
        love.graphics.setColor(0.2, 0.8, 1) -- Azul
        love.graphics.print("IA jogando...", x, y)
        love.graphics.setColor(1, 1, 1)
    end
    
    -- Alerta de tempo baixo
    if info.tempo <= 30 and info.tempo > 0 then
        love.graphics.setColor(1, 0.2, 0.2) -- Vermelho
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.print("TEMPO BAIXO!", largura/2 - 50, 50)
        love.graphics.setColor(1, 1, 1)
    end
end

function JogoCooperativo:drawMenuPausa()
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

function JogoCooperativo:mousepressed(x, y, button)
    if self.pausado then
        return self:cliquePausa(x, y, button)
    end
    
    if self.partida and not self.partida.partidaFinalizada then
        return self.partida:mousepressed(x, y, button)
    end
    
    return false
end

function JogoCooperativo:cliquePausa(x, y, button)
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

function JogoCooperativo:keypressed(key)
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

-- Função helper para ser chamada do menu principal
function JogoCooperativo:iniciarFacil()
    self:iniciar(1)
end

function JogoCooperativo:iniciarMedio()
    self:iniciar(2)
end

function JogoCooperativo:iniciarDificil()
    self:iniciar(3)
end

function JogoCooperativo:iniciarExtremo()
    self:iniciar(4)
end

return JogoCooperativo