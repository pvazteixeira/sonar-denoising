%%  

close all

k1 =  -0.0089;
k2 = 0.8515;
k3 = -20.0994;

i = 0:95;

a = k1 * i.^2 + k2 * i + k3*ones(1,96);

s = 1; % this is the MuPerDB (image intensity over dB, eg. 255/(70dB) )
a = -s*a + 0.5*ones(1,96);

plot(i,a)
title('Beam taper approximation')
xlabel('Beam index')
ylabel('Correction')

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
