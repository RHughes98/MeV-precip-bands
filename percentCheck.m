 % Author: Ryan Hughes
% Purpose: Find % of criteria (logical) vector that has a logical value of
%          True
% Inputs: 
%     crit_vec - logical 1xn array depicting whether or not criteria is met
%     min_percent - lower threshold of % True values to return 'passed'
% Output:
%       out: logical value indicating whether or not the minimum percentage
%            has been met
function [passed] = percentCheck(crit_vec,min_percent)

% standardize format of min_percent
if min_percent > 100 || min_percent < 0
    error('Minimum percentage must be between 0 and 1.0 or 0 and 100')
elseif min_percent > 1
    min_percent = min_percent / 100;
end

num_met = length(find(crit_vec)); %number of TRUE indices
percent_met = num_met / length(crit_vec); 

passed = percent_met > min_percent;

end