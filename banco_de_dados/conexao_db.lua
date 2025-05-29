local luasql = require("luasql.mysql")

-- Configurações de conexão
local host = "localhost"
local user = "root"
local password = ""
local database_name = "meu_banco_de_dados_local"

local env = assert(luasql.mysql(), "Erro ao criar ambiente LuaSQL")
local conn

-- Conectar ao MySQL sem um banco de dados específico para criar um
-- Use uma string vazia ("") como sourcename, não nil.
-- O host é o quarto argumento, como indicado na extensão MySQL.
local success_no_db, err_no_db = pcall(function()
    conn = assert(env:connect("", user, password, host), "Erro ao conectar ao MySQL para criação de DB")
end)

if success_no_db then
    print("Conectado ao servidor MySQL. Tentando criar o banco de dados...")
    local cursor = assert(conn:execute("CREATE DATABASE IF NOT EXISTS " .. database_name), "Erro ao criar o banco de dados")
    print("Banco de dados '" .. database_name .. "' criado (ou já existia) com sucesso!")
    conn:close() -- Fecha a conexão inicial para criar o DB

    -- Agora, reconecte ao banco de dados específico
    local success_with_db, err_with_db = pcall(function()
        conn = assert(env:connect(database_name, user, password, host), "Erro ao conectar ao banco de dados específico")
    end)

    if success_with_db then
        print("Conectado ao banco de dados '" .. database_name .. "' com sucesso!")
        -- Seu código para operar no DB aqui
        -- Exemplo: Criar uma tabela
        local query = [[
            CREATE TABLE IF NOT EXISTS usuarios (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nome VARCHAR(255) NOT NULL,
                idade INT
            );
        ]]
        local cursor_table = assert(conn:execute(query), "Erro ao criar a tabela 'usuarios'")
        print("Tabela 'usuarios' criada (ou já existia) com sucesso!")

        conn:close()
        env:close()
    else
        print("Erro ao reconectar ao banco de dados após a criação: " .. tostring(err_with_db))
    end
else
    print("Erro fatal: Não foi possível conectar ao servidor MySQL para criar o banco de dados.")
    print("Detalhes do erro: " .. tostring(err_no_db))
end