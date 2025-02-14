module LHEF

using EzXML
using StructArrays

export parse_lhe, flatparticles

Base.@kwdef struct Header
    nparticles::Int16
    pid::Int16
    weight::Float64
    scale::Float64
    aqed::Float64
    aqcd::Float64
end
Base.values(h::Header) = (h.nparticles, h.pid, h.weight, h.scale, h.aqed, h.aqcd)

Base.@kwdef struct Particle
    idx::Int
    id::Int32
    status::Int8
    mother1::Int16
    mother2::Int16
    color1::Int32
    color2::Int32
    px::Float64
    py::Float64
    pz::Float64
    e::Float64
    m::Float64
    lifetime::Float64
    spin::Float64
end
Base.values(h::Particle) = (h.idx, h.id, h.status, h.mother1, h.mother2, h.color1, h.color2, h.px, h.py, h.pz, h.e, h.m, h.lifetime, h.spin)

Base.@kwdef struct Event
    header::Header
    particles::Vector{Particle}
    weights::Vector{Float64}
end

function Base.show(io::IO, evt::Event)
    pads = (3, 6, 6, 7, 7, 6, 6, 11, 11, 11, 11, 10, 7, 6)

    println(io, "  Event header: ", evt.header)
    parts = evt.particles
    println(io, "  Event particles:")
    print(io, "  ")
    ks = lpad.(propertynames(first(parts)), pads)
    print(io, join(ks, "| ")...)
    println(io)

    for p in parts
        vals = [x isa Integer ? x : round(x; sigdigits=6) for x in values(p)]
        ps = lpad.(vals, pads)
        print(io, "  ")
        print(io, join(ps, ", ")...)
        println(io)
    end

    println(io, "  Event weights: ", evt.weights)
end

function parse_event(event, wgts)
    lines = split(event, '\n'; keepempty=false)
    filter!(!startswith('#'), lines)
    headerdata = split(lines[1], ' '; keepempty=false)
    header = Header(;
        nparticles=parse(Int16, headerdata[1]), # Number of particles
        pid=parse(Int16, headerdata[2]),        # Process type
        weight=parse(Float64, headerdata[3]),   # Event weight
        scale=parse(Float64, headerdata[4]),    # Scale
        aqed=parse(Float64, headerdata[5]),     # AQEDUP
        aqcd=parse(Float64, headerdata[6]),     # AQCDUP
    )
    particles = [
        begin
            fields = split(line, ' '; keepempty=false)
            p = Particle(;
                idx=idx,
                id=parse(Int32, fields[1]),
                status=parse(Int8, fields[2]),
                mother1=parse(Int16, fields[3]),
                mother2=parse(Int16, fields[4]),
                color1=parse(Int32, fields[5]),
                color2=parse(Int32, fields[6]),
                px=parse(Float64, fields[7]),
                py=parse(Float64, fields[8]),
                pz=parse(Float64, fields[9]),
                e=parse(Float64, fields[10]),
                m=parse(Float64, fields[11]),
                lifetime=parse(Float64, fields[12]),
                spin=parse(Float64, fields[13]),
            )
            p
        end for (idx, line) in enumerate(lines[2:(2 + header.nparticles - 1)])
    ]
    return Event(header, particles, wgts)
end

function isevent(reader)
    (reader.name == "event") &&
    (reader.type == EzXML.READER_ELEMENT)
end
function collect_wgts(reader)
    res = Float64[]
    while !isevent(reader)
        isnothing(iterate(reader)) && break
        if reader.name == "wgt" && reader.type == EzXML.READER_ELEMENT
            push!(res, parse(Float64, reader.content))
        end
    end
    return res
end

function parse_lhe(filename)
    res = Event[]
    open(EzXML.StreamReader, filename) do reader
        local particles_str, wgts
        while true
            if isevent(reader)
                particles_str = reader.content
                isnothing(iterate(reader)) && break
                # if the next element is not "event", we look for weights
                # otherwise, we assume there are no weights
                wgts = if !isevent(reader)
                    collect_wgts(reader)
                else
                    [1.0]
                end
                push!(res, parse_event(particles_str, wgts))
            else
                isnothing(iterate(reader)) && break
            end
        end
    end
    return res
end

function flatparticles(filename)
    res = NamedTuple{fieldnames(Particle)}([T[] for T in fieldtypes(Particle)])
    res = merge(res, (; eventnum=Int[]))
    for (i, evt) in enumerate(parse_lhe(filename)), p in evt.particles
        push!(res[:eventnum], i)
        for n in fieldnames(Particle)
            push!(res[n], getfield(p, n))
        end
    end
    return StructArray(res)
end

end # module
