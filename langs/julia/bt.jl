module bt

export insert

type Node{T}
    left::Nullable{Node{T}}
    right::Nullable{Node{T}}
    value::T
end

function insert{T}( value::T )
end

end

