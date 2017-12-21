clear;clc;close all

%% settings
dir.folderSource = 'H:\jiashao\jiashao_2014\netmanagernj\';
dir.matSave = 'D:\continuous_monitoring\analysis\jiashao\matFiles\';
dir.figSave = 'D:\continuous_monitoring\analysis\jiashao\figures\';
dateStartInput = '2014-01-08';
dateEndInput = '2014-01-08';
formatIn = 'yyyy-mm-dd';

nickName = {'HPT'};
dimens = [3600 71]; % [number of points , number of channels]              % change here

%% plots
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);     % convert to serial number (count from year 0000)
dateEnd   = datenum(dateEndInput, formatIn);
dayTotal = dateEnd-dateStart+1;
count = 1;
rawAll = [];
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
            
            fprintf('\nStacking raw data...\n')
            rawAll = cat(1, rawAll, dataTemp.data);
            
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
% save(sprintf('%s/data_raw_HPT_%s.mat', dir.matSave, dateSave));
% fprintf('\nData saved.\n')

%% plot
% make xlabel
xDate = [dateStart : dateEnd];
xDate = upsample(xDate, 24);

% dayToLabel1 = [31 59 90 120 151 181 212 243 273 304 334];
% dayToLabel2 = [31 59 90 120 151 181 212 243 273 304 334] + 365;
% dayToLabel3 = [30 59 90 120 151 181 212 243 273 304 334] + 1 + 365 + 365;
% dayToLabel = [dayToLabel1 dayToLabel2 dayToLabel3];


% for m = 1 : length(xDate)
%     
%     if mod(m, 24*nBlocks*365) == 1 || mod(m, 24*nBlocks*365*2) == 1
%        xLabel{m} = datestr(xDate(m), 'yyyy-mm-dd');
%     end
%     
%     if intersect(m-1, dayToLabel*24*nBlocks) == m-1
%        xLabel{m} = datestr(xDate(m), 'mm-dd');
%     end
%     
% end

dir.figFolder = sprintf('%s/figures_raw_HPT_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

run('titleNames.m')
for m = 18 %: size(rawAll, 2)
    figure(m)
    plot(rawAll(:,m), 'b');
    
    % axis control
    ax = gca;
%     ax.XTick = [1 : size(xDate, 2)];
%     ax.XTickLabel = xLabel;
%     ax.XTickLabelRotation = 20;  % rotation
%     ax.TickLength = [0 0];
    
%     xlabel = 'Date';
    ax.YLabel.String = 'Deflection (cm)';
    ax.Title.String = titleName_HPT{m};
    
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
%     xlim([1  length(xDate)]);
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
    saveas(gcf, sprintf('%s/raw_HPT_chan_%d.tif', dir.figFolder, m));
    fprintf('\nraw HPT channel %d saved.\n', m);
    
end




