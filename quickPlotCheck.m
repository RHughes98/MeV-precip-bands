function [tally,mislabelIndex] = quickPlotCheck(bandStart,bandEnd,rate,t,...
    avg,crit1,crit2)

if length(bandStart) ~= length(bandEnd)
    error("Mismatching band endpoints!");
end

% instantiate tally struct
tally.correct = 0; tally.mislabel = 0;

% mislabels to pass back to main script
mislabelIndex = [];

% axis limit margin in plots
plotOffset = 1500; %indices

% rate counts where criteria are met
crit1avgRate = avg.*crit1+1;
crit2avgRate = avg.*crit2-1;

numBands = length(bandStart); %number of PBs
for i = 1:numBands  
%     plot relevant section
    figure
    semilogy(t(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),...
        rate(bandStart(i)-plotOffset:bandEnd(i)+plotOffset))
    hold on
%     semilogy(t(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),...
%         baseline(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),'LineWidth',1.5)
    semilogy(t(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),...
        avg(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),'LineWidth',1.5)
    semilogy(t(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),...
        crit1avgRate(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),'.')
    semilogy(t(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),...
        crit2avgRate(bandStart(i)-plotOffset:bandEnd(i)+plotOffset),'.')
    semilogy(t(bandStart(i)),rate(bandStart(i)),'g*','MarkerSize',7)
    semilogy(t(bandEnd(i)),rate(bandEnd(i)),'m*','MarkerSize',7)
    title("Precipitation Band Check")
    xlabel("Time [h]"); ylabel("Count Rate (per 100 ms)")
    legend("Count rate","Avg","Criteria 1","Criteria 2","PB start","PB end")
    
%     collect user evaluation
    response = getPBinput();
        
%     increment tally accordingly
    if response == 1 %correct label
        tally.correct = tally.correct + 1;
    elseif response == 0 %mislabel
        tally.mislabel = tally.mislabel + 1;
        mislabelIndex = [mislabelIndex, i];
    end
    
    close
    
end

end