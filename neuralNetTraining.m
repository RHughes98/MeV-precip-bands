%% Housekeeping
clear; close all; clc

%% Read & sort data
% file naming convention: hhrrYearDay.txt
% rateData = readmatrix('SAMPEXdata/2005_345to353.txt','NumHeaderLines',1);
% attData = readmatrix('SAMPEXdata/2005_345to353_att.txt');

rateData = readmatrix('SAMPEXdata/rateDataByDay/hhrr2005347.txt','NumHeaderLines',1);
attData = readmatrix('SAMPEXdata/attDataByDay/hhrr2005347_att.txt','NumHeaderLines',74);

% [t,rate1,rate2,rate3,rate4,rate5] = deal(rateData{:,:});

rate_raw.t = rateData(:,1); %s, time
% rate.rate1 = rateData(:,2); %Sum from Time to Time + 20 msec
% rate.rate2 = rateData(:,3); %Sum from Time + 20 msec to Time + 40 msec
% rate.rate3 = rateData(:,4); %Sum from Time + 40 msec to Time + 60 msec
% rate.rate4 = rateData(:,5); %Sum from Time + 60 msec to Time + 80 msec
rate_raw.rate5 = rateData(:,6); %SSD4 from Time to Time + 100 msec
% rate.rate6 = rateData(:,7); %Sum from Time + 80 msec to Time + 100 msec

att_raw.year = attData(:,1); %year of data collection
att_raw.day = attData(:,2); %day of year
att_raw.sec = attData(:,3); %seconds of day (1-86400)
att_raw.long = attData(:,4); %deg, longitude in GEO coords. (0-360)
att_raw.lat = attData(:,5); %deg, latitude in GEO coords. (-90-90)
att_raw.alt = attData(:,6); %km, altitude in GEO coord. system
att_raw.Lshell = attData(:,7); %Earth radii, L-shell param.
att_raw.Bmag = attData(:,8); %gauss, Model field magnitude
att_raw.MLT = attData(:,9); %hr, magnetic local time
att_raw.inv_lat = attData(:,10); %deg, invariant latitude (0-90)
att_raw.LC1 = attData(:,11); %deg, loss cone 1
att_raw.LC2 = attData(:,12); %deg, loss cone 2
att_raw.eqB = attData(:,13); %gauss, magnitude of mag. field at mag. equator
att_raw.N100B = attData(:,14); %gauss, magnitude of mag. field at north 100km
att_raw.S100B = attData(:,15); %gauss, magnitude of mag. field at south 100km
att_raw.SAA = attData(:,16); %boolean, South Atlantic Anomaly Flag (drop true)
att_raw.PA = attData(:,17); %deg, pitch angle of a particle
att_raw.att_flag = attData(:,18); %boolean, attitude data quality flag

%% Clean data 

% drop SAA flag
% SAA_index = find(att_raw.SAA); %<---- indices don't align here!!!!
% rate_SAA.t = rate.t; %no need to drop SAA indices from timestamps, just counts
% rate_SSA.rate1 = rate.rate1; rateSSA.rate1(SAA_index) = 0;
% rate_SSA.rate2 = rate.rate2; rateSSA.rate2(SAA_index) = 0;
% rate_SSA.rate3 = rate.rate3; rateSSA.rate3(SAA_index) = 0;
% rate_SSA.rate4 = rate.rate4; rateSSA.rate4(SAA_index) = 0;
% rate_SSA.rate5 = rate.rate5; rateSSA.rate5(SAA_index) = 0;
% rate_SSA.rate6 = rate.rate6; rateSSA.rate6(SAA_index) = 0;
% 
% drop_check = find(rate.rate1 - rateSSA.rate1 ~= 0);

% attitude flag check

% convert time to hours
rate_raw.t = rate_raw.t ./ 3600; %h
rate.t = rate_raw.t;
att_raw.sec = att_raw.sec ./ 3600; %h

% 'de-loop' longitude data for interpolation (will be reversed later)
% this is to avoid undesired interpolation on 360->0 'skips'
longMaxIndices = [find(diff(att_raw.long)<0); length(att_raw.long)]; %indices of max values before skipping
longMaxes = att_raw.long(longMaxIndices); %check that longMaxIndices occur on max values
for i = 2:length(longMaxIndices)
    att_raw.long(longMaxIndices(i-1)+1:longMaxIndices(i)) = ...
        att_raw.long(longMaxIndices(i-1)+1:longMaxIndices(i))+360*(i-1);
end

% cubic interpolation
% (interp1 also matches time vectors and adjusts data accordingly)
att.sec = interp1(att_raw.sec,att_raw.sec,rate.t,'pchip');
att.long = interp1(att_raw.sec,att_raw.long,att.sec,'pchip');
att.lat = interp1(att_raw.sec,att_raw.lat,att.sec,'pchip');
att.inv_lat = interp1(att_raw.sec,att_raw.inv_lat,att.sec,'pchip');
att.alt = interp1(att_raw.sec,att_raw.alt,att.sec,'pchip');
att.Lshell = interp1(att_raw.sec,att_raw.Lshell,att.sec,'pchip');
att.Bmag = interp1(att_raw.sec,att_raw.Bmag,att.sec,'pchip');
% att.MLT = interp1(att_raw.sec,att_raw.MLT,att.sec,'pchip');
att.LC1 = interp1(att_raw.sec,att_raw.LC1,att.sec,'pchip');
att.LC2 = interp1(att_raw.sec,att_raw.LC2,att.sec,'pchip');
att.eqB = interp1(att_raw.sec,att_raw.eqB,att.sec,'pchip');
att.N100B = interp1(att_raw.sec,att_raw.N100B,att.sec,'pchip');
att.S100B = interp1(att_raw.sec,att_raw.S100B,att.sec,'pchip');
att.SAA = interp1(att_raw.sec,att_raw.SAA,att.sec,'pchip');

% 're-loop' longitude data using modulus
att.long = mod(att.long,360);
att_raw.long = mod(att_raw.long,360); %in the spirit of keeping it as 'raw' data

% drop SAA from rate data
rate.rate5 = rate_raw.rate5;
att.roundedSAA = ceil(att.SAA); %adjust for decimal values from interp
rate.rate5(find(att.roundedSAA)) = 0; 

% convert count rate data to single for memory space
rate.count = cast(rate.rate5,'single');

%% Define training vs. test data

len = length(rate.rate5);
trainingInds = floor([len*0.2; len*0.6]);
trainingXs = rate.t(trainingInds);

figure
semilogy(rate.t, rate.rate5)
hold on
maxY = get(gca,'ylim');
trainFill = fill([trainingXs(1) trainingXs(1) trainingXs(2) trainingXs(2)],...
    [maxY fliplr(maxY)],'m','EdgeColor','none');
testFill = fill([trainingXs(2) trainingXs(2) rate.t(len) rate.t(len)],...
    [maxY fliplr(maxY)],'g','EdgeColor','none');
set(trainFill, 'facealpha',.4)
set(testFill, 'facealpha',.4)
title("Training Data Split")
xlabel("Time [h]"); ylabel("Count Rate (per 100ms, log-scaled)")
legend("Count Rate", "Training Data", "Test Data")

%% Train & test autoencoder

autoenc = trainAutoencoder(rate.count(trainingInds(1):trainingInds(2)));
prediction = predict(autoenc,rate.rate5(trainingInds(2):len));
Z = rate.rate5(trainingInds(1):trainingInds(2));
decoded = decode(autoenc,Z');