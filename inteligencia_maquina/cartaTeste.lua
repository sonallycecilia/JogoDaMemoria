local ALTURA = 100
local LARGURA = 100
local NAO_ENCONTRADA = -1
local NAO_POSICIONADA = -1

CartaTeste = {
    id = 0,
    VERSO = "midia/images/verso.png",
    largura = LARGURA,
    altura = ALTURA,
    imagemVerso = "VERSO",
    revelada = false, -- se não for passado, assume false
    posX = NAO_POSICIONADA,
    posY = NAO_POSICIONADA,
    rodadaEncontrada = NAO_ENCONTRADA,
    probErro = 0;
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
        probErro = 0,
    }
    setmetatable(novaCarta, CartaTeste) 
    return novaCarta
end

function CartaTeste:imagemExibida()
    local img
    if self.revelada then
        img = self.imagemFrente
    else
        img = self.imagemVerso
    end

    return img
end

function CartaTeste:virar()
    self.revelada = not self.revelada
end

function CartaTeste:equals(carta)
    local result = false
    if self.id == carta.id then
        result = true
    end
    return result 
end

