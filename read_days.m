% Author: Ryan Hughes
% Purpose: Read data from a given day of 2005 into a cell array of doubles
% Input:
%       days: array of days to analyze
% Output:
%       dailyData: cell array of telemetry data to use as features in NN
% 
% Note: Days from a year other than 2005 can be modified by removing '2005'
%       from the filenames and tacking the year onto the beginning of the 
%       'days' input (e.g. 2005347 for year 2005, day 347)
function [dailyData,dailyData_unsorted] = read_days(days)

for i = 1:length(days)
    rateFile = sprintf('SAMPEXdata/rateDataByDay/hhrr2005%d.txt',days(i));
    attFile = sprintf('SAMPEXdata/attDataByDay/hhrr2005%d_att.txt',days(i));
    
    tempRateData = readmatrix(rateFile,'NumHeaderLines',1);
    tempAttData = readmatrix(attFile,'NumHeaderLines',74);
    
    rate.t{i} = tempRateData(:,1) ./ 3600; %h, time
    rate.rate{i} = tempRateData(:,6); %SSD4 from Time to Time + 100 ms
    
    att_raw.t{i} = tempAttData(:,3) ./ 3600; %seconds of day (1-86400)
    att_raw.long{i} = tempAttData(:,4); %deg, longitude in GEO coords. (0-360)
    att_raw.lat{i} = tempAttData(:,5); %deg, latitude in GEO coords. (-90-90)
    att_raw.alt{i} = tempAttData(:,6); %km, altitude in GEO coord. system
    att_raw.Lshell{i} = tempAttData(:,7); %Earth radii, L-shell param.
    att_raw.Bmag{i} = tempAttData(:,8); %gauss, Model field magnitude
    att_raw.MLT{i} = tempAttData(:,9); %hr, magnetic local time
    att_raw.inv_lat{i} = tempAttData(:,10); %deg, invariant latitude (0-90)
    att_raw.LC1{i} = tempAttData(:,11); %deg, loss cone 1
    att_raw.LC2{i} = tempAttData(:,12); %deg, loss cone 2
    att_raw.eqB{i} = tempAttData(:,13); %gauss, magnitude of mag. field at mag. equator
    att_raw.N100B{i} = tempAttData(:,14); %gauss, magnitude of mag. field at north 100km
    att_raw.S100B{i} = tempAttData(:,15); %gauss, magnitude of mag. field at south 100km
    att_raw.SAA{i} = tempAttData(:,16); %boolean, South Atlantic Anomaly Flag (drop true)
    att_raw.PA{i} = tempAttData(:,17); %deg, pitch angle of a particle
    att_raw.att_flag{i} = tempAttData(:,18); %boolean, attitude data quality flag

    % 'de-loop' longitude data for interpolation (will be reversed later)
    % this is to avoid undesired interpolation on 360->0 'skips'
    longMaxIndices = [find(diff(att_raw.long{i})<0); length(att_raw.long{i})]; %indices of max values before skipping
    longMaxes = att_raw.long{i}(longMaxIndices); %check that longMaxIndices occur on max values
    for j = 2:length(longMaxIndices)
        att_raw.long{i}(longMaxIndices(j-1)+1:longMaxIndices(j)) = ...
            att_raw.long{i}(longMaxIndices(j-1)+1:longMaxIndices(j))+360*(j-1);
    end
    
    % cubic interpolation
    % (interp1 also matches time vectors and adjusts data accordingly)
    att.t{i} = interp1(att_raw.t{i},att_raw.t{i},rate.t{i},'pchip');
    att.long{i} = interp1(att_raw.t{i},att_raw.long{i},att.t{i},'pchip');
    att.lat{i} = interp1(att_raw.t{i},att_raw.lat{i},att.t{i},'pchip');
    att.inv_lat{i} = interp1(att_raw.t{i},att_raw.inv_lat{i},att.t{i},'pchip');
    att.alt{i} = interp1(att_raw.t{i},att_raw.alt{i},att.t{i},'pchip');
    att.Lshell{i} = interp1(att_raw.t{i},att_raw.Lshell{i},att.t{i},'pchip');
    att.Bmag{i} = interp1(att_raw.t{i},att_raw.Bmag{i},att.t{i},'pchip');
    att.MLT{i} = interp1(att_raw.t{i},att_raw.MLT{i},att.t{i},'pchip');
    att.LC1{i} = interp1(att_raw.t{i},att_raw.LC1{i},att.t{i},'pchip');
    att.LC2{i} = interp1(att_raw.t{i},att_raw.LC2{i},att.t{i},'pchip');
    att.eqB{i} = interp1(att_raw.t{i},att_raw.eqB{i},att.t{i},'pchip');
    att.N100B{i} = interp1(att_raw.t{i},att_raw.N100B{i},att.t{i},'pchip');
    att.S100B{i} = interp1(att_raw.t{i},att_raw.S100B{i},att.t{i},'pchip');
    att.SAA{i} = interp1(att_raw.t{i},att_raw.SAA{i},att.t{i},'pchip');

    % 're-loop' longitude data using modulus
    att.long{i} = mod(att.long{i},360);
    att_raw.long{i} = mod(att_raw.long{i},360); %in the spirit of keeping it as 'raw' data
    
    % drop SAA from rate data
    att.roundedSAA{i} = ceil(att.SAA{i}); %adjust for decimal values from interp
    rate.rate{i}(find(att.roundedSAA{i})) = 0; 
    
    % convert count rate data to single for memory space
    rate.singleRate{i} = cast(rate.rate{i},'single');
    
    % organize data by day rather than label
    dailyData_unsorted{i} = [rate.t{1,i}.'; rate.rate{1,i}.'; att.long{1,i}.';...
        att.lat{1,i}.'; att.inv_lat{1,i}.'; att.alt{1,i}.'; att.Lshell{1,i}.';...
        att.Bmag{1,i}.'; att.LC1{1,i}.'; att.LC2{1,i}.'; att.eqB{1,i}.';...
        att.N100B{1,i}.'; att.S100B{1,i}.'; att.roundedSAA{1,i}.'].';
end

% sort data for padding
numDays = numel(dailyData_unsorted);

for i = 1:numDays
    sequence = dailyData_unsorted{i};
    sequenceLengths(i) = length(sequence);
end

[~, iSorted] = sort(sequenceLengths);
dailyData = dailyData_unsorted(iSorted);


end