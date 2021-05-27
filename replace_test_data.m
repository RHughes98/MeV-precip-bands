% Author: Ryan Hughes
% Purpose: Re-test pre-existing neural network model with different test data 
% Input:
%       testDaysNew: array of numerical days (of the year 2005) to test
% Output:
%       overall_acc: average accuracy across all tested days
%% Housekeeping
clear; close all; clc

%% Read & sort data

testDaysNew = [345 348 353 365];
testDataNew = read_days(testDaysNew);

retestLabelsMat = load('retestLabels.mat');
retestLabels = retestLabelsMat.labelmat.labels;

% retestLabelDoubles = zeros(size(retestLabels));
for i = 1:length(retestLabels)
    retestLabelDoubles(i) = retestLabels(i);
    if size(retestLabels{i},2) > 1
        retestLabels{i} = categorical(retestLabels{i});
    else
        retestLabels{i} = categorical(retestLabels{i}');
    end
end
retestLabels = flip(retestLabels');
retestLabelDoubles = flip(retestLabelDoubles);

%% Re-test network

load e10_bidirLSTM % swap out this network name to test other nets

predict = classify(net, testDataNew, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
%%
for i = 1:length(predict)
    acc(i) = sum(predict{i} == retestLabels{i}) ./ numel(retestLabels{i});
end

overall_acc = mean(acc);

%% Plot results

for i = 1:length(testDataNew)
    rate = testDataNew{1,i}(2,:);
    band_rate = rate' .* retestLabelDoubles{1,i};
    
    figure
    semilogy(testDataNew{1,i}(1,:),rate)
    hold on
    semilogy(testDataNew{1,i}(1,:),band_rate,'g','LineWidth',1.5)
    
    
    title(sprintf('Precipitation Bands for Day %i',testDaysNew(i)))
    xlabel('Time [s]')
    ylabel('Count Rate (per 100 ms, log-scaled)')
    legend('Count rate','Precip bands')
end