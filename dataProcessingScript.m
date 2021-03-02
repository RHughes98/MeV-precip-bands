%% Rapid MeV Electron Precipitation Data Processing Script
% Author: Ryan Hughes
% Purpose: Read, plot, and analyze SAMPEX energetic particle data in order
%          to classify precipitation features

%% Nomenclature
% e: elementary-charge const.
% PCR(E?): rear proportional counter
% q: electric charge
% SSD: solid-state detectors
% Z: charge number, Z = q/e
% MLT:  magnetic local time (traced to equator like L-shell)
% L-shell: how many Earth radii from the surface the mag. field line
%   crosses the equator
% SAA: South Atlantic Anomaly
% LC(1/2): Loss cone, half angle at which particles precipitate within 1
%   bounce
% inv_lat: invariant latitude, seems to 'flip' to achieve symmetry
% PA: Pitch angle of a particle heading down the instrument boresight (i.e.
%   angle between S/C z-axis and (-1) times the local magnetic field 
%   vector)

%% Housekeeping
clear; close all; clc;
tic
%% Read/sort data
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

%% Data Cleaning

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

% log-scaled rate count
rate_raw.rate5log = log(rate_raw.rate5);
rate.rate5log = log(rate.rate5); 

% magnetic flux
flux5 = (rate.rate5./15)*10; %counts/(str*sec*cm^2)
flux5len = length(flux5);


%% VA Belts

% magnetic field magnitude local minima
localMin_Bmag = islocalmin(att.Bmag); 
localMin_Bmag = att.Bmag < .4 & localMin_Bmag; % eliminate unwanted minima
localMin_BmagIndices = find(localMin_Bmag);
localMin_BmagIndices = [1; localMin_BmagIndices; length(att.Bmag)]; % include endpoints

% rolling avg. for noise-reduced fitting
VA.avg1s = movmean(rate.rate5,10,'Endpoints','fill');

% identify 'humps' in count rate 
VA.threshold = VA.avg1s > 12;

% set minimum time length for VA belts to eliminate errors to noise
VA.indices = find(VA.threshold);
VA.diff = diff(VA.indices);
VA.gap = find(VA.diff ~= 1);
VA.gapDiff = diff(VA.gap);
VA.window = 12*10; %humps must be 12 sec or longer
VA.startIndices = VA.gap(VA.gapDiff >= VA.window)+1;
VA.endIndices = VA.gap(find(VA.gapDiff >= VA.window)+1);
VA.start = VA.indices(VA.startIndices);
VA.end = VA.indices(VA.endIndices);

% rolling average for band identification
VA.avg = movmean(rate.rate5,10,'Endpoints','fill');

% curve fitting along VA belts     
VAbeltTally = curveFitting(rate.t,rate.rate5,VA);

figure
semilogy(rate.t,rate.rate5)
hold on
semilogy(rate.t.*VA.threshold,rate.rate5.*VA.threshold,'k')
semilogy(rate.t(VA.start),rate.rate5(VA.start),'gd')
semilogy(rate.t(VA.end),rate.rate5(VA.end),'ms')
semilogy(rate.t(find(att.roundedSAA)),rate_raw.rate5(find(att.roundedSAA)),'--')
plot(rate.t,att.Lshell)
yline(3,'r'); yline(7,'r')
title("VA Belt Identification")
xlabel("Time [h] "); ylabel("Count Rate (per 100ms)");
legend("Count Rate","> threshold","VA Start","VA End","Dropped SAA")


%% Microbursts

MB.window = 5; %500 ms, running avg. time window
MB.rateShort = rate.rate5(ceil(MB.window/2):end-floor(MB.window/2)); %N100
MB.tShort = rate.t(ceil(MB.window/2):end-floor(MB.window/2)); %shortened for index matching
MB.A500 = movmean(rate.rate5,MB.window,'Endpoints','discard'); %running avg. over 500 ms
MB.criterion = (MB.rateShort-MB.A500)./sqrt(1+MB.A500); %designated burst criterion
MB.burstIndex = find(MB.criterion > 10); %indices of identified microbursts

% identified bursts and their respective times
MB.bursts = MB.rateShort(MB.burstIndex);
MB.tBursts = MB.tShort(MB.burstIndex);

