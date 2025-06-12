local Config = {}

-- Configurações de janela
Config.janela = {
    LARGURA_TELA = 1200,
    ALTURA_TELA = 800,
    IMAGEM_TELA_INICIAL = "midia/images/telaInicial.png" ,
    IMAGEM_TELA_PARTIDA = "midia/images/telaPartida.jpg",
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
        },
        partida = {
            configuracoes = "midia/botoes/partida/configuracoes.png",
            encerrar = "midia/botoes/partida/encerrar.png",
            guia = "midia/botoes/partida/guia.png",
            pausar = "midia/botoes/partida/pausar.png",
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
        imagemPath = "midia/frames/menu.png",
    },
    partida = {
        carta = "midia/frames/carta.png",
        tabuleiro = "midia/frames/tabuleiro.png",
        score = "midia/frames/score.png",
    }
}

Config.cartasEspeciais = {
    tipos = {
    "Revelacao",
    "Congelamento",
    "Bomba"
},
quantidadePorNivel = {
    FACIL = 1,
    MEDIO = 2,
    DIFICIL = 3,
    EXTREMO = 3
},
chance = 0.5 --probabilidade de ser especial
}
Config.tempoRevelada = 1 --demora 1 segundo virada as cartas pos bomba

Config.nomes = {
    niveis = {
        Facil = 1,
        Medio = 2,
        Dificil = 3,
        Extremo = 4
    }
}

Config.CARTA = {
    Largura = 100,
    Altura = 100,
    Verso_carta = "midia/images/verso.png"
}

Config.tabuleiro = {
    ESPACAMENTO = 10,
    Facil = {colunas = 6, linhas = 4, max_cartas = 24},
    Medio = {colunas = 8, linhas = 5, max_cartas = 40},
    Dificil = {colunas = 8, linhas = 6, max_cartas = 48},
    Extremo = {colunas = 10, linhas = 6, max_cartas = 60}
}
return Config

