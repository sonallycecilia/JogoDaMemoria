Array = {type = ""}
Array.__index = {}

function Array.soma(arr)
    local soma = 0
    for i = 1, #arr, 1 do
        soma = soma  + arr[i]
    end
    return soma
end