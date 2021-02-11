function [] = plotFunc(t,rate,tShort,rateShort,bandStart,bandEnd,...
    B20,avgShort,crit1,crit2,MB,PB2,humps)

% rate vs. time
figure
semilogy(t,rate)
hold on
semilogy(MB.tShort(MB.burstIndex),MB.rateShort(MB.burstIndex),'r*','MarkerSize',7)
semilogy(tShort(bandStart),rateShort(bandStart),'gd','MarkerSize',7)
semilogy(tShort(bandEnd),rateShort(bandEnd),'ms','MarkerSize',7)
semilogy(t.*humps,rate.*humps,'k')
% semilogy(t,SAA*9000,"LineWidth",1.5)
title("Count Rate vs. Time")
xlabel("Time [h]"); ylabel("Count Rate (per 100ms, log-scaled)")
legend("Count rate","Microburst indicator","PB start","PB end")

% w/ baselines and PB criteria
crit1rate = avgShort.*crit1 + 1;
crit2rate = avgShort.*crit2 - 1;

figure
semilogy(t,B20,'--','LineWidth',1.5) %baselines
hold on
% semilogy(PB2.tShort,1.7*PB2.Bshort,'LineWidth',1.5);
semilogy(tShort,avgShort,'--','LineWidth',1.5) %short-window avg
semilogy(t,rate) %count rate
semilogy(tShort(bandStart),rateShort(bandStart),'gd','MarkerSize',7)
semilogy(tShort(bandEnd),rateShort(bandEnd),'ms','MarkerSize',7)
semilogy(tShort,crit1rate,':','LineWidth',1.2)
semilogy(tShort,crit2rate,':','LineWidth',1.2)
title("Baselines and Criteria")
xlabel("Time [h]"); ylabel("Count rate")
legend("20% baseline","2.5 second avg","Count rate","PB start",...
    "PB end","Criteria 1","Criteria 2")

% compare PB algorithms
figure
semilogy(t,rate)
hold on
semilogy(t(bandStart),rate(bandStart),'gd','MarkerSize',7)
semilogy(t(bandEnd),rate(bandEnd),'gs','MarkerSize',7)
semilogy(tShort(PB2.lowStart),rateShort(PB2.lowStart),'md','MarkerSize',7)
semilogy(tShort(PB2.lowEnd),rateShort(PB2.lowEnd),'ms','MarkerSize',7)
semilogy(tShort(PB2.midStart),rateShort(PB2.midStart),'bd','MarkerSize',7)
semilogy(tShort(PB2.midEnd),rateShort(PB2.midEnd),'bs','MarkerSize',7)
title("Primary and Alternate Precip Bands")
xlabel("Time [h]"); ylabel("Count rate (per 100 ms)")
legend("Count rate", "PB start", "PB end", "short PB start", "short PB end",... 
    "mid PB start", "mid PB end");


end