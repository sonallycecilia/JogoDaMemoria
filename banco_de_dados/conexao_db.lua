local luasql = require("luasql.mysql")
local env = luasql.mysql()
local conn

local host = "localhost"
local usuario = "luauser"
local senha = ""
local nomeDatabase = "sistema_pontuacao"
local porta = 3306

local function conexao_database()
    return pcall(function() 
        conn = env:connect(nomeDatabase, usuario, senha, host, porta) end)
end


local status = conexao_database()

if status  then
    print("Conexao a "..nomeDatabase.." bem sucedida!")
else
    print("Conexao a "..nomeDatabase.." falhou!")
end

function CriarRanking()
    local declaracao = [[
        CREATE TABLE IF NOT EXISTS ranking (
            nome_jogador VARCHAR(50) NOT NULL,
            data_inicio DATE NOT NULL,
            hora_inicio VARCHAR(8) NOT NULL,
            data_final DATE NOT NULL,
            hora_final VARCHAR(8) NOT NULL,
            duracao VARCHAR(8) NOT NULL,
            pontuacao INT NOT NULL,
            dificuldade VARCHAR(20) NOT NULL,
            modo VARCHAR(20) NOT NULL,
            PRIMARY KEY (nome_jogador, data_inicio, hora_inicio)
            )
    ]]
    local cursor = assert(conn:execute(declaracao), "Erro ao criar a tabela 'Ranking'")

    print("Tabela 'Ranking' criada (ou já existia) com sucesso!")
    if cursor ~= nil then
        print("Linhas afetadas: "..cursor)
    end

end

return conn