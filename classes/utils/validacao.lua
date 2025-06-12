-- Lembrete pro futuro: Criar uma classe Objet com métodos gerais para qualquer tabela

--[[ Nota: Em alguns casos fazer esse tipo de vericação traz redundancia ao método, 
porém em outros evita if aninhados e torna a condição do if mais clara. Portanto, para trazer consistencia ao código, 
todos os tratamentos utilização esse método ]]--

-- Retorna true se o elemento é nil ou false, retorna false caso contrário  
function ehNil(elemento)
    local ehNil = true
    if elemento then
        ehNil = false
    end

    return ehNil
end
