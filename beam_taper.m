%%  

close all
k0 = 0.6; % my own, additional, correction factor
k1 =  -0.0089;
k2 = 0.8515;
k3 = -20.0994;

i = 0:95;

a = (k0)*(k1 * i.^2 + k2 * i + k3*ones(1,96));

s = 1/70; % this is the MuPerDB (image intensity over dB, eg. 255/(70dB) )
%a = -s*a + 0.5*ones(1,96); % original soundmetrics correction
a = -s*a;% why the 0.5???

figure;
plot(i,a)
title('Beam taper approximation')
xlabel('Beam index')
ylabel('Correction')

polar_frame = im2double(imread('data/frame.bmp'));
offset = repmat(a, [512, 1]);
enhanced_polar_frame = polar_frame+offset;
figure;
subplot(1,3,1)
imshow(polar_frame)
subplot(1,3,2)
imshow(offset)
subplot(1,3,3)
imshow(enhanced_polar_frame);

%{
    Original DIDSON code:

	int	i, iBeam;
	double	dA1 = -0.0089;
	double	dA2 = 0.8515;
	double	dA3 = -20.0994;
	double	dCF;

	dA1 *= (double)m_nBpcMaxCorrection/20.;
	dA2 *= (double)m_nBpcMaxCorrection/20.;
	dA3 *= (double)m_nBpcMaxCorrection/20.;

	for (i = 0 ; i < 96 ; i++)
	{
		iBeam = pDoc->m_Header.m_bHighResolution && !pDoc->m_bLongRange ? i : 2*i;
		dCF = dA1*(double)(iBeam*iBeam) + dA2*(double)iBeam + dA3;
		m_iBPCorrection[i] = (int)(-pDoc->m_fMuPerDb * dCF + 0.5);
	}

%}
