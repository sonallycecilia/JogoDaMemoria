local Config = {}

-- Configurações de janela (MANTIDAS)
Config.janela = {
    LARGURA_TELA = love.graphics.getWidth(),
    ALTURA_TELA = love.graphics.getHeight(),
    IMAGEM_TELA_INICIAL = "midia/images/telaInicial.png",
    IMAGEM_TELA_PARTIDA = "midia/images/telaPartida.jpg",
}

Config.scaleX = 0.5
Config.scaleY = 0.5
Config.defaultErrorImage = "assets/erro.png"

-- Configurações de botões (MANTIDAS)
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
        },
        menuSelecaoNivel = {
            facil = "midia/botoes/niveisDeJogo/facil.png",
            medio = "midia/botoes/niveisDeJogo/medio.png",
            dificil = "midia/botoes/niveisDeJogo/dificil.png",
            extremo = "midia/botoes/niveisDeJogo/extremo.png",
            voltar = "midia/botoes/menuJogo/voltar.png"
        }
    }
}

-- Deck de cartas (MANTIDO - suas imagens específicas)
Config.deck = {
    "midia/images/cartas/fada.png",
    "midia/images/cartas/naly.png",
    "midia/images/cartas/draenei.png",
    "midia/images/cartas/thales.png",
    "midia/images/cartas/lucy.png",
    "midia/images/cartas/fury.png",
    "midia/images/cartas/fada.png",
    "midia/images/cartas/naly.png",
    "midia/images/cartas/draenei.png",
    "midia/images/cartas/thales.png",
    "midia/images/cartas/lucy.png",
    "midia/images/cartas/fury.png",
}

-- Frames (MANTIDOS)
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

-- ===== CONFIGURAÇÕES NOVAS PARA MODO COOPERATIVO =====

-- Configurações específicas do modo cooperativo (NOVAS)
Config.cooperativo = {
    facil = {
        tempo = 180,           -- 3 minutos
        nivel = 1,             -- Tabuleiro 5x5 (24 cartas)
        inteligenciaIA = 0.85, -- 85% chance da IA usar memória
        intervaloPensamento = 1.5, -- IA "pensa" por 1.5 segundos
        multiplicadorMaximo = 5.0, -- Multiplicador máximo de sequência
        incrementoMultiplicador = 0.5, -- Quanto aumenta por sequência
        descricao = "Trabalhem juntos! IA inteligente, tempo generoso"
    },
    medio = {
        tempo = 150,           -- 2.5 minutos  
        nivel = 2,             -- Tabuleiro 6x6 (36 cartas)
        inteligenciaIA = 0.75, -- 75% chance da IA usar memória
        intervaloPensamento = 1.2,
        multiplicadorMaximo = 4.0,
        incrementoMultiplicador = 0.4,
        descricao = "Mais cartas, menos tempo, IA um pouco menos precisa"
    },
    dificil = {
        tempo = 120,           -- 2 minutos
        nivel = 3,             -- Tabuleiro 7x7 (48 cartas)  
        inteligenciaIA = 0.65, -- 65% chance da IA usar memória
        intervaloPensamento = 1.0,
        multiplicadorMaximo = 3.5,
        incrementoMultiplicador = 0.3,
        descricao = "Desafio real! Muitas cartas, pouco tempo"
    },
    extremo = {
        tempo = 90,            -- 1.5 minutos
        nivel = 4,             -- Tabuleiro 7x7 com mais cartas
        inteligenciaIA = 0.55, -- 55% chance da IA usar memória
        intervaloPensamento = 0.8,
        multiplicadorMaximo = 3.0,
        incrementoMultiplicador = 0.25,
        descricao = "Para os mestres! Velocidade máxima exigida"
    }
}

-- Configurações de pontuação (NOVAS)
Config.pontuacao = {
    parBase = 100,              -- Pontos por par encontrado
    bonusTempoPorSegundo = 10,  -- Pontos por segundo restante
    penalidade = {
        tentativaErrada = 0     -- Sem penalidade no cooperativo
    }
}

-- Configurações visuais específicas (NOVAS - complementam as existentes)
Config.visual = {
    espacamento = 10,
    corFundo = {0.1, 0.1, 0.2},
    corTexto = {1, 1, 1},
    corSucesso = {0.2, 0.8, 0.2},
    corAlerta = {1, 1, 0},
    corErro = {0.8, 0.2, 0.2},
    corIA = {0.2, 0.8, 1}
}

-- Mensagens do jogo (NOVAS)
Config.mensagens = {
    cooperativo = {
        inicio = "Modo Cooperativo ativado! Trabalhem juntos para encontrar todos os pares!",
        parEncontrado = "Excelente! Par encontrado!",
        sequencia = "Incrível! %d pares consecutivos! Multiplicador: %.1fx",
        iaAcertou = "Sua parceira IA encontrou um par! Continuem!",
        iaErrou = "A IA tentou ajudar, mas não conseguiu. Sua vez!",
        vitoria = "PARABÉNS! Vocês são uma equipe fantástica!",
        derrota = "O tempo acabou! Mas foi uma boa tentativa em equipe!",
        tempoRestante = "Cuidado! Apenas %d segundos restantes!"
    }
}

-- ===== FUNÇÕES HELPER (NOVAS) =====

-- Função helper para obter configurações do cooperativo
function Config.getCooperativoConfig(dificuldade)
    local configs = {
        [1] = Config.cooperativo.facil,
        [2] = Config.cooperativo.medio, 
        [3] = Config.cooperativo.dificil,
        [4] = Config.cooperativo.extremo
    }
    
    return configs[dificuldade] or Config.cooperativo.facil
end

-- Função para calcular layout do tabuleiro baseado no nível
function Config.getTabuleiroDimensoes(nivel)
    local dimensoes = {
        [1] = {linhas = 5, colunas = 5, totalCartas = 24}, -- 12 pares
        [2] = {linhas = 6, colunas = 6, totalCartas = 36}, -- 18 pares  
        [3] = {linhas = 7, colunas = 7, totalCartas = 48}, -- 24 pares
        [4] = {linhas = 7, colunas = 7, totalCartas = 48}  -- 24 pares (extremo igual ao difícil)
    }
    
    return dimensoes[nivel] or dimensoes[1]
end

-- Função para validar se o deck tem cartas suficientes
function Config.validarDeck(nivel)
    local dimensoes = Config.getTabuleiroDimensoes(nivel)
    local paresNecessarios = math.ceil(dimensoes.totalCartas / (nivel + 1))
    
    if #Config.deck < paresNecessarios then
        print(string.format("AVISO: Deck tem apenas %d cartas, mas nível %d precisa de %d", 
              #Config.deck, nivel, paresNecessarios))
        return false
    end
    
    return true
end

return Config