-- A API lua.mysql é sucetível a SQL injection, migrar para o SQLite posteriormente

local conn = require("banco_de_dados.conexao_db")

print(conn)

--criarRanking()

-- CREATE 
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

-- TODO: filtrar por dificuldade
-- TODO: filtrar por modoDeJogo

selectTodosRegistro()
print("\n\n")
selectRegistro() -- TOP 5

-- DELETE registro

-- UPDATE registro


