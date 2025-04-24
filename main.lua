local carta = require("models.carta")

-- Codigo para debugar, favor, não excluir!! 
if os.getenv "LOCAL_LUA_DEBUGGER_VSCODE" == "1" then
    local lldebugger = require "lldebugger"
    lldebugger.start()
    local run = love.run
    function love.run(...)
        local f = lldebugger.call(run, false, ...)
        return function(...) return lldebugger.call(f, false, ...) end
    end
end


local minhaCarta = carta.novo(1, "images/cartas/lua.png", "images/verso.png")

function love.load()
    minhaCarta.x = 100
    minhaCarta.y = 100
end

function love.mousepressed(x, y, button, istouch, presses)
    if minhaCarta:clicada(x, y) then
        minhaCarta:alternar()
    end
end

function love.draw()
    minhaCarta:draw()
end
