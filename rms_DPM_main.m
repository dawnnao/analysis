clear;clc;close all

%% settings
dir.folderSource = 'D:\continuous_monitoring\data_hangzhouwan_beihangdao\';
dir.matSave = 'D:\continuous_monitoring\analysis\matFiles\';
dir.figSave = 'D:\continuous_monitoring\analysis\figures\';
dateStartInput = '2014-01-01';
dateEndInput = '2016-12-31';

nickName = {'DPM'};
dimens = [36000 13]; % [number of points , number of channels]
nBlocks = 6; % number of blocks for hour-data
%% plots
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);     % convert to serial number (count from year 0000)
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
count = 1;
rmsAll = [];
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
                fprintf('\n%s imported.\n', dir.fileRead)
            else
                fprintf('\n%s no such file.\n', dir.fileRead)
                % fill with NaN
                dataTemp.data = NaN(dimens);
            end
            
            fprintf('\nCalculating RMS...\n')
            rmsBlocks = calcuRMSForDPM(dataTemp.data, nBlocks);
            rmsAll = cat(1, rmsAll, rmsBlocks);
            clear rmsBlocks
            
        else
            fprintf('\n%s no such folder.\n', dir.dateFolderRead)
%             % fill with NaN
%             dataTemp = NaN(dimens);
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
save(sprintf('%s/data_rms_DPM_%s.mat', dir.matSave, dateSave));
fprintf('\nData saved.\n')

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

dir.figFolder = sprintf('%s/figures_rms_DPM_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

run('titleNames.m')
for m = 1 : size(rmsAll, 2)
    figure(m)
    plot(rmsAll(:,m));
    
    % axis control
    ax = gca;
    ax.XTick = [1 : size(xDate, 2)];
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    ax.TickLength = [0 0];
    
%     xlabel = 'Date';
    ax.YLabel.String = 'Displ. (mm)';
    ax.Title.String = titleName_DPM{m};
    
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
    saveas(gcf, sprintf('%s/rms_DPM_chan_%d.tif', dir.figFolder, m));
    fprintf('\nrms DPM channel %d saved.\n', m);
    
end

run('rms_DPM_makeDocFile.m');

close all




