%% Initialize
% These first sections are to generate signals that simulate the diode
% signals. We also assume that the LED signal has been stored and is
% simulated byt the ref signal.
% Set sample period
sp = 0.001;
sr = 1/sp; % Calculate sample rate
% Set reference frequency
f = 223; % Must be less than sr/2
% Generate time array
t = 0:sp:100;
% Generate reference square wave using square
ref = 0.5*(square(2*pi*f*t)+1);
plot(t,ref)
title('Plot of Reference Square Wave')
xlabel('Time (s)')
ylabel('Voltage (V)')

%% Design LPFilter
% The built-in MATLAB lowpass filter function doesn't do a good enough job
% with lowpass filtering. This should probably be a Bessel filter, but the
% one below is sufficient. The LP bandwidth determines the speed of
% response of the turbidimeter.
lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
         'PassbandFrequency',f/100,'PassbandRipple',0.2, ...
         'SampleRate',sr);
% fvtool(lpFilt)

%% Make Signals
% Generate signals by 
% linearly changing NTU from 0 to 1000 and making noisy copies of scaled
% square wave signals, to simulate the signals coming from the two diodes.
signal1 = (3.25-0.000414172*t*10).*awgn(ref,40,'measured'); % Note: 2nd Term is SNR in dB
signal2 = (0.217-exp(-0.0036155*t*10+log(0.217))).*awgn(ref,40,'measured'); % Note: 2nd Term is SNR in dB
plot(t, ref, t, signal1, t, signal2)
title('Plot of Reference and Signals')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Reference Square Wave','180 Degree Signal','90 Degree Signal')

%% Limit and make 12-bit
% Limit
signal1(signal1>3.3)=3.3;
signal1(signal1<0)=0;
signal2(signal2>3.3)=3.3;
signal2(signal2<0)=0;
% Make 12-bit
signal1 = round(4096*signal1/3.3)*3.3/4096;
signal2 = round(4096*signal2/3.3)*3.3/4096;

%% Find Freq & synthesize sine & cosine
% From here on out we are processing the simulated signals. This part is
% what the students would use to process their data.
% Figure out frequency of square wave from data.
pp = pulseperiod(ref, t);
avgFreq = 1./mean(pp)
% Generate sine and cosine at square wave frequency for lock-in
sw = sin(2*pi*avgFreq*t);
cw = cos(2*pi*avgFreq*t);
plot(t, ref, t, sw, t, cw)
title('Plot of Reference and Quadrature Signals')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Reference Square Wave','Sine Wave','Cosine Wave')

%% Do Quadrature
% do multiplications
sig1s = sw.*signal1;
sig1c = cw.*signal1;
sig2s = sw.*signal2;
sig2c = cw.*signal2;
plot(t, sig1s, t, sig1c, t, sig2s, t, sig2c)
title('Plot of Signals after Quadrature')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Signal 1 * Sine','Signal 1 * Cosine','Signal 2 * Sine','Signal 2 * Cosine')

%% LPF
% Lowpass Filter
sig1slp = filter(lpFilt,sig1s);
sig1clp = filter(lpFilt,sig1c);
sig2slp = filter(lpFilt,sig2s);
sig2clp = filter(lpFilt,sig2c);
plot(t, sig1slp, t, sig1clp, t, sig2slp, t, sig2clp)
title('Plot of Quadrature Signals after LP Filtering')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Signal 1 * Sine','Signal 1 * Cosine','Signal 2 * Sine','Signal 2 * Cosine')

%% Add in quadrature
% Combine signatures in quadrature
sig1 = 2*sqrt(sig1slp.*sig1slp+sig1clp.*sig1clp);
sig2 = 2*sqrt(sig2slp.*sig2slp+sig2clp.*sig2clp);
% look at results
plot(t,sig1, t, sig2)
title('Plot of Signal Magnitudes')
xlabel('Time (s)')
ylabel('Voltage (V)')
legend('Signal 1 ','Signal 2')

%% Calculate NTU
% Take the ratio of the two signals
rat = sig2./sig1;
% Calculate the NTU from the ratio
NTU = 3.821739700382864 + rat.*(939.7102998172565 + rat.*(...
    339963.5875757225 + rat.*(-8853763.781440246 + rat.*...
    87430404.18200735)));
plot(t,NTU)
title('Plot of Calculated Turbidity vs. Time')
xlabel('Time (s)')
ylabel('Turbidity (NTU)')
