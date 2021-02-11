function [tally] = curveFitting(t,rate,VA)

% instantiate tally struct
tally.correct = 0; tally.mislabel = 0;

plotOffset = 1500; %indices

n = length(VA.start); %number of humps

% check for mismatching # of starts/ends
if length(VA.end) ~= n
    error('Humps must have same number of start and end indices')
end

for i = 1:n
    tShort = t(VA.start(i):VA.end(i));
    avgShort = VA.avg(VA.start(i):VA.end(i));
    rateShort = rate(VA.start(i):VA.end(i));
    
%     polynomial fit
    [p,~,mu] = polyfit(tShort,avgShort,8);
    yFit = polyval(p,tShort,[],mu);
    
%     smoothing spline fit
    fo = fitoptions('Method','SmoothingSpline','SmoothingParam',0.9999999415414687);
%     previous: 0.99999957
    spline = fit(tShort,rateShort,'SmoothingSpline',fo);
    splineFit = feval(spline,tShort);
    
%     Gaussian fit
%     gaussEqn = 'a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)';
%     startPoints = [2000 10 0 2000 10 0.004];
    gaussian = fit(tShort,rateShort,'gauss2');
    gaussFit = feval(gaussian,tShort);
    
%     Precipitation band finding
    crit1 = VA.avg(VA.start(i):VA.end(i)) > 1.2 * gaussFit;
    crit2 = ~isnan(VA.avg(VA.start(i):VA.end(i))); %placeholder criteria
    [bandStart,bandEnd,~] = beltBands(crit1,crit2,rate(VA.start(i):VA.end(i)),...
        5,[]); 
    
%     plot
    figure
    plot(t(VA.start(i)-plotOffset:VA.end(i)+plotOffset),...
        rate(VA.start(i)-plotOffset:VA.end(i)+plotOffset))
    hold on
%     semilogy(t(humps.start(i)-plotOffset:humps.end(i)+plotOffset),...
%         humps.avg(humps.start(i)-plotOffset:humps.end(i)+plotOffset),...
%         '--','LineWidth',1.25)
%     plot(t(VA.start(i)),rate(VA.start(i)),'gd','MarkerSize',7);
%     plot(t(VA.end(i)),rate(VA.end(i)),'ms','MarkerSize',7);
%     semilogy(t(humps.start(i):humps.end(i)),yFit,'LineWidth',1.25)
%     semilogy(tShort,splineFit,'r--','LineWidth',1.25)
    plot(tShort,gaussFit,'r--','LineWidth',1.25)
    plot(t(VA.start(i)-plotOffset:VA.end(i)+plotOffset),...
        VA.avg(VA.start(i)-plotOffset:VA.end(i)+plotOffset),'--','LineWidth',1.25)
    plot(tShort(bandStart),rateShort(bandStart),'gd','MarkerSize',7);
    plot(tShort(bandEnd),rateShort(bandEnd),'ms','MarkerSize',7);
    title("Curve-Fit PB Finding")
    xlabel("Time [h]"); ylabel("Count Rate (per 100 ms)");
    legend("Count Rate","Curve Fit","Avg","Band Start","Band End")
    
%     collect user evaluation
%     response = getPBinput();
    
%     increment tally accordingly
%     if response == 1 %correct label
%         tally.correct = tally.correct + 1;
%     elseif response == 0 %mislabel
%         tally.mislabel = tally.mislabel + 1;
% %         mislabelIndex = [mislabelIndex, i];
%     end
    

    close
end
    
end