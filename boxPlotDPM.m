clear;clc;close all

%% settings
dir.folderSource = 'D:\continuous_monitoring\data_hangzhouwan_beihangdao\';
dateStartInput = '2014-01-01';
dateEndInput = '2014-01-05';

nickName = {'DPM'};
dimens = [36000 13]; % [number of points , number of channels]
%% plots
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);     % convert to serial number (count from year 0000)
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
count = 1;
for d = dateStart : dateEnd
    string = datestr(d);
    
    for h = 0 : 23
        dateVec(count, :) = datevec(string,'dd-mmm-yyyy');
        dateVec(count, 4) = h;
        dateSerial(count, 1) = datenum(dateVec(count,:));
        
        dir.dateFolderRead = sprintf('%d-%02d-%02d\\', dateVec(count,1), dateVec(count,2), dateVec(count,3));
        
        % read file and plot
        if exist([dir.folderSource dir.dateFolderRead], 'dir')
            dir.fileRead = sprintf('%d-%02d-%02d %02d-%s.mat', ...
                    dateVec(count,1), dateVec(count,2), dateVec(count,3), dateVec(count,4), nickName{1});
            
            % load file
            if exist([dir.folderSource dir.dateFolderRead dir.fileRead], 'file')
                dataTemp = load([dir.folderSource dir.dateFolderRead dir.fileRead]);
                fprintf('\n%s copied.\n', dir.fileRead)
            else
                fprintf('\n%s no such file.\n', dir.fileRead)
                % fill with NaN
                dataTemp = NaN(dimens);
            end
            
            % separate data column
            for f = 1 : dimens(2)
                
                dataSplit{f}(:, count) = dataTemp.data(:, f);
                dataSplit{f}(:, 1:count-1) = NaN;
            end
            clear dataTemp
            
            % plot each column
            for f = 1 : dimens(2)
                figure(f)
                boxplot(dataSplit{f});
                hold on
            end
            clear dataSplit
            
            
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
%             % fill with NaN
%             dataTemp = NaN(dimens);
        end
        count = count + 1;
        
        
    end
    
    
end
