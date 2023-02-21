using LHEF
using Test

const SAMPLES_DIR = joinpath(@__DIR__, "")

@testset "laziness" begin
    lazyevents = parse_lhe(joinpath(SAMPLES_DIR, "ft.lhe"))
    events = collect(lazyevents)
    @test events isa Vector
    @test length(events) == 45
end

@testset "parsing" begin
    events = parse_lhe(joinpath(SAMPLES_DIR, "ft.lhe")) |> collect
    event = events[1]
    particles = event.particles
    header = event.header
    @test values(header) == (6, 0, 0.1182900E-04, 0.2556536E+03, 0.7546771E-02, 0.1112889E+00)
    @test length(particles) == 6
    @test values(particles[1]) == (0, 21, -1, 0, 0, 502, 503, 0.00000000000E+00 , 0.00000000000E+00 , 0.10709531583E+04 , 0.10709531583E+04, 0.00000000000E+00, 0., -1.)
    @test values(particles[2]) == (1, 21, -1, 0, 0, 501, 504, 0.00000000000E+00 , 0.00000000000E+00 , -0.77476002582E+03, 0.77476002582E+03, 0.00000000000E+00, 0., 1.)
    @test values(particles[3]) == (2, 6 , 1 , 1, 2, 501, 0  , 0.11337785248E+03 , 0.11416185862E+03 , -0.41887649846E+02, 0.23993966451E+03, 0.17300000000E+03, 0., 1.)
    @test values(particles[4]) == (3, 6 , 1 , 1, 2, 502, 0  , 0.34597641987E+02 , -0.27246642769E+03,-0.24576811815E+03 , 0.40714360973E+03, 0.17300000000E+03, 0., 1.)
    @test values(particles[5]) == (4, -6, 1 , 1, 2, 0  , 503, 0.15534573574E+02 , 0.18289123966E+03 , 0.82271340950E+03 , 0.86050966450E+03, 0.17300000000E+03, 0., -1.)
    @test values(particles[6]) == (5, -6, 1 , 1, 2, 0  , 504, -0.16351006804E+03,-0.24586670591E+02 ,-0.23886450899E+03 , 0.33812024543E+03, 0.17300000000E+03, 0., -1.)
end

@testset "gzip" begin
    e1 = parse_lhe(joinpath(SAMPLES_DIR, "ft.lhe")) |> collect
    e2 = parse_lhe(joinpath(SAMPLES_DIR, "ft.lhe.gz")) |> collect
    @test all([e1[i].particles == e2[i].particles for i in 1:length(e1)])
end

@testset "flattened particles" begin
    particles = flatparticles(joinpath(SAMPLES_DIR, "ft.lhe.gz"))
    @test length(particles) == 270
    @test maximum(p.eventnum for p in particles) == 45
end
