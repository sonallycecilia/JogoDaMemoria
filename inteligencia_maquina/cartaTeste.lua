local ALTURA = 100
local LARGURA = 100
local NAO_ENCONTRADA = -1
local NAO_POSICIONADA = -1

CartaTeste = {
    VERSO = "midia/images/verso.png",
    
}
CartaTeste.__index = CartaTeste



function CartaTeste:new(id, caminhoImagemFrente)
    local novaCarta = {
        id = id,
        largura = LARGURA,
        altura = ALTURA,
        pathImagem = caminhoImagemFrente, --precisa ficar pois pegamos o caminho da imagem
        imagemFrente = caminhoImagemFrente,
        imagemVerso = "VERSO",
        revelada = false, -- se não for passado, assume false
        posX = NAO_POSICIONADA,
        posY = NAO_POSICIONADA,
        rodadaEncontrada = NAO_ENCONTRADA,
        probErro = 0;
    }
    setmetatable(novaCarta, CartaTeste) --permite o uso de :, ligando a metatable de cima
    return novaCarta
end

