clear;clc;close all

%% settings
% % jiashao
% dir.folderSource = 'H:/jiashao/jiashao_2014/netmanagernj/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jiashao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2014-12-31';
% dimens = [3600 54]; % [number of points , number of channels]

% hangzhouwan BHD
dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/BHD/';
dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_beihangdao/';
dir.figSave = dir.saveRoot;
dateStartInput = '2014-01-01';
dateEndInput = '2016-12-31';
dimens = [36000 13]; % [number of points , number of channels]

% % hangzhouwan NHD
% dir.folderSource = 'F:/hangzhouwan/hangzhouwan_2014-2016_mat/NHD/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/hangzhouwan_nanhangdao/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2014-01-01';
% dateEndInput = '2016-12-31';
% dimens = [36000 10]; % [number of points , number of channels]

% % xihoumen
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/xihoumen/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-01';
% dateEndInput = '2016-12-31';
% dimens = [3600 13]; % [number of points , number of channels]

% % jintang
% dir.folderSource = 'F:/zhoushan_2013-2016_mat_continuous/';
% dir.saveRoot = 'D:/continuous_monitoring/analysis/jintang/';
% dir.figSave = dir.saveRoot;
% dateStartInput = '2013-01-01';
% dateEndInput = '2016-12-31';
% dimens = [3600 13]; % [number of points , number of channels]

%%
nickName = 'DPM';
nBlocks = 6; % number of blocks for hour-data

% orderPlot = {[1:6], [7:54]};                                             % jiashao 
% run('titleNames_jiashao.m')                                                

orderPlot = {[1:10], [11:12], [13]};                                     % hangzhouwan BHD
run('titleNames_hangzhouwan_BHD.m')                                        

% orderPlot = {[1:9] [10]};                                                % hangzhouwan NHD
% run('titleNames_hangzhouwan_NHD.m')

% orderPlot = {[1:7]};                                                     % xihoumen
% run('titleNames_xihoumen.m')

% orderPlot = {[8:13]};                                                    % jintang
% run('titleNames_jintang.m')

%% computation
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
countBasic = 1;
countFreq = 1;
rmsAll = [];
maxAll = [];
minAll = [];
nfft = 1024;

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
            
            % basic stats
            fprintf('\nCalculating max, rms and min...\n')            
            maxBlocks = calcuStats('max', dataTemp.data, nBlocks, nickName);
            maxAll = cat(1, maxAll, maxBlocks);
            clear maxBlocks
            
            rmsBlocks = calcuStats('rms', dataTemp.data, nBlocks, nickName);
            rmsAll = cat(1, rmsAll, rmsBlocks);
            clear rmsBlocks
            
            minBlocks = calcuStats('min', dataTemp.data, nBlocks, nickName);
            minAll = cat(1, minAll, minBlocks);
            clear minBlocks
            
            if h == 0
                % compute frequency response
                dataTemp.data(abs(dataTemp.data) > 100) = 0; % clean outliers
                fprintf('\nComputing frequency response...\n')
                for f = cell2mat(orderPlot)
                    [pxx{f}(1:(nfft/2+1), countFreq), freq{f}(1:(nfft/2+1), countFreq)] = cpsd(dataTemp.data(:,f), dataTemp.data(:,f), ...
                        nfft, [], [], dimens(1)/3600);
                end
                countFreq = countFreq + 1;
                clear dataTemp
            end
            
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
        end
        countBasic = countBasic + 1;
    end
end
countBasic = countBasic - 1;
countFreq = countFreq - 1;

%% save data
if ~exist(dir.saveRoot, 'dir')
    mkdir(dir.saveRoot)
end

formatOut = 'yyyy_mm_dd_HH_MM';
dateSave = datestr(datetime('now'), formatOut);
save(sprintf('%s/stats_%s_%s.mat', dir.saveRoot, nickName, dateSave));
fprintf('\nData saved.\n')

%% plot basic stats -- make label
xTickDispl = [];
xLabel = [];
countLable = 1;
for d = dateStart : dateEnd
    dateVecTemp = datevec(d);
    if dateVecTemp(1, 2) == 1 && dateVecTemp(1, 3) == 1
        xTickDispl = cat(2, xTickDispl, d-dateStart+1);
        xLabel{countLable} = datestr(d, 'yyyy-mm-dd');
        countLable = countLable + 1;
    elseif dateVecTemp(1, 3) == 1
        xTickDispl = cat(2, xTickDispl, d-dateStart+1);
        xLabel{countLable} = datestr(d, 'mm-dd');
        countLable = countLable + 1;
    end
    clear dateVecTemp
