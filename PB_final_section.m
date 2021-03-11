%% Precipitation bands 

% time windows for moving avg.
PB.avgWindow = 20*10; %20 s, running avg time window
PB.avgWindowShort = 2*10; %2 s, running avg short window

% moving avg. count rate (standard and short-window)
PB.avg = movmean(rate.rate5,PB.avgWindow,'Endpoints','fill');
PB.avgShort = movmean(rate.rate5,PB.avgWindowShort,'Endpoints','fill');

% shifted avg. for plotting
% PB.shiftedAvg = 

% criteria
%  crit1 = 
%  critCC = 

% function calls
% [PB.bandStart, PB.bandEnd] = mergedCritBands(