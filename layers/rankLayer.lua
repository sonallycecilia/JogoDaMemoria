-- layers/rankLayer.lua
local Config = require("config")
local Botao = require("interface.botao")

local RankLayer = {}
RankLayer.__index = RankLayer

function RankLayer:new(manager)
    local self = setmetatable({}, RankLayer)
    self.manager = manager
    self.proximaLayer = nil
    
    self.botoes = {
        Botao:new(Config,
            Config.botoes.imagemPath.menuPrincipal.sair,
            50, 50, 0.7, 0.7,
            function() self.proximaLayer = "menuPrincipal" end),
    }
        self.scrollY = 0
    self.dados = {}
    -- Carrega dados do arquivo apenas uma vez
    local arquivo = io.open("exemplo_db.txt", "r")
    if arquivo then
        for linha in arquivo:lines() do
            linha = linha:match("%((.*)%)")
            local campos = {}
            for campo in linha:gmatch("[^,]+") do
                campo = campo:gsub("^%s*", ""):gsub("%s*$", ""):gsub("^['\"](.-)['\"]$", "%1")
                table.insert(campos, campo)
            end
            local registro = {
                nome = campos[1],
                pontuacao = campos[6],
                dificuldade = campos[7],
                modo = campos[8]
            }
            table.insert(self.dados, registro)
        end
        arquivo:close()
    end
    
    return self
end

function RankLayer:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, botao in ipairs(self.botoes) do
        botao:update(mx, my)
    end
end

function RankLayer:wheelmoved(x, y)
    self.scrollY = self.scrollY + y * 20
end

function RankLayer:draw()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setFont(Config.fonte)
    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    
    -- Fundo principal
    local imagemFundo = love.graphics.newImage(Config.janela.IMAGEM_TELA_INICIAL)
    local xFundo = (larguraTela - imagemFundo:getWidth()) / 2
    local yFundo = (alturaTela - imagemFundo:getHeight()) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(imagemFundo, xFundo, yFundo)

    -- Camada preta translúcida
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, larguraTela, alturaTela)

    -- Frame do menu com escala reduzida
    local imagemFundoMenu = love.graphics.newImage(Config.frames.menu.imagemPath)
    local menuScale = 0.8
    local larguraMenu = imagemFundoMenu:getWidth() * menuScale
    local alturaMenu = imagemFundoMenu:getHeight() * menuScale
    local xFundoMenu = (larguraTela - larguraMenu) / 2
    local yFundoMenu = (alturaTela - alturaMenu) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(imagemFundoMenu, xFundoMenu, yFundoMenu, 0, menuScale, menuScale)
    
        -- Área interna de scroll
    local padding = 20
    local larguraAreaTexto = larguraMenu - padding * 2
    local alturaAreaTexto = alturaMenu - padding * 2
    local xAreaTexto = xFundoMenu + padding
    local yAreaTexto = yFundoMenu + padding

    -- Fundo translúcido da área de texto
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", xAreaTexto, yAreaTexto, larguraAreaTexto, alturaAreaTexto)

    -- Clipping da área de texto
    love.graphics.setScissor(xAreaTexto, yAreaTexto, larguraAreaTexto, alturaAreaTexto)

    -- Configurações de fonte-- tamanho menor pro restante

    local alturaNome = Config.fonte:getHeight()
    local alturaDados = Config.fonte:getHeight() * 0.7
    local espacamentoEntreRegistros = 20

    -- Posição inicial de texto com scroll
    local xTexto = xAreaTexto + 10
    local yTexto = yAreaTexto + 10 + self.scrollY

    -- Desenha os dados
    for _, jogador in ipairs(self.dados) do
        love.graphics.setFont(Config.fonte)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(jogador.nome, xTexto, yTexto)

        yTexto = yTexto + alturaNome + 5  -- espaço abaixo do nome

        love.graphics.print(
            string.format("%s |  %s |  %s",
            jogador.pontuacao, jogador.dificuldade, jogador.modo), xTexto, yTexto)
            love.graphics.print(" ", xTexto, yTexto)

        yTexto = yTexto + alturaDados + espacamentoEntreRegistros -- espaço entre blocos
    end

    -- Remove scissor
    love.graphics.setScissor()


    -- Calcula altura total real dos botões com espaçamento
    local espacamento = 5  -- margem entre botões
    local alturaTotal = 0
    for _, botao in ipairs(self.botoes) do
    alturaTotal = alturaTotal + (botao.height * botao.scaleY)
    end
    alturaTotal = alturaTotal + espacamento * (#self.botoes - 1)

    local yInicial = yFundoMenu + (alturaMenu - alturaTotal) / 2

    -- Posiciona centralizado
    local yAtual = yInicial
    for _, botao in ipairs(self.botoes) do
        botao.x = xFundoMenu + 200 + (larguraMenu - botao.width * botao.scaleX) / 2
        botao.y = 150 + yAtual
        botao:draw()
        yAtual = yAtual + (botao.height * botao.scaleY) + espacamento
    end
end

function RankLayer:mousepressed(x, y, button)
    for _, botao in ipairs(self.botoes) do
        botao:mousepressed(x, y, button)
    end
end

function RankLayer:mousemoved(x, y, dx, dy)
    for _, botao in ipairs(self.botoes) do
        botao:update(x, y)
    end
end

function RankLayer:formatarPlacar()
end

return RankLayer