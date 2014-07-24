function [ PSF ] = cpsf( beam, bin)
%CPSF Generate custom PSF for the DIDSON
%   "The DIDSON has 12 active channels. Assuming the DIDSON-Std at HF, 
%   using 96 beams, this means that it takes 8 ping cycles (transmitting on
%   and receiving from 12 transducers for each ping cycle) to build a 
%   single complete frame." (from Sound Metrics Support)
%
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu

  % beam pattern approximation, in dB
  %{
  beam = [18,18,18,18,18,18,18,18,24,18,18,18,...
          18,18,18,18,24,18,18,18,18,18,18,18,...
          27,18,18,18,18,18,18,18,32,18,18,18,...
          18,18,18,18,40,18,18,18,28,18,39,18,...
          70,18,39,18,28,18,18,18,40,18,18,18,...
          18,18,18,18,32,18,18,18,18,18,18,18,...
          27,18,18,18,18,18,18,18,24,18,18,18,...
          18,18,18,18,24,18,18,18,18,18,18,18];
  beam = (1/sum(beam))*beam;
  %}

  beam = zeros(1,96);
  beam(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[ 24 24 24 27 32 40 70 40 32 27 24 24];
  PSF = (1/sum(sum(beam)))*beam;
end
