module LHEF

using LightXML, LorentzVectors

struct EventHeader
    nup::UInt8          # Number of particles
    ldprup::UInt8       # Process type?
    xwgtup::Float64     # Event Wight
    scalup::Float64     # Scale
    αem::Float64        # AQEDUP
    αs::Float64         # AQCDUP
end

struct FourVector
    data::NTuple{4,Float64}
end
getindex(x::FourVector,i) = x.data[i+1]

# Mostly negative convention
dot(x::FourVector,y::FourVector) = (x[0]*y[0]-x[1]*y[1]-x[2]*y[2]-x[3]*y[3])

struct Particle
    particle::Int8
    status::Int8
    mothup::NTuple{2,UInt8}
    color::NTuple{2,UInt16}
    pμ::FourVector
    m::Float64
    vtimup::Float64
    spinup::Float64
end

struct Event
    header::EventHeader
    data::Vector{Particle}
end
 
function parse_lhe(filename; format = nothing)
    if format === nothing
        # Format not declared, inferring from extension
        fparts = split(basename(filename),".")
        if fparts[end] == "lhe"
            format = :lhe
        elseif fparts[end] == "gz" && fparts[end-1] == "lhe"
            format = :lhegz
        end
    end

    @assert format == :lhe
    lhefile = parse_file(filename)
    lhenode = root(lhefile)

    (name(lhenode) == "LesHouchesEvents") || error("Invalid root node")
    (attributes_dict(lhenode)["version"] == "3.0") || error("Unsupported Version")

    events = get_elements_by_tagname(lhenode,"event")

    [begin
        data = [begin
                    1
        end for line in lines[2:end]]
        Event(header,data)
    end for event in events]
end

# package code goes here

end # module
