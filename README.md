# LHEF

## Exampls

```julia
julia> using LHEF

julia> as = LHEF.parse_lhe("./test/ft.lhe");

julia> bs = LHEF.parse_lhe("./test/ft.lhe.gz");

julia> typeof(as)
Vector{LHEF.Event} (alias for Array{LHEF.Event, 1})

julia> typeof(as[1])
LHEF.Event

julia> typeof(as[1].data)
Vector{LHEF.Particle} (alias for Array{LHEF.Particle, 1})

julia> as[1].data[1]
LHEF.Particle(21, -1, (0x00, 0x00), (0x01f6, 0x01f7), LorentzVectors.LorentzVector{Float64}(1070.9531583, 0.0, 0.0, 1070.9531583), 0.0, 0.0, -1.0)
```
