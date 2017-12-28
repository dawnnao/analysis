clear;clc;close all

%% import mat file
dataPath1 = 'D:\continuous_monitoring\analysis\xihoumen\stats_DPM_2017_12_21_22_04.mat';
load(dataPath1)
rmsAll1 = rmsAll; clear rmsAll
maxAll1 = maxAll; clear maxAll
minAll1 = minAll; clear minAll

dataPath2 = 'D:\continuous_monitoring\analysis\xihoumen\stats_DPM_2017_12_27_09_26.mat';
load(dataPath2)
rmsAll2 = rmsAll; clear rmsAll
maxAll2 = maxAll; clear maxAll
minAll2 = minAll; clear minAll

rmsAll = cat(1, rmsAll1, rmsAll2);
maxAll = cat(1, maxAll1, maxAll2);
minAll = cat(1, minAll1, minAll2);

%% reset
dir.saveRoot = 'D:/continuous_monitoring/analysis/xihoumen/plot_together/';
dir.figSave = dir.saveRoot;
dateStartInput = '2013-01-01';
dateEndInput = '2017-11-30';

%% plot basic stats -- make label
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;

xTickDispl = [];
xLabel = [];
countLable = 1;
for d = dateStart : dateEnd
    dateVecTemp = datevec(d);
    if dateVecTemp(1, 2) == 1 && dateVecTemp(1, 3) == 1
        xTickDispl = cat(2, xTickDispl, d-dateStart+1);
        xLabel{countLable} = datestr(d, 'yyyy-mm-dd');
        countLable = countLable + 1;
    elseif dateVecTemp(1, 3) == 1 && mod(dateVecTemp(1, 2), 2) == 1
        xTickDispl = cat(2, xTickDispl, d-dateStart+1);
        xLabel{countLable} = datestr(d, 'mm-dd');
        countLable = countLable + 1;
    elseif dateVecTemp(1, 3) == 1 && mod(dateVecTemp(1, 2), 2) == 0
        xTickDispl = cat(2, xTickDispl, d-dateStart+1);
        xLabel{countLable} = ''; % datestr(d, 'mm-dd');
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
    
    plot(maxAll(:,f), 'r', 'LineWidth', 1);
    hold on
    plot(rmsAll(:,f), 'b', 'LineWidth', 1);
    hold on
    plot(minAll(:,f), 'g', 'LineWidth', 1);
    hold off
    legend('MAX', 'RMS', 'MIN', 'Location', 'bestoutside')
    % axis control
    ax = gca;
    ax.XTick = xTickDispl;
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 23;  % rotation
    ax.YLabel.String = 'Displ. (mm)';                                      
    ax.Title.String = [sprintf('%s: ', nickName) titles{f}];
    ax.Units = 'normalized';
    ax.Position = [0.05 0.19 0.9 0.72];  % control ax's position in figure
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    xlim([1  size(rmsAll, 1)]);
    grid on
    % size control
    fig = gcf;
    fig.Units = 'pixels';
    fig.Position = [20 550 2500 440];  % control figure's position
    fig.Color = 'w';
    
    % save
    saveas(gcf, sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, f));
    saveas(gcf, sprintf('%s/stats_%s_chan_%d_basic.fig', dir.figFolderBasic, nickName, f));
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
%     saveas(gcf, sprintf('%s/stats_%s_chan_%d_freq.fig', dir.figFolderFreq, nickName, f));
%     fprintf('\nfreq %s channel %d saved.\n', nickName, f);
%     close
% end

%%
run('stats_makeDocFile_DPM.m');



