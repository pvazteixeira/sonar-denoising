function [ beam, bin ] = toBeamBin( x, y )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    global n_beams beam_width n_bins bin_width min_range;

    n_beams = 96;
    beam_width = deg2rad(0.3);
    beam = n_beams/2 - floor(atan2(y, x)/beam_width);
    bin = floor((sqrt( x*x + y*y) - min_range)/bin_width);
    
     if ( beam < 0 || beam >= n_beams || bin < 0 || bin >= n_bins)
         error('failed conversion!');
     end
   
end

 inline int toBeamBin(const float& x, const float& y, int& beam, int &bin) const
    {
      // float alpha = atan2(y, x);
      // float range = sqrt( x*x + y*y);

      // ASSUMPTION: beam 0 = 14.4deg
      beam = 
      

      if ( beam < 0 || beam >= m_n_beams || bin < 0 || bin >= m_n_bins)
      {
        beam = bin = -1;
        return(1);  // failure
      }
      else
      {
        return(0);  // success
      }
    };