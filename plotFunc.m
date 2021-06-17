function [] = plotFunc(t,rate,tShort,rateShort,bandStart,bandEnd,...
    avgShort,crit1,crit2,MB)%,PB2,humps)

% Author: Ryan Hughes
% Purpose: General plotting function for DataProcessingScript.m
% Input:
%       t & tShort: time series data (and shortened)
%       rate & rateShort: count rate data (and shortened)
%       bandStart: start indices of identified precipitation bands
%       bandEnd: end indices of identified precipitation bands
%       avgShort: short-window average of count rate
%       crit1 & crit2: logical arrays depicting where crits are met
%       MB: data struct with all pertinent microburst variables
%       
% Output:
%       Plots

% rate vs. time
figure
semilogy(t,rate)
hold on
semilogy(MB.tShort(MB.burstIndex),MB.rateShort(MB.burstIndex),'r*','MarkerSize',7)
semilogy(tShort(bandStart),rateShort(bandStart),'gd','MarkerSize',7)
semilogy(tShort(bandEnd),rateShort(bandEnd),'ms','MarkerSize',7)
% semilogy(t.*humps,rate.*humps,'k')
% semilogy(t,SAA*9000,"LineWidth",1.5)
title("Count Rate vs. Time")
xlabel("Time [h]"); ylabel("Count Rate (per 100ms, log-scaled)")
legend("Count rate","Microburst indicator","PB start","PB end")

% w/ baselines and PB criteria
crit1rate = 100.*crit1;
crit2rate = 120.*crit2;

mergedCrit = crit1 & crit2;
mergedCrit = mergedCrit | movPercent(mergedCrit,4,75);
mergedCritRate = 110.* mergedCrit;
movPercentRate = 130.* movPercent(mergedCrit,4,75);

figure
% semilogy(t,B20,'--','LineWidth',1.5) %baselines
% semilogy(PB2.tShort,1.7*PB2.Bshort,'LineWidth',1.5);
semilogy(tShort,avgShort,'--','LineWidth',1.5) %short-window avg
hold on
semilogy(t,rate) %count rate
semilogy(tShort,mergedCritRate,'LineWidth',1.2)
semilogy(tShort,movPercentRate,'LineWidth',1.2)
semilogy(tShort(bandStart),rateShort(bandStart),'gd','MarkerSize',7)
semilogy(tShort(bandEnd),rateShort(bandEnd),'ms','MarkerSize',7)
title("Baselines and Criteria")
xlabel("Time [h]"); ylabel("Count rate")
legend("Short window avg","Count rate","Merged Criteria", "Moving % Criteria",...
    "PB start","PB end")

% compare PB algorithms
% figure
% semilogy(t,rate)
% hold on
% semilogy(t(bandStart),rate(bandStart),'gd','MarkerSize',7)
% semilogy(t(bandEnd),rate(bandEnd),'gs','MarkerSize',7)
% semilogy(tShort(PB2.lowStart),rateShort(PB2.lowStart),'md','MarkerSize',7)
% semilogy(tShort(PB2.lowEnd),rateShort(PB2.lowEnd),'ms','MarkerSize',7)
% semilogy(tShort(PB2.midStart),rateShort(PB2.midStart),'bd','MarkerSize',7)
% semilogy(tShort(PB2.midEnd),rateShort(PB2.midEnd),'bs','MarkerSize',7)
% title("Primary and Alternate Precip Bands")
% xlabel("Time [h]"); ylabel("Count rate (per 100 ms)")
% legend("Count rate", "PB start", "PB end", "short PB start", "short PB end",... 
%     "mid PB start", "mid PB end");


end