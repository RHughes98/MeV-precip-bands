function [bandStart, bandEnd, crit1index] = beltBands(crit1,crit2,rate,...
    tMin,tMax)
%% Find gaps

% find where crit1 is met for whole time window
c1index = find(crit1);
c1diff = diff(c1index);
c1gap = find(c1diff ~= 1);
c1gapDiff = diff([0; c1gap; 0]);
% x4gapDiff index = x4gap index --> 
% x4gap value @ index = x4index at start of stretch (b/w jumps)
% x4gap value @ index + 1 = x4index at end of stretch (b/w jumps)

% indices where crit2 is met
c2index = find(crit2);
c2diff = diff(c2index);
c2gap = find(c2diff ~= 1);
c2gapDiff = diff(c2gap);
% c2gapDiff index = c2gap index
% c2gap value @ index = c2index at start of stretch
% c2gap value @ index + 1 = c2index at end of stretch

if isempty(tMax)
    % time window over which crit1 must be met
    window = tMin*10;

    % indices where crit1 is met for t seconds
    c1StretchStart = c1gap(c1gapDiff >= window)+1;
    c1StretchEnd = c1gap(find(c1gapDiff >= window)+1);
    
    % indices where crit2 is met for t seconds
    c2StretchStart = c2gap(c2gapDiff >= window)+1;
    c2StretchEnd = c2gap(find(c2gapDiff >= window)+1);
else
    % time window over which crit1 must be met
    wMin = tMin*10;
    wMax = tMax*10;

    % indices where crit1 is met for t seconds
    c1StretchStart = c1gap(c1gapDiff >= wMin & c1gapDiff < wMax)+1;
    c1StretchEnd = c1gap(find(c1gapDiff >= wMin & c1gapDiff < wMax)+1);
    
    % indices where crit2 is met for t seconds
    c2StretchStart = c2gap(c2gapDiff >= wMin & c2gapDiff < wMax)+1;
    c2StretchEnd = c2gap(find(c2gapDiff >= wMin & c2gapDiff < wMax)+1);
end

crit1start = c1index(c1StretchStart);
crit1end = c1index(c1StretchEnd);
crit1index = c1index(sort([c1StretchStart; c1StretchEnd]));

crit2start = c2index(c2StretchStart);
crit2end = c2index(c2StretchEnd);
crit2index = c2index(sort([c2StretchStart; c2StretchEnd]));

%% Check bands for both criteria

% find where both crit1 and crit2 are met

% Option 1: crit1 stretch falls within crit2 stretch
c1StartIndex = find(ismember(crit1start,c2index));
c1EndIndex = find(ismember(crit1end,c2index));
c1BandIndex = intersect(c1StartIndex,c1EndIndex);

c1Start = crit1start(c1BandIndex);
c1End = crit1end(c1BandIndex);

% Option 2: crit2 stretch falls within crit1 stretch
c2StartIndex = find(ismember(crit2start,c1index));
c2EndIndex = find(ismember(crit2end,c1index));
c2BandIndex = intersect(c2StartIndex,c2EndIndex);

c2Start = crit2start(c2BandIndex);
c2End = crit2end(c2BandIndex);

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


end