end
countLable = countLable - 1;
% match with the point number of maxAll, rmsAll and minAll
xTickDispl = (xTickDispl - 1) * 24 * nBlocks + 1;                          

% plot basic stats -- plot and save figures
dir.figFolderBasic = sprintf('%s/stats_%s_%s_basic/', dir.figSave, nickName, dateSave);
if ~exist(dir.figFolderBasic, 'dir')
    mkdir(dir.figFolderBasic)
end

titles = getfield(titleName, nickName);
for f = cell2mat(orderPlot)
    fprintf(sprintf('\nPlotting figure %d...\n', f))
    figure(f)
    
%     plot(maxAll(:,f), 'r', 'LineWidth', 1);
%     hold on
%     plot(rmsAll(:,f), 'b', 'LineWidth', 1);
%     hold on
%     plot(minAll(:,f), 'g', 'LineWidth', 1);
%     hold off
%     legend('MAX', 'RMS', 'MIN', 'Location', 'bestoutside')
%     % axis control
%     ax = gca;
%     ax.XTick = xTickDispl;
%     ax.XTickLabel = xLabel;
%     ax.XTickLabelRotation = 23;  % rotation
%     ax.YLabel.String = 'Displ. (mm)';                                      
%     ax.Title.String = [sprintf('%s: ', nickName) titles{f}];
%     ax.Units = 'normalized';
%     ax.Position = [0.05 0.19 0.9 0.72];  % control ax's position in figure
%     set(gca, 'fontsize', 20);
%     set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
%     xlim([1  size(rmsAll, 1)]);
%     grid on
%     % size control
%     fig = gcf;
%     fig.Units = 'pixels';
%     fig.Position = [20 550 2500 440];  % control figure's position
%     fig.Color = 'w';
    
    % save
    saveas(gcf, sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, f));
    fprintf('\nstats %s channel %d saved.\n', nickName, f);
%     close
end

%% plot frequency response -- make label
% xTickDispl = [];
% xLabel = [];
% countLable = 1;
% for d = dateStart : dateEnd
%     dateVecTemp = datevec(d);
%     if dateVecTemp(1, 2) == 1 && dateVecTemp(1, 3) == 1
%         xTickDispl = cat(2, xTickDispl, d-dateStart+1);
%         xLabel{countLable} = datestr(d, 'yyyy-mm-dd');
%         countLable = countLable + 1;
%     elseif dateVecTemp(1, 3) == 1
%         xTickDispl = cat(2, xTickDispl, d-dateStart+1);
%         xLabel{countLable} = datestr(d, 'mm-dd');
%         countLable = countLable + 1;
%     end
%     clear dateVecTemp
% end
% countLable = countLable - 1;
% % match with the point number of rmsAll
% xTickDispl = (xTickDispl - 1) + 1;                                    
% 
% % plot frequency response -- plot and save figures
% dir.figFolderFreq = sprintf('%s/stats_%s_%s_freq/', dir.figSave, nickName, dateSave);
% if ~exist(dir.figFolderFreq, 'dir')
%     mkdir(dir.figFolderFreq)
% end
% 
% titles = getfield(titleName, nickName);
% for f = cell2mat(orderPlot)
%     fprintf(sprintf('\nPlotting figure %d...\n', f))
%     figure(f)
%     
%     contour(1:size(pxx{f}, 2), freq{f}(:,1), log(real(pxx{f})), 300);
%     colorbar('FontSize', 18, 'FontName', 'Times new roman');
%     colormap jet
%     % axis control
%     ax = gca;
%     ax.XTick = xTickDispl;
%     ax.XTickLabel = xLabel;
%     ax.XTickLabelRotation = 20;  % rotation
%     ax.YLabel.String = 'Frequency (Hz)';
%     ax.Title.String = [sprintf('%s: ', nickName) titles{f}];
%     ax.Units = 'normalized';
%     ax.Position = [0.05 0.18 0.9 0.73];  % control ax's position in figure
%     set(gca, 'fontsize', 20);
%     set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
%     xlim([1  size(pxx{1}, 2)]);
%     % size control
%     fig = gcf;
%     fig.Units = 'pixels';
%     fig.Position = [20 50 2500 440];  % control figure's position
%     fig.Color = 'w';
% %     pause(10)
%     
%     % save
%     saveas(gcf, sprintf('%s/stats_%s_chan_%d_freq.tif', dir.figFolderFreq, nickName, f));
%     fprintf('\nfreq %s channel %d saved.\n', nickName, f);
%     close
% end

%%
run('stats_makeDocFile_DPM.m');



