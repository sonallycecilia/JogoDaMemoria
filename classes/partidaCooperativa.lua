local Partida =  require("classes.partida")

local PartidaCooperativa = {}
PartidaCooperativa.__index = Partida

function PartidaCooperativa:new(modoDeJogo, nivel)
    local obj = {}
    setmetatable(obj, PartidaCooperativa)
    return Partida:new(modoDeJogo, nivel)
end

function PartidaCooperativa:finalizou()
    local result = false
    if self.tempoRestante <= 0 or self.tabuleiro.cartasRestantes == 0 then
        self.partidaFinalizada = true
        result =  true
    end
    return result
end