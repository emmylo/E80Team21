% logreaderfinal.m
% Use this script to read data from your micro SD card

clear;
%clf;

% 71 was BFS I think
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




%% PROCESS THERMISTOR DATA

teensyunit = 0.003237;
A03prime = double(A03);
Vthermistor = teensyunit.*A03prime; %% MAKE SURE CORRECT PIN
%Vthermistor = linspace(0.3,3.3,100); % test vector
temps = Vthermistor.*-37.1 + 109;
cutTemps = temps(1500:end-25);
t = 0.099.*(1:length(cutTemps));
figure(3)
plot(t,temps(1500:end-25))
fontsize("scale", 1.4)
xlabel('Time (seconds)')
ylabel('Temperature (degrees Celsius)')
fontsize("default")
title(['Motor A H-Bridge Temperature (14-Minute Autonomous Run)'])
hold on 
annotation("textarrow",[.763 .763],[.80 .88],String="Peak Temperature: 54°C")


%hold on
%plot(motorC)

