local Config = {}

--metodos uteis
local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return { r, g, b }
end

-- Configurações de janela
Config.janela = {
    LARGURA_TELA = love.graphics.getWidth(),
    ALTURA_TELA = love.graphics.getHeight(),
    IMAGEM_TELA_INICIAL = "midia/images/telaInicial.png" ,
    IMAGEM_TELA_PARTIDA = "midia/images/telaPartida.png",
}

Config.scaleX = 0.5
Config.scaleY = 0.5
Config.defaultErrorImage = "assets/erro.png"

Config.botoes = {
    largura = 200,
    altura = 50,
    coresBotao = {
        normal = hexToRGB("#b66e54"),
        hover = hexToRGB("#ce8f79"),
        selecionado = hexToRGB("#ce8f79")
    }
}

Config.deck = {
        "midia/images/cartas/fada.png",
        "midia/images/cartas/naly.png",
        "midia/images/cartas/elfa.png",
        "midia/images/cartas/draenei.png",
        "midia/images/cartas/borboleta.png",
        "midia/images/cartas/lua.png",
        "midia/images/cartas/coracao.png",
        "midia/images/cartas/draenei.png",
        "midia/images/cartas/flor.png",
        "midia/images/cartas/gato.png",
        "midia/images/cartas/pocao.png",
        "midia/images/cartas/planta.png",
}

return Config

