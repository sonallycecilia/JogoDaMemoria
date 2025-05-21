local Config = {}

-- Configurações de janela
Config.janela = {
    LARGURA_TELA = love.graphics.getWidth(),
    ALTURA_TELA = love.graphics.getHeight(),
    IMAGEM_TELA_INICIAL = "midia/images/telaInicial.png" ,
    IMAGEM_TELA_PARTIDA = "midia/images/telaPartida.png",
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

