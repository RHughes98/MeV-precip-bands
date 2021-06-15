% Author: Ryan Hughes
% Purpose: Prompt user to highlight all bands for a given day (in half-hour
%          increments), then save categorical data to .mat file
% Input:
%       day: numerical day in the year 2005 whose data will be observed
% Output:
%       labels: categorical vector of 1's and 0's corresponding to PB's
%                and uneventful data, respectively (saved to a .mat)
%% Housekeeping
clear; close all; clc

%% Read & split data
day = 365;
data = read_days(day);

t = data{1,1}(1,:);
rate = data{1,1}(2,:);

n = length(rate);
bins = floor(linspace(0,n,49)); %half-hour increments

%% Plot & brush data

tPB = [];
ratePB = {};
PBcount = 0;
bInd_all = [];

for i = 1:length(bins)-1
    % plot count rate of relevant section
    figure
    h = semilogy(t(bins(i)+1:bins(i+1)),rate(bins(i)+1:bins(i+1)));
    hold on
    title('Count Rate Time Window')
    xlabel('Time [h]')
    ylabel('Count Rate (per 100ms, log-scaled')
    
    % ask number of bands to account for
    numBands = input('How many bands are visible in this time window?\n');
    % NOTE: if user hits 'Enter' here without entering a number, expects a band
    if numBands == 0
        bInd_all = [bInd_all zeros(1,length(h.XData))];
        close
        continue
    end
    
    % get user brush input for first band
    brush on
    fprintf('Select the first precipitation band with the brush, then press any key to continue:\n')
    pause
    
    % handle brushed data
    bInd = logical(h.BrushData);
    bInd_all = [bInd_all bInd];
    PBcount = PBcount + 1;    
    
    % define current 'chunk' of data for observation
    this_t = t(bins(i)+1:bins(i+1));
    this_rate = rate(bins(i)+1:bins(i+1));
    
    % save logical data
    tB = this_t(bInd);
    rateB = this_rate(bInd);
    % tPB{PBcount} = tB;
    tPB = [tPB tB];
    ratePB{PBcount} = rateB;
    
    % get user brush input for subsequent bands
    if numBands > 1
        for b = 2:numBands
            % plot previously marked band
            semilogy(tB,rateB,'g','LineWidth',1.5)
            legend('Count Rate','Marked PBs')
            
            % get user brush input
            brush on
            fprintf('Select the next precipitation band with the brush, then press any key to continue:\n')
            pause
            
            % handle brushed data
            bInd = logical(h.BrushData);
            
            % increment total precip band count
            PBcount = PBcount + 1;

            this_t = t(bins(i)+1:bins(i+1));
            this_rate = rate(bins(i)+1:bins(i+1));

            tB = this_t(bInd);
            rateB = this_rate(bInd);
            % tPB{PBcount} = tB;
            tPB = [tPB tB];
            ratePB{PBcount} = rateB;
        end
        % handle brushed data
        bInd_all = [bInd_all bInd];
    end
    close
end

% match time stamps
bInd_all = ismember(t,tPB);

if length(bInd_all) ~= n
    error('Brush data is of unexpected length != n')
end

%% Save data
% brushLabels = matfile('brushLabels.mat');
brushLabels = load('brushLabels.mat');
labels = brushLabels.labels;
labels{length(labels)+1 } = categorical(bInd_all);
save brushLabels labels