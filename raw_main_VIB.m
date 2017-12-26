clear;clc;close all

%% settings
% jiashao
% dir.folderSource = 'H:/jiashao/jiashao_2014/netmanagervib/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jiashao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2014-12-31';
% dimens = [180000 55]; % [number of points , number of channels]

% hangzhouwan BHD
dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/BHD/';
dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_beihangdao/';
dir.figSave = dir.saveRoot;
dateStartInput = '2014-01-03';
dateEndInput = '2014-01-03';
dimens = [180000 55]; % [number of points , number of channels]

% % hangzhouwan NHD
% dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/NHD/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_nanhangdao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2016-12-31';
% dimens = [180000 31]; % [number of points , number of channels]

% % xihoumen
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/xihoumen/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-03';
% dateEndInput = '2013-01-03';
% dimens = [90000 99]; % [number of points , number of channels]

% % jintang
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jintang/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-01';
% dateEndInput = '2016-12-31';
% dimens = [90000 99]; % [number of points , number of channels]

%%
nickName = 'VIB';
nBlocks = 6; % number of blocks for hour-data

% orderPlot = {[3:11 16:21 28:36] [45:49] [50:55] [1:2 12:15 22:27 37:44]};  % jiashao
% run('titleNames_jiashao.m')     

orderPlot = {[10:14 26:35 1:9 36 48:55], [15:22 37:44], [45:47 23:25]};  % hangzhouwan BHD
run('titleNames_hangzhouwan_BHD.m')                                              

% orderPlot = {[1:7 19:28] [8:15] [16:18 29:31]};                          % hangzhouwan NHD
% run('titleNames_hangzhouwan_NHD.m')

% orderPlot = {[1:30] [31:50]};                                              % xihoumen
% run('titleNames_xihoumen.m')

% orderPlot = {[71:99]};                                                   % jintang
% run('titleNames_jintang.m')

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
xTickDispl = (xTickDispl - 1) * 25 + 1;                                    % change here                        

%% plot basic stats -- plot and save figures
dir.figFolderBasic = sprintf('%s/stats_%s_%s_basic/', dir.figSave, nickName, dateSave);
if ~exist(dir.figFolderBasic, 'dir')
    mkdir(dir.figFolderBasic)
end

titles = getfield(titleName, nickName);
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
    ax.Title.String = [sprintf('%s: ', nickName) titles{f}];
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
%     saveas(gcf, sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, f));
%     fprintf('\nstats %s channel %d saved.\n', nickName, f);
%     close
end