MB.halfBin = 15; %1.5 s, half of baseline percentile bin size
MB.fluxGroups = zeros(2*MB.halfBin,flux5len); MB.rateGroups = MB.fluxGroups;
for i = MB.halfBin+1:flux5len-MB.halfBin+1
    MB.fluxGroups(:,i) = flux5(i-MB.halfBin:i+MB.halfBin-1);
    MB.rateGroups(:,i) = rate.rate5(i-MB.halfBin:i+MB.halfBin-1);
end
MB.B3 = prctile(MB.fluxGroups,10,1)'; %10th percentile in 3s bins
MB.B3short = MB.B3(ceil(MB.window/2):end-floor(MB.window/2));

MB.burstMag = MB.bursts-MB.B3short(MB.burstIndex); %burst magnitude

%% Precipitation bands

% PB.window = 5;
% PB.rateShort = MB.rateShort; %N100

PB.halfBin = 100; %10 s, half of baseline percentile bin size
PB.fluxGroups = zeros(2*PB.halfBin,flux5len); PB.rateGroups = PB.fluxGroups;
for i = PB.halfBin+1:flux5len-PB.halfBin+1
    PB.fluxGroups(:,i) = flux5(i-PB.halfBin:i+PB.halfBin-1);
    PB.rateGroups(:,i) = rate.rate5(i-PB.halfBin:i+PB.halfBin-1);
%     PB.timeGroups(:,i) = rate.t(i-PB.halfBin:i+PB.halfBin-1);
end

