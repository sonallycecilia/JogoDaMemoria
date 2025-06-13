-- A API lua.mysql é sucetível a SQL injection, migrar para outro depois

local conn = require("banco_de_dados.conexao_db")

print(conn)

--criarRanking()

-- CREATE 
-- Utilizar string.format igual em C para "preparar" a declaracao
local function addRegistro(nome_jogador, data_inicio, hora_inicio, data_final, hora_final, pontuacao, dificuldade, modo)
    if conn ~= nil then
        local declaracao = [[
            INSERT INTO ranking
                (nome_jogador,
                data_inicio,
                hora_inicio,
                data_final,
                hora_final,
                pontuacao,
                dificuldade,
                modo)
            VALUES]].."('"..nome_jogador.."','"..data_inicio.."','"..hora_inicio.."','"..data_final.."','"..hora_final.."','"..pontuacao.."','"..dificuldade.."','"..modo.."');"

        local cursor = conn:execute(declaracao)
        
        if cursor ~= nil then
            print("linhas afetadas: "..cursor)
        end

        print("-\t-\t-\t-\t-\t-\n")

    end
end

-- READ registro
local function selectRegistro(numLinhas)
    local resultado
    numLinhas = numLinhas or 5
    -- Tratar o erro ao enviar uma linha fora dos registros
    if conn ~= nil then
        local declaracao = [[SELECT
                                nome_jogador,
                                data_inicio,
                                hora_inicio,
                                data_final,
                                hora_final,
                                TIME_FORMAT(
                                    TIMEDIFF(CONCAT(data_final, ' ', hora_final), CONCAT(data_inicio, ' ', hora_inicio)),
                                    '%H:%i:%s'
                                ) AS duracao,
                                pontuacao,
                                dificuldade,
                                modo
                            FROM
                                ranking    
                            ORDER BY pontuacao DESC
                            LIMIT ]]..numLinhas..";"

        resultado = {}
        
        local cursor = conn:execute(declaracao)
        if cursor ~= nil then
            

            local linha = cursor:fetch({}, "n")
            while linha do
                for i = 1, #linha, 1 do
                    table.insert(resultado, linha)
                    io.write(linha[i].."\t")
                end
                print()
                linha = cursor:fetch({}, "n")
            end
            print(cursor)
        end
    end

    return resultado
end

local function selectTodosRegistro()
    local resultado
    if conn ~= nil then
        local declaracao = [[SELECT
                                nome_jogador,
                                data_inicio,
                                hora_inicio,
                                data_final,
                                hora_final,
                                TIME_FORMAT(
                                    TIMEDIFF(CONCAT(data_final, ' ', hora_final), CONCAT(data_inicio, ' ', hora_inicio)),
                                    '%H:%i:%s'
                                ) AS duracao,
                                pontuacao,
                                dificuldade,
                                modo
                            FROM
                                ranking
                            ORDER BY pontuacao DESC;]]
        resultado = {}
        
        local cursor = conn:execute(declaracao)
        if cursor ~= nil then
            local linha = cursor:fetch({}, "n")
            while linha do
                for i = 1, #linha, 1 do
                    io.write(linha[i].."\t")
                end
                print()
                linha = cursor:fetch({}, "n")
            end
            print(cursor)
        end


    end
end

local function selectTodosRegistroPorModo(modo)
    local resultado
    if conn ~= nil then
        local declaracao = [[SELECT
                                nome_jogador,
                                data_inicio,
                                hora_inicio,
                                data_final,
                                hora_final,
                                TIME_FORMAT(
                                    TIMEDIFF(CONCAT(data_final, ' ', hora_final), CONCAT(data_inicio, ' ', hora_inicio)),
                                    '%H:%i:%s'
                                ) AS duracao,
                                pontuacao,
                                dificuldade,
                                modo
                            FROM
                                ranking
                            WHERE
                                modo = ']] .. modo .. [['
                            ORDER BY pontuacao DESC;]]
        resultado = {}
        
        local cursor = conn:execute(declaracao)
        if cursor ~= nil then
            local linha = cursor:fetch({}, "n")
            while linha do
                for i = 1, #linha, 1 do
                    io.write(linha[i].."\t")
                end
                print()
                linha = cursor:fetch({}, "n")
            end
            print(cursor)
        end
    end
end

local function selectRegistroPorModo(numLinhas, modo)
    local resultado
    numLinhas = numLinhas or 5
    if conn ~= nil then
        local declaracao = [[SELECT
                                nome_jogador,
                                data_inicio,
                                hora_inicio,
                                data_final,
                                hora_final,
                                TIME_FORMAT(
                                    TIMEDIFF(CONCAT(data_final, ' ', hora_final), CONCAT(data_inicio, ' ', hora_inicio)),
                                    '%H:%i:%s'
                                ) AS duracao,
                                pontuacao,
                                dificuldade,
                                modo
                            FROM
                                ranking     
                            WHERE
                                modo = ']] .. modo .. [['
                            ORDER BY pontuacao DESC
                            LIMIT ]]..numLinhas..";"

        resultado = {}
        
        local cursor = conn:execute(declaracao)
        if cursor ~= nil then
            local linha = cursor:fetch({}, "n")
            while linha do
                for i = 1, #linha, 1 do
                    table.insert(resultado, linha)
                    io.write(linha[i].."\t")
                end
                print()
                linha = cursor:fetch({}, "n")
            end
            print(cursor)
        end
    end

    return resultado
end

-- TODO: filtrar por dificuldade
-- TODO: filtrar por modoDeJogo

print("\nTop 5 geral\n")
selectRegistro(5) -- TOP 5

print("\nFiltro do modo Cooperativo\n")
selectRegistroPorModo(5,"cooperativo")

print("\nTop 5 do modo Solo\n")
selectRegistroPorModo(5, "solo")

print("\nTop 5 do modo Solo\n")
selectRegistroPorModo(5, "competitivo")
-- DELETE registro

-- UPDATE registro


