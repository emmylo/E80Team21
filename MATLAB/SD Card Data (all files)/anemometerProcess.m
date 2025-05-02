% logreaderfinal.m
% Use this script to read data from your micro SD card

clear;
%clf;

%218 (9:40am), 237 (1:45pm)

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



%% PROCESS ANEMOMETER DATA

% voltages should be either 0 or around 1023, using 10 to be safe
low = 10;
A01prime = double(A01);

% number of samples to take moving average over 
period = 200;

% keeping track of what came before and what we're on now
prev = 100;
curr = A01prime(1);

revolutionVector = zeros(1,length(A01prime));

for i = 2:length(A01prime)
    curr = A01prime(i);
    if and(curr < low, prev > low)
        revolutionVector(i) = 1;
    else
        revolutionVector(i) = 0;
    end
    prev = curr;
end

rps = movmean(revolutionVector, period)/0.099;

windspeed = rps*6.76+0.235; % calibration equation from rps to mph

%% SAMPLE NUMBER TO TIME
t = 0.099*(0:(length(windspeed)-1));

figure(1)
avgWind = mean(windspeed);
avgWindVector = avgWind.*ones(1,length(windspeed));
plot(t,avgWindVector)
hold on
plot(t,windspeed)
xlabel('Time (sec)')
ylabel('Wind Speed (mph)')
title('Wind Speeds during the 1:45pm Deployment')
averageWindString = append("Average: ", num2str(avgWind,3), " mph");
% annotation("textarrow",[.4 .4],[.5 .6],String=averageWindString) %940am
annotation("textarrow",[.5 .5],[.3 .41],String=averageWindString) %145pm



