clear;clc;close all

%% settings
% % jiashao
% dir.folderSource = 'H:/jiashao/jiashao_2014/netmanagernj/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jiashao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2014-12-31';
% dimens = [3600 71]; % [number of points , number of channels]
% run('referPoints_jiashao.m');

% hangzhouwan BHD
dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/BHD/';
dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_beihangdao/';
dir.figSave = dir.saveRoot;
dateStartInput = '2014-01-03';
dateEndInput = '2014-01-03';
dimens = [36000 36]; % [number of points , number of channels]
run('referPoints_hangzhouwan_BHD.m');

% % hangzhouwan NHD
% dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/NHD/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_nanhangdao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2016-12-31';
% dimens = [36000 18]; % [number of points , number of channels]
% run('referPoints_hangzhouwan_NHD.m');

% % xihoumen has no HPT!
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/xihoumen/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-01';
% dateEndInput = '2016-12-31';
% dimens = []; % [number of points , number of channels]
% run('referPoints_xihoumen.m');

% % jintang
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jintang/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-01';
% dateEndInput = '2016-12-31';
% dimens = [3600 78]; % [number of points , number of channels]
% run('referPoints_jintang.m');

%%
% orderPlot = {[1:46 70:71], [47:59]};                                     % jiashao
% run('titleNames_jiashao.m')
% column = [min(cell2mat(orderPlot)) : max(cell2mat(orderPlot))];

orderPlot = {[1:36]};                                                    % hangzhouwan BHD
run('titleNames_hangzhouwan_BHD.m')
columnHPT = [1:36];

% orderPlot = {[1:18]};                                                    % hangzhouwan NHD
% run('titleNames_hangzhouwan_NHD.m')

% no HPT for xihoumen

% orderPlot = {[29:74]};                                                     % jintang
% run('titleNames_jintang.m')
% columnHPT = [29:74];

%%
nickName = 'HPT';
nBlocks = 6; % number of blocks for hour-data
referPoints = getfield(referPoint, nickName);

%% computation
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
countBasic = 1;
countFreq = 1;
rawAll = [];

for d = dateStart : dateEnd
    string = datestr(d);
    
    for h = 0 : 23
        dateVec(countBasic, :) = datevec(string,'dd-mmm-yyyy');
        dateVec(countBasic, 4) = h;
        dateSerial(countBasic, 1) = datenum(dateVec(countBasic,:));
        
        dir.dateFolderRead = sprintf('%d-%02d-%02d\\', dateVec(countBasic,1), dateVec(countBasic,2), dateVec(countBasic,3));
        % read file and plot
        if exist([dir.folderSource dir.dateFolderRead], 'dir')
            dir.fileRead = sprintf('%d-%02d-%02d %02d-%s.mat', ...
                    dateVec(countBasic,1), dateVec(countBasic,2), dateVec(countBasic,3), dateVec(countBasic,4), nickName);
            % load file
            if exist([dir.folderSource dir.dateFolderRead dir.fileRead], 'file')
                dataTemp = load([dir.folderSource dir.dateFolderRead dir.fileRead]);
                fprintf('\n%s imported.\n', dir.fileRead)
            else
                fprintf('\n%s no such file.\n', dir.fileRead)
                % fill with NaN
                dataTemp.data = NaN(dimens);
            end
            
            dataTemp.data(abs(dataTemp.data) < 1) = NaN; % clean outliers
            
            fprintf('\nStacking raw data...\n')
            rawAll = cat(1, rawAll, dataTemp.data);
            
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
        end
        countBasic = countBasic + 1;
    end
end
countBasic = countBasic - 1;

%% save data
if ~exist(dir.saveRoot, 'dir')
    mkdir(dir.saveRoot)
end

formatOut = 'yyyy_mm_dd_HH_MM';
dateSave = datestr(datetime('now'), formatOut);
% save(sprintf('%s/stats_%s_%s.mat', dir.saveRoot, nickName, dateSave));
% fprintf('\nData saved.\n')

%% plot basic stats -- make label
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
                if mod(dateVecTemp(1, 4), 24) == 0 && dateVecTemp(1, 5) == 0 && dateVecTemp(1, 6) == 0
                    xTickDispl = cat(2, xTickDispl, countPoint);
                    xLabel{countLable} = datestr(dateVecTemp, 'mm-dd');
                    if countLable == 1
                        xLabel{countLable} = datestr(dateVecTemp, 'yyyy mm-dd');
                    end
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
xTickDispl = (xTickDispl - 1) * 1 + 1;                                     % change here

% plot basic stats -- plot and save figures
dir.figFolderBasic = sprintf('%s/stats_%s_%s_basic/', dir.figSave, nickName, dateSave);
if ~exist(dir.figFolderBasic, 'dir')
    mkdir(dir.figFolderBasic)
end

titles = getfield(titleName, nickName);
for f = cell2mat(orderPlot)
    fprintf(sprintf('\nPlotting figure %d...\n', f))
    figure(f)
    
    plot(rawAll(:,f), 'b');
    legend('RAW', 'Location', 'bestoutside')
    % axis control
    ax = gca;
    ax.XTick = xTickDispl;
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    ax.YLabel.String = 'Deflection (mm)';
    ax.Title.String = [sprintf('%s: ', nickName) titles{f}];
    ax.Units = 'normalized';
    ax.Position = [0.05 0.18 0.9 0.73];  % control ax's position in figure
%     ax.Position = [0.16 0.13 0.82 0.82];  % control ax's position in figure
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    xlim([1  size(rawAll, 1)]);
    grid on
    % size control
    fig = gcf;
    fig.Units = 'pixels';
    fig.Position = [20 50 2500 440];  % control figure's position
%     fig.Position = [20 50 1000 800];  % control figure's position
    fig.Color = 'w';
    
    % save
%     saveas(gcf, sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, f));
%     fprintf('\nstats %s channel %d saved.\n', nickName, f);
%     close
end

%%
% run('stats_makeDocFile_HPT.m');



