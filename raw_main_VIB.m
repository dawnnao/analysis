clear;clc;close all

%% settings
dir.folderSource = 'H:\jiashao\jiashao_2014\netmanagervib\';
dir.matSave = 'D:\continuous_monitoring\analysis\jiashao\matFiles\';
dir.figSave = 'D:\continuous_monitoring\analysis\jiashao\figures\';
dateStartInput = '2014-01-08';
dateEndInput = '2014-01-08';
formatIn = 'yyyy-mm-dd';

nickName = {'VIB'};
dimens = [180000 55]; % [number of points , number of channels]            % change here

%% plots
dateStart = datenum(dateStartInput, formatIn);
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
count = 1;
rawAll = [];

for d = dateStart : dateEnd
    string = datestr(d);
    
    for h = 13 : 14 % 0 : 23
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
                dataTemp.data = NaN(dimens);
            end
            
            fprintf('\nStacking raw data...\n')
            rawAll = cat(1, rawAll, dataTemp.data);
            
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
        end
        count = count + 1;
    end
end

%% save data
if ~exist(dir.matSave, 'dir')
    mkdir(dir.matSave)
end

formatOut = 'yyyy_mm_dd_HH_MM';
dateSave = datestr(datetime('now'), formatOut);
% save(sprintf('%s/data_raw_VIB_%s.mat', dir.matSave, dateSave));
% fprintf('\nData saved.\n')

%% make label
xTickDispl = [];
xLabel = [];
countLable = 1;
countPoint = 1;
for d = dateStart : dateEnd
    dateVecTemp = datevec(d);
    for hour = 0 : 23
        dateVecTemp(1, 4) = hour;
        for minute = 0 : 59
            dateVecTemp(1, 5) = minute;
            for sec = 0 : 59
                dateVecTemp(1, 6) = sec;
                if mod(dateVecTemp(1, 5), 10) == 0 && dateVecTemp(1, 6) == 0
                    xTickDispl = cat(2, xTickDispl, countPoint);
                    xLabel{countLable} = datestr(dateVecTemp, 'mm-dd HH:MM:SS');
                    countLable = countLable + 1;
            %     elseif dateVecTemp(1, 3) == 1
            %         xTickDispl = cat(2, xTickDispl, d-dateStart+1);
            %         xLabel{countLable} = datestr(d, 'mm-dd');
            %         countLable = countLable + 1;
                end
                countPoint = countPoint + 1;
            end
        end
    end
    clear dateVecTemp
end
countLable = countLable - 1;
countPoint = countPoint - 1;
% match with the point number of rmsAll
xTickDispl = (xTickDispl - 1) * 50 + 1;                                    % change here

%% plot and save figures
dir.figFolder = sprintf('%s/figures_raw_VIB_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

run('titleNames.m')
orderPlot = {52}; % {[3:11 16:21 28:36] [45:49] [50:55] [1:2 12:15 22:27 37:44]};  % change here
for f = cell2mat(orderPlot)
    fprintf(sprintf('\nPlotting figure %d...\n', f))
    figure(f)
    
    plot(rawAll(:,f), 'b');
    % axis control
    ax = gca;
    ax.XTick = xTickDispl;
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    ax.YLabel.String = 'Accel. RMS (gal)';
    ax.Title.String = ['Vibration: ' titleName_VIB{f}];
    ax.Units = 'normalized';
    ax.Position = [0.16 0.13 0.82 0.82];  % control ax's position in figure
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    xlim([1  size(rawAll, 1)]);
    grid on
    % size control
    fig = gcf;
    fig.Units = 'pixels';
    fig.Position = [20 50 1000 800];  % control figure's position
    fig.Color = 'w';
    
    % save
    saveas(gcf, sprintf('%s/raw_VIB_chan_%d.tif', dir.figFolder, f));
    fprintf('\nraw VIB channel %d saved.\n', f);
end



