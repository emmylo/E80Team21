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


%% SAMPLE NUMBER TO TIME
t = 0.099*(0:length(A01));


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

% bring the 360 jumps to 0 
angledeg(angledeg > 315) = angledeg(angledeg > 315) -315;

figure(1902)
plot(angledeg)



yawDeg = yaw*180/pi;
headingIMUCut = headingIMU;
%headingIMUFiltered = lowpass(headingIMUCut,0.2);
%headingIMU = headingIMUFiltered;
%plot(headingIMUCut(3900:5200));
%%plot(headingIMUFiltered)
%plot(yawDeg(2000:8000))
plot(headingIMU+angledeg+70);


xlabel('Sample Number')
ylabel('Angle (degrees)')
title('Weather Vane')


yl = ylim;
ylim([0 360]);
xl = xlim;
xBox = [xl(1), xl(2), xl(2), xl(1)];
directions = ['Forward', 'Right', 'Backward', 'Left'];
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
legend('Vane Direction', 'Robot Heading', 'Right','Backward', 'Left', 'Forward')

hold off;



figure(121)
makeYaw = headingIMU*pi/180;
makeYaw = -makeYaw+pi/2;



if makeYaw<-pi
    makeYaw = makeYaw + 2*pi;
elseif makeYaw > pi
    makeYaw = makeYaw - 2*pi;
end

makeYaw = makeYaw*180/pi;

plot(makeYaw)
hold on
%plot(yawDeg-angledeg)
%deriv = yawDeg(1:end-1)-yawDeg(2:end);
%%plot(deriv)
plot(angledeg)
%headingIMU(headingIMU > -110) = headingIMU(headingIMU > -110) -180;
hold on
%plot(headingIMU+360)
%plot(angledeg)

%figure(11)
motorB = double(motorB);
motorA = double(motorA);
%plot((motorB-motorA)/20)

figure(999)
plot(headingIMU+angledeg+180);
title('Heading + Weather Vane + 180')



figure(939)
plot(angledeg)
hold on
plot(-headingIMU)
title('yaw_des and yaw')


