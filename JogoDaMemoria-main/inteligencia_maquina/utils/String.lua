String = {}
String.__index = String

--Retorna uma string com a concatenação de len * char
function String.new(char, len) 
    if len < 0 then
        len = 0
    end
    local result = ""
    for i = 1, len, 1 do
        result = result..char
    end
    return result
end 
    