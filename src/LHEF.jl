module LHEF

using EzXML, LorentzVectors

export parse_lhe

function parse_event(event)
    lines = split(event, '\n'; keepempty=false)
    headerdata = split(lines[1], ' '; keepempty=false)
    header = (;
        nup=parse(UInt8, headerdata[1]),       # Number of particles
        ldprup=parse(UInt8, headerdata[2]),    # Process type
        xwgtup=parse(Float64, headerdata[3]),  # Event weight
        xscalup=parse(Float64, headerdata[4]), # Scale
        αem=parse(Float64, headerdata[5]),     # AQEDUP
        αs=parse(Float64, headerdata[6]),      # AQCDUP
    )
    particles = [
        begin
            fields = split(line, ' '; keepempty=false)
            p = (;
                particle=parse(Int32, fields[1]),
                status=parse(Int8, fields[2]),
                mothup=(parse(UInt8, fields[3]), parse(UInt8, fields[4])),
                color=(parse(UInt16, fields[5]), parse(UInt16, fields[6])),
                p4=LorentzVector(
                    parse(Float64, fields[10]),
                    parse(Float64, fields[7]),
                    parse(Float64, fields[8]),
                    parse(Float64, fields[9]),
                ),
                m=parse(Float64, fields[11]),
                vtimup=parse(Float64, fields[12]),
                spinup=parse(Float64, fields[13]),
            )
            p
        end for line in lines[2:2+header.nup-1]
    ]
    return (; header=header, particles=particles)
end

function parse_lhe(filename)
    reader = open(EzXML.StreamReader, filename)
    f(item) = (item != nothing) && (reader.name == "event") && (reader.type == EzXML.READER_ELEMENT)
    return (parse_event(reader.content) for _ in Iterators.filter(f, reader))
end

end # module
