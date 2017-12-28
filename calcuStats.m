function  outBlocks = calcuStats(item, data, n, nickName, column, referPoint)
% Split data to n blocks and calculate max value for each block. In each block,
% max values are calculated by each column.

% clean outliers
switch nickName
    case 'DPM'
        for c = 1 : size(data, 2)
            data(abs(data(:,c)) > 5000, c) = NaN; % jiashao: 2000 | zhoushan: 5000 | hangzhouwan: 2000
            data(abs(data(:,c)) < 1, c) = NaN;    % jiashao:  100 | zhoushan:    1 | hangzhouwan:    1
        end
    case 'VIB'
        for c = 1 : size(data, 2)
            data(abs(data(:,c)) > 1000, c) = 0;    % jiashao:  100 | zhoushan: 1000 | hangzhouwan:  100
        end
    case 'HPT'
        for c = 1 : size(data, 2)
            data(abs(data(:,c)) > 2000, c) = NaN; % jiashao: 9000 | zhoushan:      | hangzhouwan: 2000
            data(abs(data(:,c)) < 1, c) = NaN;    % jiashao:    1 | zhoushan:      | hangzhouwan:    1
        end
        data(:, column) = data(:, column) - data(:, referPoint);
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
            
            maxTemp = nanmax(dataSplit{nn});
            minTemp = nanmin(dataSplit{nn});
            rmsTemp = nanrms(dataSplit{nn});
            
            for c = 1 : size(data, 2)
                if sign(maxTemp(c))*sign(rmsTemp(c)) < 0 && sign(minTemp(c))*sign(rmsTemp(c)) < 0
                    rmsTemp(c) = -rmsTemp(c);
                end
            end
            
            rmsBlocks = cat(1, rmsBlocks, rmsTemp);
        end
        outBlocks = rmsBlocks;
end

end