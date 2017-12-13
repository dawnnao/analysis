clear;clc;close all

%% settings
dir.folderSource = 'D:\continuous_monitoring\data_hangzhouwan_beihangdao\';
dir.matSave = 'D:\continuous_monitoring\analysis\matFiles\';
dir.figSave = 'D:\continuous_monitoring\analysis\figures\';
dateStartInput = '2014-01-01';
dateEndInput = '2016-12-31';

nickName = {'DPM'};
dimens = [36000 13]; % [number of points , number of channels]
downSampRatio = 1000; % decrease sampling rate by interger factor
endOfMonthSerial = [getSerialDateOfMonthEnd(2014, 1:12, 1),...
                    getSerialDateOfMonthEnd(2015, 1:12, 1),...
                    getSerialDateOfMonthEnd(2016, 1:12, 1)];

%% plots
% initialization
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);     % convert to serial number (count from year 0000)
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
count = 1;
countMonth = 1;
boxDataAll = [];
for f = 1 : dimens(2)
    yLim{f} = [];
end

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
                dataTemp.data = NaN(dimens);
            end
            % clean and collect data
            dataTemp.data = downsample(dataTemp.data, downSampRatio);
            dataTemp.data = abs(dataTemp.data);
            dataTemp.data(dataTemp.data > 2000) = NaN; % clean outliers
            dataTemp.data(dataTemp.data < 100) = NaN;
            boxDataAll = cat(1, boxDataAll, dataTemp.data);
            clear dataTemp
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
%             % fill with NaN
%             dataTemp = NaN(dimens);
        end
        count = count + 1;
    end
    
    % boxplot per month
    if  ismember(ceil(dateSerial(count-1, 1)), endOfMonthSerial)
        % separate data column
        for f = 1 : dimens(2)
            dataSplit{f}(:, countMonth) = boxDataAll(:, f);
            dataSplit{f}(:, 1:countMonth-1) = NaN;
        end
        boxDataAll = [];
        % plot each column
        for f = 1 : dimens(2)
            figure(f)
            boxplot(dataSplit{f});
            
            % axis control
            yLimPrev{f} = yLim{f};
            yLim{f} = get(gca, 'YLim');
            yLimMix = [yLim{f} yLimPrev{f}];
            yLim{f} = [min(yLimMix) max(yLimMix)];
            set(gca, 'YLim', yLim{f});
            
            ax = gca;
            ax.Title.String = sprintf('DPM channel %02d', f);
            ax.YLabel.String = 'Displ. (mm)';
            ax.Units = 'normalized';
            ax.Position = [0.05 0.09 0.94 0.82];  % control ax's position in figure
            set(gca, 'fontsize', 20);
            set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
            
            fig = gcf;
            fig.Units = 'pixels';
            fig.Position = [20 50 2500 480];  % control figure's position
            fig.Color = 'w';           
            
            hold on
        end
        dataSplit = [];
        countMonth = countMonth + 1;
    end
    
end

%% save data
if ~exist(dir.matSave, 'dir')
    mkdir(dir.matSave)
end

formatOut = 'yyyy_mm_dd_HH_MM';
dateSave = datestr(datetime('now'), formatOut);
save(sprintf('%s/data_box_DPM_%s.mat', dir.matSave, dateSave));
fprintf('\nData saved.\n')

%% save figures
dir.figFolder = sprintf('%s/figures_box_DPM_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

for m = 1 : dimens(2)
    saveas(figure(m), sprintf('%s/box_DPM_chan_%d.tif', dir.figFolder, m));
    fprintf('\nbox DPM channel %d saved.\n', m);
end

%% plot
% make xlabel
xDate = [dateStart : dateEnd];
xDate = upsample(xDate, 24*nBlocks);
xLabel = cell(size(xDate));
dayToLabel1 = [31 59 90 120 151 181 212 243 273 304 334];
dayToLabel2 = [31 59 90 120 151 181 212 243 273 304 334] + 365;
dayToLabel3 = [30 59 90 120 151 181 212 243 273 304 334] + 1 + 365 + 365;
dayToLabel = [dayToLabel1 dayToLabel2 dayToLabel3];

for m = 1 : length(xDate)
    
    if mod(m, 24*nBlocks*365) == 1 || mod(m, 24*nBlocks*365*2) == 1
       xLabel{m} = datestr(xDate(m), 'yyyy-mm-dd');
    end
    
    if intersect(m-1, dayToLabel*24*nBlocks) == m-1
       xLabel{m} = datestr(xDate(m), 'mm-dd');
    end
    
end



for m = 1 : size(boxDataAll, 2)
    figure(m)
    plot(boxDataAll(:,m));
    
    % axis control
    ax = gca;
    ax.XTick = [1 : size(xDate, 2)];
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    ax.TickLength = [0 0];
    
%     xlabel = 'Date';
%     ax.YLabel.String = 'box';
    ax.Title.String = sprintf('DPM channel %02d', m);
    
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    xlim([1  size(xDate, 2)]);
%     grid on
    
    % size control
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0.5 1 0.4];  % control figure's position
%     fig.Position = [0 0.75 1 0.08];  % control figure's position
    % set(gcf,'color','w');
    fig.Color = 'w';
    ax.Units = 'normalized';
    ax.Position = [0.05 0.19 0.94 0.72];  % control ax's position in figure
    
    % save
    
    
end

run('box_DPM_makeDocFile.m');




