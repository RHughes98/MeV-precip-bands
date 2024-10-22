% Author: Ryan Hughes
% Purpose: Determine whether a certain percentage of criteria have been met
%          in a logical vector
% Input:
%       crit: logical array of criteria values (whether or not the crit is met)
%       window: moving time window of observation [s]
%       min_percent: lower threshold of % True values to fill an index w/ 1 (T)
% Output:
%       out: logical value indicating whether or not the minimum percentage
%            has been met
function [out] = movPercent(crit, window, min_percent)


% standardize format of min_percent
if min_percent > 100 || min_percent < 0
    error('Minimum percentage must be between 0 and 1.0 or 0 and 100')
elseif min_percent > 1
    min_percent = min_percent / 100;
end

ind = window * 10; % convert from s to indices
sum = movsum(crit,[ind-1 0]); % only looking backwards
% if min_percent of indices in the window are 1, then return index is 1
out = sum >= min_percent * ind; 

end