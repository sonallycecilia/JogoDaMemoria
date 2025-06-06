-- config.lua
local Config = {}

-- Configurações da Janela
Config.JANELA = {
    LARGURA_PADRAO = 1200, -- Largura padrão da janela do jogo
    ALTURA_PADRAO = 800,  -- Altura padrão da janela do jogo
    IMAGEM_TELA_INICIAL = "midia/images/telaInicial.png", -- Caminho para a imagem da tela inicial/menu
    IMAGEM_TELA_PARTIDA = "midia/images/telaPartida.png", -- Caminho para a imagem do fundo da partida
}

-- Configurações de escala para elementos da UI (se aplicável ao seu design)
Config.scaleX = 0.5
Config.scaleY = 0.5
Config.defaultErrorImage = "assets/erro.png" -- Caminho para uma imagem de erro padrão (se usada)

-- Configurações de Botões (apenas caminhos para imagens, organize de acordo com suas pastas)
Config.botoes = {
    largura = 404,
    altura = 80,
    imagemPath = {
        menuPrincipal = {
            iniciarJogo = "midia/botoes/menuPrincipal/iniciarJogo.png",
            configuracoes = "midia/botoes/menuPrincipal/configuracoes.png",
            conquistas = "midia/botoes/menuPrincipal/conquistas.png",
            creditos = "midia/botoes/menuPrincipal/creditos.png",
            skins = "midia/botoes/menuPrincipal/skins.png",
            sair = "midia/botoes/menuPrincipal/sair.png",
        },
        menuJogo = { -- Botões para seleção de modo e nível
            competitivo = "midia/botoes/menuJogo/competitivo.png",
            cooperativo = "midia/botoes/menuJogo/cooperativo.png",
            solo = "midia/botoes/menuJogo/solo.png", -- Manter se for usar
            voltar = "midia/botoes/menuJogo/voltar.png",
            facil = "midia/botoes/menuJogo/facil.png",
            medio = "midia/botoes/menuJogo/medio.png",
            dificil = "midia/botoes/menuJogo/dificil.png",
            extremo = "midia/botoes/menuJogo/extremo.png",
            comecarPartida = "midia/botoes/menuJogo/comecarPartida.png", -- Botão para iniciar a partida
            verTop5 = "midia/botoes/menuJogo/verTop5.png", -- Botão para ver o ranking
        }
    }
}

-- Caminhos para as imagens das cartas (seu "baralho" base)
Config.deck = {
    "midia/images/cartas/fada.png",
    "midia/images/cartas/naly.png",
    "midia/images/cartas/elfa.png",
    "midia/images/cartas/draenei.png",
    "midia/images/cartas/borboleta.png",
    "midia/images/cartas/lua.png",
    "midia/images/cartas/coracao.png",
    "midia/images/cartas/flor.png",
    "midia/images/cartas/gato.png",
    "midia/images/cartas/pocao.png",
    "midia/images/cartas/planta.png",
    "midia/images/cartas/estrela.png", -- Exemplo de mais uma para ter 12 únicas
}

-- Caminhos para os frames de UI (como fundos de menu ou painéis)
Config.frames = {
    menu = {
        imagemPath = "midia/frames/fundoMenu.png",
    }
}

-- Configurações da Classe Carta
Config.CARTA = {
    LARGURA = 100,
    ALTURA = 100,
    VERSO_IMAGEM = "midia/images/verso.png", -- Caminho para a imagem do verso da carta
}

-- Configurações do Tabuleiro por Nível
Config.TABULEIRO = {
    ESPACAMENTO = 10,
    FACIL = { colunas = 6, linhas = 4, max_cartas = 24 }, -- Pares (2 cópias)
    MEDIO = { colunas = 8, linhas = 5, max_cartas = 40 }, -- Trincas (3 cópias)
    DIFICIL = { colunas = 8, linhas = 6, max_cartas = 48 }, -- Quadras (4 cópias)
    EXTREMO = { colunas = 10, linhas = 6, max_cartas = 60 }, -- Combinações variáveis (o Tabuleiro define o mix)
}

-- Configurações de Pontuação
Config.PONTUACAO = {
    PONTOS_POR_MATCH_BASE = 100,
    PENALIDADE_ERRO = 50,
    PENALIDADE_DICA = 50,
    TEMPO_BONUS_FATOR = 10, -- Usado no modo cooperativo para calcular pontuação final
}

-- Configurações de Dicas
Config.DICAS = {
    MAX_INICIAIS = 3,
    COOLDOWN = 30, -- Segundos de espera após usar uma dica
    ACERTOS_CONSECUTIVOS_PARA_DICA = 2, -- Ganha dica a cada X acertos consecutivos
    TOTAL_ACERTOS_PARA_DICA = 5,       -- Ganha dica a cada X acertos totais
}

-- Configurações da IA (para AI_Player)
Config.IA = {
    CHANCE_MEMORIA_DIFICIL = 0.85, -- 85% de chance de lembrar no difícil
    MEMORIA_CURTO_PRAZO_FACIL = 1, -- Lembra apenas 1 carta
    MEMORIA_CURTO_PRAZO_MEDIO = 6, -- Lembra 6 cartas (últimas 3 jogadas)
}

-- Configurações de Cartas Especiais
Config.CARTAS_ESPECIAIS = {
    MAX_POR_PARTIDA = 3, -- Máximo de cartas especiais por jogo
    CHANCE = 0.1, -- 10% de chance de uma carta comum se tornar especial durante a criação do tabuleiro
    TIPOS = {"Revelacao", "Embaralhamento", "Congelamento"}, -- Tipos de poderes disponíveis
}

-- Tempos de Atraso no Jogo (para pausar entre jogadas, exibir dicas, etc.)
Config.TEMPOS = {
    PAUSA_APOS_CLIQUE = 0.8, -- Pausa em segundos após virar um grupo de cartas
    TEMPO_DICA_REVELADA = 2, -- Tempo em segundos que a carta da dica fica virada para cima
}

-- Nomes de exibição para Modos e Níveis (usados na UI e ranking)
Config.NOMES = {
    MODOS = {
        Competitivo = "Competitivo",
        Cooperativo = "Cooperativo",
        Solo = "Solo" -- Se você tiver um modo solo
    },
    NIVEIS = {
        Facil = "Fácil",
        Medio = "Médio",
        Dificil = "Difícil",
        Extremo = "Extremo"
    }
}


return Config