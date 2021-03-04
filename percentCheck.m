% Author: Ryan Hughes
% Purpose: Find % of criteria (logical) vector that has a logical value of
%          True
% Inputs: 
%     crit_vec - logical 1xn array depicting whether or not criteria is met
%     min_percent - lower threshold of % True values to return 'passed'

function [passed] = percentCheck(crit_vec,min_percent)

num_met = length(find(crit_vec)); %number of TRUE indices
percent_met = num_met / length(crit_vec); 

passed = percent_met > min_percent;

end