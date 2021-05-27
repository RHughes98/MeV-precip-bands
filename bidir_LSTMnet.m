%% Bidirectional LSTM Neural Network
% Author: Ryan Hughes
% Purpose: Train and test a bidirectional Long Short-Term Memory (LSTM)
%          neural network model to identify precipitation bands
% Input:
%       trainDays: array of numerical days (of the year 2005) to train on
%       testDays: array of numerical days (of the year 2005) to test
% Output:
%       overall_acc: average accuracy across all tested days
%% Housekeeping
clear; close all; clc

%% Read & sort data

trainDays = [347 349];
trainData = read_days(trainDays);

trainLabelsMat = load('trainLabels.mat');
trainLabels = trainLabelsMat.labels;
for i = 1:length(trainLabels)
    trainLabelDoubles(i) = trainLabels(i);
    trainLabels{i} = categorical(trainLabels{i}');
end

testDays = [345 348 353 365];
testData = read_days(testDays);

testLabelsMat = load('testLabels.mat');
testLabels = testLabelsMat.labelmat.labels;

% testLabelDoubles = zeros(size(testLabels));
for i = 1:length(testLabels)
    testLabelDoubles(i) = testLabels(i);
    testLabels{i} = categorical(testLabels{i}');
end

%% Learning Parameters

inputSize = size(trainData{1,1},1);
numHiddenUnits = 100;
numDays = length(trainDays);

maxEpochs = 5;
miniBatchSize = 24;

%% Behind-the-scenes stuff

layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');

%% Train network

net = trainNetwork(trainData',trainLabels,layers,options);
% net = trainNetwork(a,b,layers,options);
%% Test network

predict = classify(net, testData, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');

testLabels = flip(testLabels');

for i = 1:length(predict)
    acc(i) = sum(predict{i} == testLabels{i}) ./ numel(testLabels{i});
end

overall_acc = mean(acc);

%% Plot results

% testLabelDoubles = flip(testLabelDoubles');

for i = 1:length(testData)
    rate = testData{1,i}(2,:);
    band_rate = rate' .* testLabelDoubles{i,1};
    
    figure
    semilogy(testData{1,i}(1,:),rate)
    hold on
    semilogy(testData{1,i}(1,:),band_rate,'g','LineWidth',1.5)
    
    
    title(sprintf('Precipitation Bands for Day %i',testDays(i)))
    xlabel('Time [s]')
    ylabel('Count Rate (per 100 ms, log-scaled)')
    legend('Count rate','Precip bands')
end
