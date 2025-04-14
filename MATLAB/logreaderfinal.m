% logreaderfinal.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '036'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');



%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

%% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

%% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);



%% PROCESS ANEMOMETER DATA

% voltages should be either 0 or around 1023, using 10 to be safe
low = 10;
A01prime = double(A01);

% number of seconds to take moving average over (times 10)
period = 10;
samples = 1:period:length(A01prime);
rps = zeros(1,length(samples));

% keeping track of what came before and what we're on now
prev = 100;
curr = A01(1);
revs = 0;
totalRevs = 0;
sampleTime = 700:800;

for i = 1:length(samples)-1
    for j = samples(i):samples(i+1)
        curr = A01(j);
    if(and(prev > low, curr < low))
        revs = revs + 1;
    end
    prev = curr;
    end
    totalRevs = revs + totalRevs;
    rps(i) = revs/period*10;

    revs = 0;
end

% awesome function that turns somethings like [1 2 3] into [ 1 1 2 2 3 3]
smoothrps = repelem(rps, period);
averagerps = totalRevs/length(sampleTime)*10;
windspeed = rps*10.1-5.14;
figure(1)
plot(windspeed)
xlabel('Sample Number')
ylabel('Wind Speed (mph)')
title('Anemometer')




%% PROCESS WIND VANE DATA
A02prime = double(A02);
Vin = 5;
Rf = 11000;
Rn1 = 6000;
Rg = 48000;
Rp1 = 50000;
R2 = 5000;
teensyunit = 0.003237; % one teensy unit to volts
Vteensy = A02prime.*0.003237; % PROBABLY CHANGE THIS PLEASE DON'T FORGET
%Vteensy = linspace(0.3,3.3,100); % test vector

Vdivider = -Rn1/Rf*(Vteensy - (1+Rf/Rn1)*(Rg/(Rp1+Rg)*Vin)); %back out to get Vout from voltage divider
R1 = R2*(Vin./Vdivider - 1); % back out to get resistance 

for i = 1:length(R1)
while (R1(i) >= 6000 || R1(i) <= 4000)
        if (R1(i) >= 6000) 
            R1(i) = R1(i) - 1000; % Decrease R1 by 1000 if it's greater than 6000
        else
            R1(i) = R1(i) + 1000;  % Increase R1 by 1000 if it's less than 4000
        end
end
end

       
for j = 1:length(R1)
if(R1(j)>=5000)
    R1(j) = R1(j) - 5000;
  
else
    R1(j) = R1(j) - 4000;
   
end
end

angle = R1./1000;
angledeg = 360-angle*360; % degrees
anglerad = angle*pi()/180; % radians

figure(2)
plot(angledeg)
xlabel('Sample Number')
ylabel('Angle (degrees)')
title('Weather Vane')

yl = ylim;
ylim([0 360]);
xl = xlim;
xBox = [xl(1), xl(2), xl(2), xl(1)];
directions = ['North', 'East', 'South', 'West'];
colors = ['y', 'g', 'b'];

lowEdge = 67.5;
highEdge = lowEdge+45;

for i = 1:3
    yBox = [lowEdge lowEdge highEdge highEdge];
    patch(xBox, yBox, colors(i), 'FaceColor', colors(i),'FaceAlpha', 0.1,'EdgeColor', 'none');
    lowEdge = lowEdge + 90;
    highEdge = highEdge + 90;
end

yBoxNlo = [0 0 22.5 22.5];
yBoxNhi = [337.5 337.5 360 360];
patch(xBox, yBoxNlo, 'black', 'FaceColor', 'red','FaceAlpha', 0.1,'EdgeColor', 'none')
patch(xBox, yBoxNhi, 'black', 'FaceColor', 'red','FaceAlpha', 0.1,'EdgeColor', 'none')
legend('Vane Direction','East','South', 'West', 'North')

hold off;

%% PROCESS THERMISTOR DATA

A03prime = double(A03);
Vthermistor = teensyunit.*A03prime; %% MAKE SURE CORRECT PIN
%Vthermistor = linspace(0.3,3.3,100); % test vector
temps = Vthermistor.*-37.1 + 109;
figure(3)
plot(temps)
xlabel('Sample Number')
ylabel('Temperature (degrees Celsius)')
title(['Thermistor'])
