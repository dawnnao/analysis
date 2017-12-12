function  rmsBlocks = calcuRMSForDPM(data, n)
% Split data to n blocks and calculate RMS for each block. In each block,
% RMS values are calculated by each column.

data(abs(data) > 9900) = 0; % clean outliers

rmsBlocks = [];
numSub = size(data,1)/n;
dataSplit = mat2cell(data, numSub*ones(1,n));

for nn = 1 : n
    rmsTemp = rms(dataSplit{nn});
    rmsBlocks = cat(1, rmsBlocks, rmsTemp);
end

end