%% Housekeeping
clear; close all; clc

%% Load figure
x = linspace(1,30);
y = x.^2 + 3*x + 4;
figure
hold on
h = plot(x,y);
brush on
pause

%% Handle brush data
brushedInd = logical(h.BrushData);
xB = x(brushedInd);
yB = y(brushedInd);
plot(xB,yB)


% t=0:0.2:25; plot(t,sin(t),'.-');
% brush on
% pause
% hBrushLine = findall(gca,'tag','Brushing');
% brushedData = get(hBrushLine, {'Xdata','Ydata'});
% brushedIdx = ~isnan(brushedData{1});
% brushedXData = brushedData{1}(brushedIdx);
% brushedYData = brushedData{2}(brushedIdx);