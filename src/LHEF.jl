module LHEF

using EzXML

export parse_lhe, flatparticles

struct Event
    header
    particles
end

function Base.show(io::IO, evt::Event)
    println(io)
    println(io, "  Event header: ", evt.header)
    println(io, "  Event particles:")
    for p in evt.particles
        println(io, "    ", p)
    end
end

function parse_event(event)
    lines = split(event, '\n'; keepempty=false)
    headerdata = split(lines[1], ' '; keepempty=false)
    header = (;
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
            p = (;
                idx=idx-1, # zero-based to match `mother1`, `mother2`
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
        end for (idx,line) in enumerate(lines[2:2+header.nparticles-1])
    ]
    return Event(header, particles)
end

function parse_lhe(filename)
    reader = open(EzXML.StreamReader, filename)
    f(item) = (item != nothing) && (reader.name == "event") && (reader.type == EzXML.READER_ELEMENT)
    return (parse_event(reader.content) for _ in Iterators.filter(f, reader))
end

function flatparticles(filename)
    vcat([[(;eventnum=ievt, p...) for p in evt.particles]
          for (ievt,evt) in enumerate(parse_lhe(filename))]...)
end

end # module
