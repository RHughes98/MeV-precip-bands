clear; close all; clc

crit = [0 1 1 1 0 0 0 1 1 1 1 0]';
% a = a == 1; % convert to logical
% a = double(a); % convert to double

crit0 = [crit; 0]; %add zero to avoid empty ii condition

% find ends of consecutive 1's
critEnds = strfind(crit0',[1 0]);

a1 = cumsum(crit);

% cumulative sum @ end of any stretch of 1's
i1 = a1(critEnds);

% need to handle empty ii/i1 condition before this
crit0(critEnds+1) = -[i1(1); diff(i1)];
crit0'

out = cumsum(crit0);
out'

% define band start and end
threshold = 3;
endIndices = out >= threshold;

% filter down to just endpoints
for i = 2:length(endIndices)
    if endIndices(i-1) == 1 && endIndices(i) == 1
        endIndices(i-1) = 0;
    end
end

ends = find(endIndices)

starts = find(endIndices) - out(endIndices) + 1