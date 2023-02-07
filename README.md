# LHEF.jl
[![Build Status](https://github.com/JuliaHEP/LHEF.jl/workflows/CI/badge.svg)](https://github.com/JuliaHEP/LHEF.jl/actions)

## Opening a LHE file

```julia
julia> using LHEF

julia> events = parse_lhe("./test/ft.lhe.gz"); # lazy generator

julia> event = first(events)
  Event header: (nparticles = 6, pid = 0, weight = 1.1829e-5, scale = 255.6536, aqed = 0.007546771, aqcd = 0.1112889)
  Event particles:
  idx|     id| status| mother1| mother2| color1| color2|             px|             py|             pz|              e|      m| lifetime|   spin
    0,     21,     -1,       0,       0,    502,    503,            0.0,            0.0,   1070.9531583,   1070.9531583,    0.0,      0.0,   -1.0
    1,     21,     -1,       0,       0,    501,    504,            0.0,            0.0,  -774.76002582,   774.76002582,    0.0,      0.0,    1.0
    2,      6,      1,       1,       2,    501,      0,   113.37785248,   114.16185862,  -41.887649846,   239.93966451,  173.0,      0.0,    1.0
    3,      6,      1,       1,       2,    502,      0,   34.597641987,  -272.46642769,  -245.76811815,   407.14360973,  173.0,      0.0,    1.0
    4,     -6,      1,       1,       2,      0,    503,   15.534573574,   182.89123966,    822.7134095,    860.5096645,  173.0,      0.0,   -1.0
    5,     -6,      1,       1,       2,      0,    504,  -163.51006804,  -24.586670591,  -238.86450899,   338.12024543,  173.0,      0.0,   -1.0
```

## LorentzVector and Physical quantity

If you need to compute physical quantities such as `mass`, consider using [LorentzVectorHEP.jl](https://github.com/JuliaHEP/LorentzVectorHEP.jl):
```julia
julia> using LorentzVectorHEP

julia> lhe_v4(p) = LorentzVector(p.e, p.px, p.py, p.pz)

julia> test_particle = event.particles[1]

julia> mass(lhe_v4(test_particle)) == test_particle.m # self-consistency test
```

## Columnar style

To facilitate columnar manipulations, there is an additional function which inserts consecutive event numbers into each
particle and concatenates particles across events.
```julia
julia> particles = flatparticles("./test/ft.lhe.gz");

julia> keys(particles[100])
(:eventnum, :idx, :id, :status, :mother1, :mother2, :color1, :color2, :px, :py, :pz, :e, :m, :lifetime, :spin)

julia> values(particles[100])
(1, 0, 21, -1, 0, 0, 502, 503, 0.0, 0.0, 1070.9531583, 1070.9531583, 0.0, 0.0, -1.0)

julia> using DataFrames

julia> DataFrame(particles)
270×15 DataFrame
 Row │ eventnum  idx    id     status  mother1  mother2  color1  color2  px          py         ⋯
     │ Int64     Int64  Int32  Int8    Int16    Int16    Int32   Int32   Float64     Float64    ⋯
─────┼───────────────────────────────────────────────────────────────────────────────────────────
   1 │        1      0     21      -1        0        0     502     503     0.0         0.0     ⋯
   2 │        1      1     21      -1        0        0     501     504     0.0         0.0
   3 │        1      2      6       1        1        2     501       0   113.378     114.162
   4 │        1      3      6       1        1        2     502       0    34.5976   -272.466
   5 │        1      4     -6       1        1        2       0     503    15.5346    182.891   ⋯
  ⋮  │    ⋮        ⋮      ⋮      ⋮        ⋮        ⋮       ⋮       ⋮         ⋮           ⋮      ⋱
 267 │       45      2      6       1        1        2     501       0    35.3736    -60.1114
 268 │       45      3      6       1        1        2     502       0  -406.333     127.811
 269 │       45      4     -6       1        1        2       0     503   372.086     -99.7773
 270 │       45      5     -6       1        1        2       0     504    -1.12621    32.0774  ⋯
                                                                   5 columns and 261 rows omitted
```
