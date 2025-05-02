% logreaderfinal.m
% Use this script to read data from your micro SD card

clear;
clf;

filenum = ['237']; % file number for the data you want to read
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

figure(9)
plot(headingIMU)

%% SAMPLE NUMBER TO TIME
t = 0.099*(1:length(A02));


%% PROCESS WIND VANE DATA
A02prime = double(A02);
A02prime = lowpass(A02prime,0.2);
Vin = 5;
Rf = 11000;
Rn1 = 6000;
Rg = 48000;
Rp1 = 50000;
R2 = 5000;
teensyunit = 0.003237; % one teensy unit to volts
Vteensy = A02prime.*0.003237; 
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
angledeg = angle*360; % degrees
anglerad = angledeg*pi()/180; % radians

for i = 1:length(angledeg)
    if angledeg(i)>337.5
        angledeg(i) = angledeg(i)-360;
    end
end

headingIMU = -headingIMU;
headingIMU = lowpass(headingIMU,0.2);

for j = 1:length(headingIMU)
    if headingIMU(j) < -50
        headingIMU(j) = headingIMU(j)+180;
    end
end


%angledegCleaned = lowpass(angledeg,0.5);
%headingIMUCleaned = lowpass(headingIMU,0.5);

plot(t,angledeg)
hold on
plot(t,headingIMU)

xlabel('Time (seconds)')
ylabel('Angle (degrees)')
legend('Weather Vane Angle','Robot Heading')
title('ASV Response to Wind Vane')

% 200 to 250
figure(1)
idx1 = (t >= 200) & (t <= 250);
plot(t(idx1), angledeg(idx1), 'b')
hold on
plot(t(idx1), headingIMU(idx1), 'r')
xlabel('Time (seconds)')
ylabel('Angle (degrees)')
legend('Weather Vane Angle', 'Robot Heading')
title('ASV Response to Wind Vane: Time 200–250')
grid on

% 280 to 340
figure(2)
idx2 = (t >= 280) & (t <= 340);
plot(t(idx2), angledeg(idx2), 'b')
hold on
plot(t(idx2), headingIMU(idx2), 'r')
xlabel('Time (seconds)')
ylabel('Angle (degrees)')
legend('Weather Vane Angle', 'Robot Heading')
title('ASV Response to Wind Vane: Time 280–340')
grid on

% 365 to 400
figure(3)
idx3 = (t >= 365) & (t <= 400);
plot(t(idx3), angledeg(idx3), 'b')
hold on
plot(t(idx3), headingIMU(idx3), 'r')
xlabel('Time (seconds)')
ylabel('Angle (degrees)')
legend('Weather Vane Angle', 'Robot Heading')
title('ASV Response to Wind Vane: Time 365–400')
grid on

% Time 500 to 700
figure(4)
idx4 = (t >= 500) & (t <= 700);
plot(t(idx4), angledeg(idx4), 'b')
hold on
plot(t(idx4), headingIMU(idx4), 'r')
xlabel('Time (seconds)')
ylabel('Angle (degrees)')
legend('Weather Vane Angle', 'Robot Heading')
title('ASV Response to Wind Vane: Time 500–700')
grid on
