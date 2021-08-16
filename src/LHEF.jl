module LHEF

using EzXML, LorentzVectors

export parse_lhe

function parse_lhe(filename; format=nothing)
    events = []
    reader = open(EzXML.StreamReader, filename)
    while (item = iterate(reader)) != nothing
        (reader.type != EzXML.READER_ELEMENT) && continue
        (reader.name != "event") && continue

        lines = split(reader.content, '\n'; keepempty=false)
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
        # Right now this is not lazy
        # figure out how to do `yield blah` in julia
        push!(events, (; header=header, particles=particles))
   end
   return events
end

end # module
