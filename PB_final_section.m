%% Precipitation bands 

% time windows for moving avg.
PB.avgWindow = 20*10; %20 s, running avg time window
PB.avgWindowShort = 2*10; %2 s, running avg short window

% moving avg. count rate (standard and short-window)
PB.avg = movmean(rate.rate5,PB.avgWindow,'Endpoints','fill');
PB.avgShort = movmean(rate.rate5,PB.avgWindowShort,'Endpoints','fill');

% shifted avg. for plotting
% PB.shiftedAvg = 

% avg.-based criteria
PB.critAvg = PB.avgShort > 1.2 * PB.avg;

% correlation coefficient-based criteria
PB.dataLength = length(PB.avg);
PB.movCC = zeros(PB.dataLength,1);
PB.CCwindow = 5*10; %5 s, running CC time window
for i = (PB.CCwindow+1):PB.dataLength-(PB.CCwindow-1)
    PB.tmpCC = corrcoef(PB.avgShort(i-PB.CCwindow:i+PB.CCwindow-1),...
        PB.avg(i-PB.CCwindow:i+PB.CCwindow-1));
    PB.movCC(i) = PB.tmpCC(2);
end
PB.critCC = PB.movCC < .955;

% function calls
% [PB.bandStart, PB.bandEnd] = PBands(PB.critAvg,PB.critCC,rate.rate5,5,[]);
[PB.bandStart, PB.bandEnd] = mergedCritBands(PB.critAvg,PB.critCC,rate.rate5,5,[]);