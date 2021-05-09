%% Housekeeping
% clear; close all; clc

%% Read data
days = [345 346 348 351 352 353 363 364 365];
data = read_days(days);

%% Calculate variance
myvar = zeros(size(data));
for i = 1:length(data)
    myvar(i) = var(data{1,i}(2,:));
end