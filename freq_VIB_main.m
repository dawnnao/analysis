% clear;clc;close all
% 
% %% settings
% dir.folderSource = 'D:\continuous_monitoring\data_hangzhouwan_beihangdao\';
% dir.matSave = 'D:\continuous_monitoring\analysis\matFiles\';
% dir.figSave = 'D:\continuous_monitoring\analysis\figures\';
% dateStartInput = '2014-01-01';
% dateEndInput = '2016-12-31';
% 
% nickName = {'VIB'};
% dimens = [180000 55]; % [number of points , number of channels]
% 
% % downSampRatio = 500; % decrease sampling rate by interger factor
% % endOfMonthSerial = [getSerialDateOfMonthEnd(2014, 1:12, 1),...
% %                     getSerialDateOfMonthEnd(2015, 1:12, 1),...
% %                     getSerialDateOfMonthEnd(2016, 1:12, 1)];
% 
% %% plots
% % initialization
% formatIn = 'yyyy-mm-dd';
% dateStart = datenum(dateStartInput, formatIn);     % convert to serial number (count from year 0000)
% dateEnd   = datenum(dateEndInput, formatIn);
% dayTotal = dateEnd-dateStart+1;
% count = 1;
% % countMonth = 1;
% % boxDataAll = [];
% nfft = 2048*2;
% for f = 1 : dimens(2)
%     yLim{f} = [];
% end
% 
% for d = dateStart : dateEnd
%     string = datestr(d);
%     
%     for h = 0 % : 23
%         dateVec(count, :) = datevec(string,'dd-mmm-yyyy');
%         dateVec(count, 4) = h;
%         dateSerial(count, 1) = datenum(dateVec(count,:));
%         
%         dir.dateFolderRead = sprintf('%d-%02d-%02d\\', dateVec(count,1), dateVec(count,2), dateVec(count,3));
%         % read file and plot
%         if exist([dir.folderSource dir.dateFolderRead], 'dir')
%             dir.fileRead = sprintf('%d-%02d-%02d %02d-%s.mat', ...
%                     dateVec(count,1), dateVec(count,2), dateVec(count,3), dateVec(count,4), nickName{1});
%             % load file
%             if exist([dir.folderSource dir.dateFolderRead dir.fileRead], 'file')
%                 dataTemp = load([dir.folderSource dir.dateFolderRead dir.fileRead]);
%                 fprintf('\n%s copied.\n', dir.fileRead)
%             else
%                 fprintf('\n%s no such file.\n', dir.fileRead)
%                 % fill with NaN
%                 dataTemp.data = NaN(dimens);
%             end
%             % clean data
% %             dataTemp.data = downsample(dataTemp.data, downSampRatio);
% %             dataTemp.data(abs(dataTemp.data) > 100) = mean(nanmean(dataTemp.data)); % clean outliers
%             dataTemp.data(abs(dataTemp.data) > 100) = 0; % clean outliers
% 
%             
%             fprintf('\nComputing frequency response...\n')
%             for f = 1 : dimens(2)
%                 [pxx{f}(:, count), freq{f}(:, count)] = cpsd(dataTemp.data(:,f), dataTemp.data(:,f), ...
%                     hanning(nfft/4), nfft*1.5/8, nfft, dimens(1)/3600);
%                 
% %                 figure(f)
% %                 semilogy(real(freq{f}), real(pxx{f}));
% %                 
% %                 ax = gca;
% %                 ax.Title.String = sprintf('VIB channel %02d', f);
% %                 ax.XLabel.String = 'Frequency (Hz)';
% %                 ax.YLabel.String = 'Power of Accel. (mm^2/s^3)';
% %                 ax.Units = 'normalized';
% %                 ax.Position = [0.05 0.13 0.94 0.81];  % control ax's position in figure
% %                 set(gca, 'fontsize', 22);
% %                 set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
% % 
% %                 fig = gcf;
% %                 fig.Units = 'pixels';
% %                 fig.Position = [20 50 2500 680];  % control figure's position
% %                 fig.Color = 'w';
% %                 hold on
%                 
%             end
%             
%             clear dataTemp
%         else
%             fprintf('\n%s no such folder.\n', dir.dateFolderRead)
% %             % fill with NaN
% %             dataTemp = NaN(dimens);
%         end
%         count = count + 1;
%     end
%     
%     
% %     % boxplot per month
% %     if  ismember(ceil(dateSerial(count-1, 1)), endOfMonthSerial)
% %         % separate data column
% %         for f = 1 : dimens(2)
% %             dataSplit{f}(:, countMonth) = boxDataAll(:, f);
% %             dataSplit{f}(:, 1:countMonth-1) = NaN;
% %         end
% %         boxDataAll = [];
% %         % plot each column
% %         for f = 1 : dimens(2)
% %             figure(f)
% %             boxplot(dataSplit{f});
% %             
% %             % axis control
% %             yLimPrev{f} = yLim{f};
% %             yLim{f} = get(gca, 'YLim');
% %             yLimMix = [yLim{f} yLimPrev{f}];
% %             yLim{f} = [min(yLimMix) max(yLimMix)];
% %             set(gca, 'YLim', yLim{f});
% %             
% %             ax = gca;
% %             ax.Title.String = sprintf('VIB channel %02d', f);
% %             ax.YLabel.String = 'Accel. RMS (gal)';
% %             ax.Units = 'normalized';
% %             ax.Position = [0.05 0.09 0.94 0.82];  % control ax's position in figure
% %             set(gca, 'fontsize', 20);
% %             set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
% % %             
% %             fig = gcf;
% %             fig.Units = 'pixels';
% %             fig.Position = [20 50 2500 480];  % control figure's position
% %             fig.Color = 'w';           
% %             
% %             hold on
% %         end
% %         dataSplit = [];
% %         countMonth = countMonth + 1;
% %     end
%     
% end
% count = count - 1;
% 
% %% save data
% if ~exist(dir.matSave, 'dir')
%     mkdir(dir.matSave)
% end
% 
% formatOut = 'yyyy_mm_dd_HH_MM';
% dateSave = datestr(datetime('now'), formatOut);
% save(sprintf('%s/data_freq_VIB_%s.mat', dir.matSave, dateSave));
% fprintf('\nData saved.\n')
% 
%% plot and save figures
dir.figFolder = sprintf('%s/figures_freq_VIB_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

% % for m = 1 : dimens(2)
% %     
% %     saveas(figure(m), sprintf('%s/freq_VIB_chan_%d.tif', dir.figFolder, m));
% %     fprintf('\nfreq VIB channel %d saved.\n', m);
% % end
% % 
% % run('freq_VIB_makeDocFile.m');


%% make xlabel
% t = 1;
% Date = {};
% xlabel=[];
% for year = 2014 : 2016
%     for month = 1:12
%         Date{t,1} = sprintf('%d-%02d-01',year,month);
%         xlabel(t) = datenum(Date{t,1});
%         if month == 1
%             xLabel{t,1} = datestr(xlabel(t),'yyyy-mm-dd');
%         else
%             xLabel{t,1} = sprintf('%02d-01',month); 
%         end
%         t=t+1;
%     end
% end

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

%% plot
orderPlot = [1:9 10:14 26:35 36 48:55 15:22 37:44 45:47 23:25];
run('titleNames.m')
for f = 23 : dimens(2)
    fprintf('\nPlotting...\n')
    figure(f)
%     contour(1:1096, freq{f}(1:2048,1), real(pxx{f}(1:2048,:)));
    contour(1:1096, freq{f}(:,1), log(real(pxx{f})), 800);
%     contour(real(pxx{f}));
%     ylim = ([0 5]);
    colorbar('FontSize', 18, 'FontName', 'Times new roman');
    colormap jet
    
    ax = gca;
    ax.Title.String = titleName_VIB{f};
    ax.YLabel.String = 'Frequency (Hz)';
    ax.Units = 'normalized';
    ax.Position = [0.05 0.14 0.9 0.79];  % control ax's position in figure
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    
    ax.XTick = xTickDispl;
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    
    fig = gcf;
    fig.Units = 'pixels';
    fig.Position = [20 50 2500 580];  % control figure's position
    fig.Color = 'w';
    pause(10)
    
    % save
    saveas(gcf, sprintf('%s/freq_VIB_chan_%d.tif', dir.figFolder, f));
    fprintf('\nfreq VIB channel %d saved.\n', f);
    close

    fprintf('\nDone.\n')
    
end

run('freq_VIB_makeDocFile.m');




