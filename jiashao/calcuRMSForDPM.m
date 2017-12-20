function  rmsBlocks = calcuRMSForDPM(data, n)
% Split data to n blocks and calculate RMS for each block. In each block,
% RMS values are calculated by each column.

% clean outliers
for c = 1 : size(data, 2)
    data(abs(data(:,c)) > 2000, c) = NaN; %nanmedian(data(:,c));
    data(abs(data(:,c)) < 100, c) = NaN; %nanmedian(data(:,c));
end

rmsBlocks = [];
numSub = size(data,1)/n;
dataSplit = mat2cell(data, numSub*ones(1,n));

for nn = 1 : n
    rmsTemp = nanrms(dataSplit{nn});
    rmsBlocks = cat(1, rmsBlocks, rmsTemp);
end

end