local DataHora = {}
DataHora.__index = DataHora

-- Construtor
function DataHora:new(dia, mes, ano, hora, minuto, segundo)
    local obj = {
        dia = dia or os.date("*t").day,
        mes = mes or os.date("*t").month,
        ano = ano or os.date("*t").year,
        hora = hora or os.date("*t").hour,
        minuto = minuto or os.date("*t").min,
        segundo = segundo or os.date("*t").sec
    }
    return setmetatable(obj, self)
end

-- Atualiza para a data/hora atual
function DataHora:atualizar()
    local t = os.date("*t")
    self.dia = t.day
    self.mes = t.month
    self.ano = t.year
    self.hora = t.hour
    self.minuto = t.min
    self.segundo = t.sec
end

-- Retorna a data formatada
function DataHora:formatarData()
    return string.format("%02d/%02d/%04d", self.dia, self.mes, self.ano)
end

-- Retorna a hora formatada
function DataHora:formatarHora()
    return string.format("%02d:%02d:%02d", self.hora, self.minuto, self.segundo)
end

-- Retorna data e hora juntas
function DataHora:formatarCompleto()
    return self:formatarData() .. " " .. self:formatarHora()
end

return DataHora