PB.B10 = prctile(PB.fluxGroups,10,1)'; %10th percentile in 20s bins
% PB.B10short = PB.B10(ceil(PB.window

% N100 > 4*B20 for >= 5s
PB.crit1 = rate.rate5 > 4 * PB.B10;
% PB.crit1 = rate.rate5 > 1.2*PB.B10;
% PB.A5 = movmean(rate.rate5,50,'Endpoints','discard');
% PB.crit1 = rate.rate5(25:end-25) >  PB.A5;

% linear corrcoef b/w N100 & B20 < .955

PB.movCC = zeros(flux5len,1);
for i = 51:flux5len-49
    CC = corrcoef(rate.rate5(i-50:i+49),PB.B10(i-50:i+49));
    PB.movCC(i) = CC(2);
end

% loop unrolling:
% want i-50 to i+49 and i+50 to i+99
% for i:51:flux5len-99 <-- would I need to skip any indices? I think not

PB.crit2 = PB.movCC < .955;
PB.crit2Indices = find(PB.crit2); %indices where crit2 is met

% abstracted PB function
[PB.bandStart, PB.bandEnd, PB.crit1Indices] = PBands(PB.crit1,PB.crit2,...
    rate.rate5,5,[]);

% avg for plotting
PB.avg = movmean(rate.rate5,25,'Endpoints','fill');

%% Alternative PB

% applying microburst eqn. to PB
PB2.window = 200; %20 s, running avg. time window
PB2.rateShort = rate.rate5(ceil(PB2.window/2):end-floor(PB2.window/2)); %N100
PB2.SAAshort = att.roundedSAA(ceil(PB2.window/2):end-floor(PB2.window/2));
PB2.tShort = rate.t(ceil(PB2.window/2):end-floor(PB2.window/2)); %shortened for index matching
PB2.avg = movmean(rate.rate5,PB2.window,'Endpoints','discard'); %running avg. over (window/10) s
PB2.avg(find(PB2.SAAshort)) = 0;
PB2.criterion = (PB2.rateShort-PB2.avg)./sqrt(1+PB2.avg); %designated burst criterion
PB2.eqnIndex = find(PB2.criterion > 10); %indices of identified microbursts

PB2.eqnDiff = diff(PB2.eqnIndex);
PB2.eqnGap = find(PB2.eqnDiff ~= 1); %indices right before 'jumps'
PB2.eqnGapDiff = diff(PB2.eqnGap); %# of indices between jumps

% baselines with varied percentiles (all 20s bins)
PB2.B25 = prctile(PB.fluxGroups,25,1)';
PB2.B50 = prctile(PB.fluxGroups,50,1)'; 
PB2.B75 = prctile(PB.fluxGroups,75,1)';

PB2.Bshort = PB2.B50(ceil(PB2.window/2):end-floor(PB2.window/2));


% use avg instead of baseline 
PB2.avgShort = movmean(PB2.rateShort,20,'Endpoints','fill'); %short-window moving avg
PB2.avgShort(find(PB2.SAAshort)) = 0;
PB2.avgCrit1 = PB2.avgShort > 1.2*PB2.avg;

% corrcoef operation for avg
PB2.shortLength = length(PB2.avg);
PB2.movCC = zeros(PB2.shortLength,1);
for i = 51:PB2.shortLength-49
    CC = corrcoef(PB2.avgShort(i-50:i+49),PB2.avg(i-50:i+49));
    PB2.movCC(i) = CC(2);
end
PB2.avgCrit2 = PB2.movCC < .955;

[PB2.avgBandStart,PB2.avgBandEnd,PB2.crit1avgIndices] = PBands(PB2.avgCrit1,...
    PB2.avgCrit2,PB2.rateShort,4,[]);


% use standard deviation
PB2.std3 = movstd(PB2.rateShort,75,'Endpoints','fill'); %3-second standard deviation
PB2.stdCrit1 = PB2.avgShort > PB2.avg + .5*PB2.std3;
% PB2.avgShort_fullLength = movmean(rate.rate5,20,'Endpoints','fill'); %short-window moving avg

[PB2.stdBandStart,PB2.stdBandEnd,PB2.crit1stdIndices] = PBands(PB2.stdCrit1,...
    PB2.avgCrit2,PB2.rateShort,5,[]);


% 'in-betweener' PB (time < 5 s)
% [PB2.lowStart, PB2.lowEnd, ~] = PBands(PB.crit1,PB.crit2,rate.rate5,1.5,3);
% [PB2.midStart, PB2.midEnd, ~] = PBands(PB.crit1,PB.crit2,rate.rate5,3,5);
[PB2.lowStart, PB2.lowEnd, ~] = PBands(PB2.avgCrit1,PB2.avgCrit2,PB2.rateShort,1.5,3);
[PB2.midStart, PB2.midEnd, ~] = PBands(PB2.avgCrit1,PB2.avgCrit2,PB2.rateShort,3,5);
% [PB2.lowStart, PB2.lowEnd, ~] = PBands(PB2.stdCrit1,PB2.avgCrit2,PB2.rateShort,1.5,3);
% [PB2.midStart, PB2.midEnd, ~] = PBands(PB2.stdCrit1,PB2.avgCrit2,PB2.rateShort,3,5);

%% Self-check

% stop timer before manual check
toc

% adjusted avg for selfCheckTally function
PB2.tallyAvg = [zeros(PB2.window/2,1); PB2.avg];

% original criteria
% [selfCheckTally,PB.mislabels] = quickPlotCheck(PB.bandStart,PB.bandEnd,...
%     rate.rate5,rate.t,PB.avg,PB.crit1,PB.crit2);

% average-based criteria
[selfCheckTally,PB.mislabels] = quickPlotCheck(PB2.avgBandStart,PB2.avgBandEnd,...
    PB2.rateShort,PB2.tShort,PB2.avgShort,PB2.avgCrit1,PB2.avgCrit2);

% standard deviation criteria
% [selfCheckTally,PB.mislabels] = quickPlotCheck(PB2.stdBandStart,PB2.stdBandEnd,...
%     PB2.rateShort,PB2.tShort,PB2.avgShort,PB2.stdCrit1,PB2.avgCrit2);

% drop user-identified mislabels
if (~isempty(PB.mislabels))
%     PB.bandStart(PB.mislabels) = []; PB.bandEnd(PB.mislabels) = [];
    PB2.avgBandStart(PB.mislabels) = []; PB2.avgBandEnd(PB.mislabels) = [];
%     PB2.stdBandStart(PB.mislabels) = []; PB2.stdBandEnd(PB.mislabels) = [];
end

%% Plots

% original criteria
% plotFunc(rate.t,rate.rate5,rate.t,rate.rate5,PB.bandStart,...
%     PB.bandEnd,PB.B10,PB.avg,PB.crit1,PB.crit2,MB,PB2);

% average-based criteria
plotFunc(rate.t,rate.rate5,PB2.tShort,PB2.rateShort,PB2.avgBandStart,...
    PB2.avgBandEnd,PB.B10,PB2.avgShort,PB2.avgCrit1,PB2.avgCrit2,MB,PB2,VA.threshold);

% standard deviation criteria
% plotFunc(rate.t,rate.rate5,PB2.tShort,PB2.rateShort,PB2.stdBandStart,...
%     PB2.stdBandEnd,PB.B10,PB2.avgShort,PB2.stdCrit1,PB2.avgCrit2,MB,PB2);
