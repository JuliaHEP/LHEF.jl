# LHEF

## Example

```julia
julia> using LHEF

julia> events = parse_lhe("./test/ft.lhe.gz"); # lazy generator

julia> event = first(events)

  Event header: (nparticles = 6, pid = 0, weight = 1.1829e-5, scale = 214.5584, aqed = 0.007546771, aqcd = 0.1139351)
  Event particles (:idx, :id, :status, :mother1, :mother2, :color1, :color2, :px, :py, :pz, :e, :m, :lifetime, :spin):
    (0, 21, -1, 0, 0, 502, 503, 0.0, 0.0, 515.31921514, 515.31921514, 0.0, 0.0, -1.0)
    (1, 21, -1, 0, 0, 503, 504, 0.0, 0.0, -649.98283734, 649.98283734, 0.0, 0.0, -1.0)
    (2, 6, 1, 1, 2, 501, 0, -130.58110551, 95.902583415, -221.13924459, 324.16091084, 173.0, 0.0, -1.0)
    (3, 6, 1, 1, 2, 502, 0, 96.850960221, -26.621733185, 300.72483123, 361.18312432, 173.0, 0.0, -1.0)
    (4, -6, 1, 1, 2, 0, 501, 125.43365625, -19.928902577, -51.749377613, 220.76630486, 173.0, 0.0, 1.0)
    (5, -6, 1, 1, 2, 0, 504, -91.703510957, -49.351947654, -162.49983123, 259.19171246, 173.0, 0.0, -1.0)

julia> event.particles[1].id
21

```

To facilitate columnar manipulations, there is an additional function which inserts consecutive event numbers into each
particle and concatenates particles across events.
```julia
julia> particles = flatparticles("./test/ft.lhe.gz");

julia> keys(particle[100])
(:eventnum, :idx, :id, :status, :mother1, :mother2, :color1, :color2, :px, :py, :pz, :e, :m, :lifetime, :spin)

julia> values(particle[100])
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
