module LHEF

using XML, CodecZlib, StructArrays

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
    wgts::Vector{Float64}
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

    println(io, "  Event weights: ", evt.wgts)
end

function parse_event(event, wgt)
    lines = split(event, '\n'; keepempty=false)
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
                idx=idx - 1, # zero-based to match `mother1`, `mother2`
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
    wgts = if getfield(wgt[1], :tag) == "wgt"
        [parse(Float64, w[1]) for w in children(wgt)]
    else
        [1.0]
    end
    return Event(header, particles,  wgts)
end

function parse_lhe(filename)
    root = if endswith(filename, "gz")
        io = IOBuffer(transcode(GzipDecompressor, read(filename)))
        Document(XML.XMLTokenIterator(io)).root
    else
        XML.Document(filename).root
    end

    first_child = children(root)[1]
    if first_child isa XML.Element && getfield(first_child, :tag) == "file"
        root = first_child
    end
    return [parse_event(ele[1], ele[2]) for ele in children(root) if ele isa XML.Element && getfield(ele, :tag) == "event"]
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
