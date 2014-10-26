function [ b_position_a, attitude ] = getPose( transform )
  b_position_a = transform (1:3,4);

  [y,p,r] = dcm2angle(transform(1:3,1:3)','ZYX');
  attitude = [y;p;r];
end