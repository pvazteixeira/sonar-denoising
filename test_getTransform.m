xB = [1; 0; 0; 1];
yB = [0; 1; 0; 1];
zB = [0; 0; 1; 1];

%% 1 - +90 in yaw
clc
aTb = getTransform([0 1 0]' , deg2rad([90 0 0]));
min(aTb*xB - [0 2 0 1]' < eps*ones(4,1))
min(aTb*yB - [-1 1 0 1]' < eps*ones(4,1))
min(aTb*zB - [0 1 1 1]'  < eps*ones(4,1))

%% 2
clc
aTb = getTransform([0 1 0]' , deg2rad([0 0 -90]));
aTb*xB
aTb*yB
aTb*zB

%% 3
clc
aTb = getTransform([0 1 0]' , deg2rad([0 90 0]));
aTb*xB
aTb*yB
aTb*zB


%% 4
clc
aTb = getTransform([0 1 0]' , deg2rad([90 90 0]));

aTb*xB
aTb*yB
aTb*zB
