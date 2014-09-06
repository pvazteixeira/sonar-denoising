function [ aTb ] = getTransform( b_position_a, attitude )
%UNTITLED2 Get homogenous transform matrix from b to a
%   b_position_a - position of the b frame's origin in the a frame
%   attitude     - rotation from a frame to b frame, in ypr sequence

    aRb= angle2dcm(attitude(1),attitude(2),attitude(3),'ZYX');
    
    aTb = [ aRb',        b_position_a;
            zeros(1,3), 1];
end

% convention: 
% - aTb transforms from 'b' to 'a' (homogenous transformation
% matrix)
% - aRb is the rotation from 'b' to 'a'
% - r_a is a pose in the 'a' reference frame
% - r_Ob_a is the position of the origin of the 'b' frame in
% the 'a' frame
% - homogeneous transform matrices are thus:
%   [ aRb        r_Ob_a
%     zeros(3,1) 1]
%