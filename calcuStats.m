function  outBlocks = calcuStats(item, data, n, nickName, referPoint)
% Split data to n blocks and calculate max value for each block. In each block,
% max values are calculated by each column.

% clean outliers
switch nickName
    case 'DPM'
%         for c = 1 : size(data, 2)
%             data(abs(data(:,c)) > 2000, c) = NaN; %nanmedian(data(:,c));
%             data(abs(data(:,c)) < 100, c) = NaN; %nanmedian(data(:,c));
%         end
    case 'VIB'
        for c = 1 : size(data, 2)
            data(abs(data(:,c)) > 100, c) = 0; %nanmedian(data(:,c));
        end
    case 'HPT'
        for c = 1 : size(data, 2)
            data(abs(data(:,c)) > 9000, c) = NaN; %nanmedian(data(:,c));
        end
        data = data - data(:, referPoint);
end

numSub = size(data,1)/n;
dataSplit = mat2cell(data, numSub*ones(1,n));

% calculation
switch item
    case 'max'
        maxBlocks = [];
        for nn = 1 : n
            maxTemp = nanmax(dataSplit{nn});
            maxBlocks = cat(1, maxBlocks, maxTemp);
        end
        outBlocks = maxBlocks;
    case 'min'
        minBlocks = [];
        for nn = 1 : n
            minTemp = nanmin(dataSplit{nn});
            minBlocks = cat(1, minBlocks, minTemp);
        end
        outBlocks = minBlocks;
    case 'rms'
        rmsBlocks = [];
        for nn = 1 : n
            rmsTemp = nanrms(dataSplit{nn});
            rmsBlocks = cat(1, rmsBlocks, rmsTemp);
        end
        outBlocks = rmsBlocks;
end

end