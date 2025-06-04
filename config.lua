local Config = {}

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
    largura = 404,
    altura = 80,
    imagemPath = {
        menuPrincipal ={
        iniciarJogo = "midia/botoes/menuPrincipal/iniciarJogo.png",
        configuracoes = "midia/botoes/menuPrincipal/configuracoes.png",
        conquistas = "midia/botoes/menuPrincipal/conquistas.png",
        creditos = "midia/botoes/menuPrincipal/creditos.png",
        skins = "midia/botoes/menuPrincipal/skins.png",
        sair = "midia/botoes/menuPrincipal/sair.png",
        },
        menuJogo = {
            competitivo = "midia/botoes/menuJogo/competitivo.png",
            cooperativo = "midia/botoes/menuJogo/cooperativo.png",
            solo = "midia/botoes/menuJogo/solo.png",
            voltar = "midia/botoes/menuJogo/voltar.png",
        }
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

Config.frames = {
    menu = {
        imagemPath = "midia/frames/fundoMenu.png",
    }
}


return Config

