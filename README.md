sonar-sandbox
=============

A set of matlab scripts and functions to support research on SONAR modelling and data enhancement.

## general instructions

1. run buildjar.sh
2. open matlab
3. run addjars.m
4. run other stuff

## scripts
 - addjars.m - script to add the .jar files required for matlab to listen to lcm
 - beam_taper.m - beam pattern (taper) correction test
 - didson_enhancer.m - a script to listen to didson frames, enhance and republish
 - didson_lcm_to_mat.m - a script to convert didson data from lcm logs to .mat files
 - didson_listener.m - a script that listens to didson lcm messages
 - didson_skeleton.m - template for per-frame processing
 - didson_stats.m - misc computations on a per-frame basis
 - fls_listener.m - a script that listens to 3dfls lcm messages
 - psf_estimtion.m - point spread function estimation using blind deconvolution
 - simple_viewer.m - main development script; reads didson data from a .mat file (converted from lcm) and runs several enhancements/tests/...
 - test_deconvwnr.m - a script to test Wiener deconvolution using roughly-estimated PSFs.
 - transmission_loss.m - a script to evaluate different transmission loss models.

## functions
 - cpsf.m - a function to return a custom psf
 - enhance.m - a function to gather all sonar image enhancements (deconvolution, beam pattern correction, transmission loss)
 - polarToCart.m - a function to handle the conversion of sonar data from a polar to a cartesian frame

## dependencies:
	hauv_didson_t.lcm (can be found at https://svn.csail.mit.edu/marine/projects/3dfls/3dfls/lcmtypes/)
