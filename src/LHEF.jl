module LHEF

using LightXML, LorentzVectors

export parse_lhe

struct EventHeader
    nup::UInt8          # Number of particles
    ldprup::UInt8       # Process type?
    xwgtup::Float64     # Event Wight
    scalup::Float64     # Scale
    αem::Float64        # AQEDUP
    αs::Float64         # AQCDUP
end

struct Particle
    particle::Int8
    status::Int8
    mothup::NTuple{2,UInt8}
    color::NTuple{2,UInt16}
    pμ::LorentzVector{Float64}
    m::Float64
    vtimup::Float64
    spinup::Float64
end

struct Event
    header::EventHeader
    data::Vector{Particle}
end

function parse_lhe(filename; format=nothing)
    if format === nothing
        # Format not declared, inferring from extension
        fparts = split(basename(filename), ".")
        format = if fparts[end] == "lhe"
            :lhe
        elseif fparts[end] == "gz" && fparts[end - 1] == "lhe"
            :lhegz
        end
    end

    lhefile = parse_file(filename)
    lhenode = root(lhefile)

    (name(lhenode) == "LesHouchesEvents") || error("Invalid root node")
    events = lhenode["event"]
    return [
        begin
            data = content(first(child_nodes(event)))
            lines = split(data, '\n'; keepempty=false)
            headerdata = split(lines[1], ' '; keepempty=false)
            header = EventHeader(
                parse(UInt8, headerdata[1]),
                parse(UInt8, headerdata[2]),
                parse(Float64, headerdata[3]),
                parse(Float64, headerdata[4]),
                parse(Float64, headerdata[5]),
                parse(Float64, headerdata[6]),
            )
            data = [
                begin
                    fields = split(line, ' '; keepempty=false)
                    p = Particle(
                        parse(Int8, fields[1]),
                        parse(Int8, fields[2]),
                        (parse(UInt8, fields[3]), parse(UInt8, fields[4])),
                        (parse(UInt16, fields[5]), parse(UInt16, fields[6])),
                        LorentzVector(
                            parse(Float64, fields[10]),
                            parse(Float64, fields[7]),
                            parse(Float64, fields[8]),
                            parse(Float64, fields[9]),
                        ),
                        parse(Float64, fields[11]),
                        parse(Float64, fields[12]),
                        parse(Float64, fields[13]),
                    )
                    p
                end for line in lines[2:end]
            ]
            Event(header, data)
        end for event in events
    ]
end

end # module
