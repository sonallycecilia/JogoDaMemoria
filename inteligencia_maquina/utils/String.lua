String = {}
String.__index = String

--Retorna uma string com a concatenação de len * char
function String.new(char, len) 
    local result = ""
    for i = 1, len, 1 do
        result = result..char
    end
    return result
end 
    