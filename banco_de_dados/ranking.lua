-- A API lua.mysql é sucetível a SQL injection, migrar para o SQLite posteriormente

local conn = require("banco_de_dados.conexao_db")

print(conn)

criarRanking()

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

--
local function selectRegistro(primeiraLinha, numLinha)
    -- Tratar o erro ao enviar uma linha fora dos registros
    if conn ~= nil then
        local declaracao = "SELECT * FROM ranking LIMIT "..primeiraLinha..","..numLinha..";"
        local resultado = {}
        
        local cursor = conn:execute(declaracao)
        if cursor ~= nil then
            

            local linha = cursor:fetch({}, "n")
            while linha do
                for i = 1, #linha, 1 do
                    table.insert()
                end
                print()
                linha = cursor:fetch({}, "n")
            end
            print(cursor)
        end

        

    end
end

local function selectAllRegistro()
    if conn ~= nil then
        local declaracao = "SELECT * FROM ranking;"
        local resultado
        
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

selectAllRegistro()


-- DELETE registro

-- UPDATE registro


