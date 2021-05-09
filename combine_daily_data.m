% Housekeeping
clear; close all; clc

%% Rate Data
% days of rate files to read in
days = [345:349, 351:353];

% define arrays to print to file
t = [];
rate1 = []; rate2 = []; rate3 = [];
rate4 = []; rate5 = []; rate6 = [];

for day = days
%     read data
    filename = strcat('SAMPEXdata/rateDataByDay/hhrr2005',num2str(day),'.txt');
    rateData = readmatrix(filename,'NumHeaderLines',1);
      
%     sort data
%     increment time if not first pass through loop
    if t > days(1)
        t = [t; t(end)+rateData(:,1)]; %s, time
    else
        t = [t; rateData(:,1)]; %s, time
    end
    rate1 = [rate1; rateData(:,2)]; %Sum from Time to Time + 20 msec
    rate2 = [rate2; rateData(:,3)]; %Sum from Time + 20 msec to Time + 40 msec
    rate3 = [rate3; rateData(:,4)]; %Sum from Time + 40 msec to Time + 60 msec
    rate4 = [rate4; rateData(:,5)]; %Sum from Time + 60 msec to Time + 80 msec
    rate5 = [rate5; rateData(:,6)]; %SSD4 from Time to Time + 100 msec
    rate6 = [rate6; rateData(:,7)]; %Sum from Time + 80 msec to Time + 100 msec
        
end

% open text file
fileID = fopen('SAMPEXdata/2005_345to353.txt','w');
% write header line
fprintf(fileID,'Time Rate1 Rate2 Rate3 Rate4 Rate5 Rate6\n');
% write rate data to file
writeData = [t,rate1,rate2,rate3,rate4,rate5,rate6]';
fprintf(fileID,'%.2f, %d, %d, %d, %d, %d, %d\n',writeData);


%% Attitude Data
%{
% read file and extract time data (all we need)
attData = readmatrix('SAMPEXdata/2005_345to353_att_raw.txt','NumHeaderLines',74);

t_att = attData(:,3); %sec

% indices and values of time before downward 'skip'
maxIndices = find(diff(t_att) < 0);
maxes = t_att(maxIndices);

% increment t vector by latest max to make it linear
for i = 1:length(maxes)
    t_att(maxIndices(i)+1:end) = t_att(maxIndices(i)+1:end) + maxes(i);
end

% swap in modified time data for output
writeData_att = attData;
writeData_att(:,3) = t_att;
writeData_att = writeData_att';

% write att data to file
fileID_att = fopen('SAMPEXdata/2005_345to353_att.txt','w');
fprintf(fileID_att,'%d, %d
, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d \n',...
    writeData_att);
%}