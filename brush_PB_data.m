%% Housekeeping
clear; close all; clc

%% Read & split data
day = 347;
data = read_days(day);

t = data{1,1}(1,:);
rate = data{1,1}(2,:);

n = length(rate);
bins = floor(linspace(1,n,49)); %half-hour increments

%% Plot & brush data

tPB = {};
ratePB = {};
PBcount = 0;
bInd_all = [];

for i = 1:length(bins)-1
    % plot count rate of relevant section
    figure
    h = semilogy(t(bins(i):bins(i+1)),rate(bins(i):bins(i+1)));
    hold on
    title('Count Rate Time Window')
    xlabel('Time [h]')
    ylabel('Count Rate (per 100ms, log-scaled')
    
    % ask number of bands to account for
    numBands = input('How many bands are visible in this time window?\n');
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
    
    this_t = t(bins(i):bins(i+1));
    this_rate = rate(bins(i):bins(i+1));
    
    tB = this_t(bInd);
    rateB = this_rate(bInd);
    tPB{PBcount} = tB;
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
            bInd_all = [bInd_all bInd];
            PBcount = PBcount + 1;

            this_t = t(bins(i):bins(i+1));
            this_rate = rate(bins(i):bins(i+1));

            tB = this_t(bInd);
            rateB = this_rate(bInd);
            tPB{PBcount} = tB;
            ratePB{PBcount} = rateB;
        end
    end
    close
end

%% Save data
% brushLabels = matfile('brushLabels.mat');
brushLabels = load('brushLabels.mat');
labels = brushLabels.labels;
labels{length(labels)+1 } = categorical(bInd_all);
save brushLabels labels