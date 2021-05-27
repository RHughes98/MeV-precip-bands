function [bandStart, bandEnd] = mergedCritBands(crit1,crit2,rate,tMin,tMax)
% Author: Ryan Hughes
% Purpose: Combine PB criteria before evaluating to reduce gaps in crit met
% Input:
%       crit1: logical array of first criteria
%       crit2: logical array of second criteria
%       rate: count rate data
%       tMin: min. time window of a PB (must be at least this many sec)
%       tMax: max. time window of a PB
% Output:
%       bandStart: array of precipitation band start indices
%       bandEnd: array of precipitation band end indices
%% Merge criteria

mergedCrit = crit1 & crit2;

% apply moving percent function
mergedCrit = mergedCrit | movPercent(mergedCrit,4,75);
% OR operator keeps True values outside of high-% 'chains'
% MAKE SURE TO change function parameters in plotFunc too!

%% Find criteria 'stretches'

mcrit_d = double(mergedCrit);
mcrit_d0 = [mcrit_d; 0]; % appended zero for streaks that end at last element
mcrit_ends = strfind(mcrit_d0',[1 0]); % ends of streaks of any length

% if crit is never met, return empty arrays
if isempty(mcrit_ends)
    bandStart = []; bandEnd = [];
    return 
end

mcrit_cumu = cumsum(mergedCrit); % cumulative sum of all 'true' indices
mcrit_endVals = mcrit_cumu(mcrit_ends); % count values at end of each stretch
mcrit_d0(mcrit_ends + 1) = -[mcrit_endVals(1); diff(mcrit_endVals)];
mcrit_stretches = cumsum(mcrit_d0);

% Handle time window
if isempty(tMax)
    % time window over which crit1 must be met
    window = tMin*10;
    
    endIndices = mcrit_stretches >= window;
else
    % time window over which crit1 must be met
    wMin = tMin*10;
    wMax = tMax*10;
    
    endIndices = mcrit_stretches >= wMin & mcrit_stretches < wMax;
end

% filter down to just endpoints
for i = 2:length(endIndices)
    if endIndices(i-1) == 1 && endIndices(i) == 1
        endIndices(i-1) = 0;
    end
end

%% Processing & cleaning

bandEnd = find(endIndices);
bandStart = find(endIndices) - mcrit_stretches(endIndices) + 1;

% if band starts/ends below min. count threshold, remove
for i = 1:length(bandEnd)
    if rate(bandStart(i)) < 20 || rate(bandEnd(i)) < 20
        bandStart(i) = NaN;
        bandEnd(i) = NaN;
    end
end

bandStart(isnan(bandStart)) = [];
bandEnd(isnan(bandEnd)) = [];
end