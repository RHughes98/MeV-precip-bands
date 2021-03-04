function [bandStart, bandEnd] = beltBands(crit1,crit2,rate,...
    tMin,tMax)
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

% find where both crit1 and crit2 are met

% Option 1: crit1 stretch falls within crit2 stretch
c1StartIndex = find(ismember(starts1,find(crit2)));
c1EndIndex = find(ismember(ends1,find(crit2)));
c1BandIndex = intersect(c1StartIndex,c1EndIndex);

c1Start = starts1(c1BandIndex);
c1End = ends1(c1BandIndex);

% Option 2: crit2 stretch falls within crit1 stretch
c2StartIndex = find(ismember(starts2,find(crit1)));
c2EndIndex = find(ismember(ends2,find(crit1)));
c2BandIndex = intersect(c2StartIndex,c2EndIndex);

c2Start = starts2(c2BandIndex);
c2End = ends2(c2BandIndex);

% check that all c1 indices (midpoints) meet crit2
c1NumEndpoints = length(c1BandIndex);
for i = 1:c1NumEndpoints
    if ismember(0,crit2(c1Start(i):c1End(i)))...
            || rate(c1Start(i)) < 10 ...
            || rate(c1End(i)) < 10 %threshold criteria
        c1Start(i) = NaN;
        c1End(i) = NaN;
    end
end

% repeat for c2 indices and crit1
c2NumEndpoints = length(c2BandIndex);
for i = 1:c2NumEndpoints
    if ismember(0,crit1(c2Start(i):c2End(i)))...
            || rate(c2Start(i)) < 10 ...
            || rate(c2End(i)) < 10 %threshold criteria
        c2Start(i) = NaN;
        c2End(i) = NaN;
    end
end

% eliminate bands that don't meet criteria for whole duration
c1Start(isnan(c1Start)) = [];
c1End(isnan(c1End)) = [];

c2Start(isnan(c2Start)) = [];
c2End(isnan(c2End)) = [];

%% Combine

bandStart = sort([c1Start; c2Start]);
bandEnd = sort([c1End; c2End]);
