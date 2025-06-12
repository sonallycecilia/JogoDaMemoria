local Partida =  require("classes.partida")

local PartidaCompetitiva = {}
PartidaCompetitiva.__index = Partida

function PartidaCompetitiva:new(modoDeJogo, nivel)
    local obj = {}
    setmetatable(obj, PartidaCompetitiva)
    return Partida:new(modoDeJogo, nivel)
end

function PartidaCompetitiva:finalizou()
    local result = false
    if self.tabuleiro.cartasRestantes == 0 then
        self.partidaFinalizada = true
        result =  true
    end
    return result
end