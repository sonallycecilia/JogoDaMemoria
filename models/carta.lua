local carta = {}

-- CONSTRUTOR
function carta.novo(_id, _imagem)
    return{
        id = _id,
        imagem = _imagem,
        revelada = false
    }
end

-- METODOS
function carta.revelar()
    return {
        revelada = false
    }
end

function carta.esconder()
    return{
        revelada = false
    }
end

