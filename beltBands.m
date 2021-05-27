% Author: Ryan Hughes
% Purpose: Identify bands along Van Allen Belts using modified criteria
% Input:
%       crit1: logical array of first criteria
%       crit2: logical array of second criteria
%       rate: count rate data
%       tMin: min. time window of a PB (must be at least this many sec)
%       tMax: max. time window of a PB
% Output:
%       bandStart: array of precipitation band start indices
%       bandEnd: array of precipitation band end indices

function [bandStart, bandEnd] = beltBands(crit1,crit2,rate,...
    tMin,tMax)

% Inactive

% if revived:
%   check for duplicates

%% Find gaps

% check for empty criteria condition
crit1d = double(crit1);
crit1d0 = [crit1d; 0]; % appended zero for streaks that end at last element
crit1ends = strfind(crit1d0',[1 0]); % ends of streaks of any length

crit2d = double(crit2);
crit2d0 = [crit2d; 0]; % appended zero for streaks that end at last element
crit2ends = strfind(crit2d0',[1 0]); % ends of streaks of any length

if isempty(crit1ends) || isempty(crit2ends) %if either crit is never met
    bandStart = [];
    bandEnd = [];
    return;
end

crit1cumu = cumsum(crit1); %cumulative count of all 'true' indices
crit1endVals = crit1cumu(crit1ends); %count values at end of each stretch
crit1d0(crit1ends+1) = -[crit1endVals(1); diff(crit1endVals)];
crit1stretches = cumsum(crit1d0);



crit2cumu = cumsum(crit2); %cumulative count of all 'true' indices
crit2endVals = crit2cumu(crit2ends); %count values at end of each stretch
crit2d0(crit2ends+1) = -[crit2endVals(1); diff(crit2endVals)];
crit2stretches = cumsum(crit2d0);

if isempty(tMax)
    % time window over which crit1 must be met
    window = tMin*10;
    
    endIndices1 = crit1stretches >= window;
    endIndices2 = crit2stretches >= window;
else
    % time window over which crit1 must be met
    wMin = tMin*10;
    wMax = tMax*10;

    endIndices1 = crit1stretches >= wMin & crit1stretches < wMax;
    endIndices2 = crit2stretches >= wMin & crit2stretches < wMax;
end

% filter down to just endpoints
for i = 2:length(endIndices1)
    if endIndices1(i-1) == 1 && endIndices1(i) == 1
        endIndices1(i-1) = 0;
    end
end

for i = 2:length(endIndices2)
    if endIndices2(i-1) == 1 && endIndices2(i) == 1
        endIndices2(i-1) = 0;
    end
end

ends1 = find(endIndices1);
ends2 = find(endIndices2);

starts1 = find(endIndices1) - crit1stretches(endIndices1) + 1;
starts2 = find(endIndices2) - crit2stretches(endIndices2) + 1;

%% Check bands for both criteria

min_overlap_percent = .98;

for i = 1:length(ends1)
    if ~percentCheck(crit2(starts1(i):ends1(i)),min_overlap_percent)
        starts1(i) = NaN;
        ends1(i) = NaN;
    end
end

for i = 1:length(ends2)
    if ~percentCheck(crit1(starts2(i):ends2(i)),min_overlap_percent)
        starts2(i) = NaN;
        ends2(i) = NaN;
    end
end

starts1(isnan(starts1)) = [];
ends1(isnan(ends1)) = [];

starts2(isnan(starts2)) = [];
ends2(isnan(ends2)) = [];
%% Combine

bandStart = sort([starts1; starts2]);
bandEnd = sort([ends1; ends2]);

%% Final cleaning

for i = 1:length(bandEnd)
    if rate(bandStart(i)) < 10 || rate(bandEnd(i)) < 10
        bandStart(i) = NaN;
        bandEnd(i) = NaN;
    end
end

bandStart(isnan(bandStart)) = [];
bandEnd(isnan(bandEnd)) = [];
end