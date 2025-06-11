local luasql = require("luasql.mysql")
local env = luasql.mysql()
local conn

local host = "localhost"
local usuario = "luauser"
local senha = ""
local nomeDatabase = "sistema_pontuacao"
local porta = 3306
local caminhoArqSql = "banco_de_dados\\conexao_db.lua"

local function conexao_database()
    return pcall(function() conn = env:connect(nomeDatabase, usuario, senha, host, porta) end)
end


local temConexao, err = conexao_database()

if (!temConexao) then
    print("O Banco de Dados "..nomeDatabase.." nao existe(ainda)")
    local commando = string.format('mysql -h %s -u %s -p%s < "%s"', host, usuario, senha, caminhoArqSql)
end