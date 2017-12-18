clear;clc;close all

%% settings
dir.folderSource = 'H:\jiashao\jiashao_2014\netmanagernj\';
dir.matSave = 'D:\continuous_monitoring\analysis\jiashao\matFiles\';
dir.figSave = 'D:\continuous_monitoring\analysis\jiashao\figures\';
dateStartInput = '2014-01-01';
dateEndInput = '2014-12-31';

nickName = {'HPT'};
dimens = [3600 71]; % [number of points , number of channels]              % change here
nBlocks = 6; % number of blocks for hour-data
run('referPoint.m');                                                       % change here

%% plots
formatIn = 'yyyy-mm-dd';
dateStart = datenum(dateStartInput, formatIn);
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
                fprintf('\n%s copied.\n', dir.fileRead)
            else
                fprintf('\n%s no such file.\n', dir.fileRead)
                % fill with NaN
                dataTemp.data = NaN(dimens);
            end
            
            fprintf('\nCalculating RMS...\n')
            rmsBlocks = calcuRMSForHPT(dataTemp.data, nBlocks, referPoint_HPT);
            rmsAll = cat(1, rmsAll, rmsBlocks);
            clear rmsBlocks
            
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
save(sprintf('%s/data_rms_HPT_%s.mat', dir.matSave, dateSave));
fprintf('\nData saved.\n')

%% make xlabel
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
% match with the point number of rmsAll
xTickDispl = (xTickDispl - 1) * 24 * nBlocks + 1;                          % change here

%% plot and save figures
dir.figFolder = sprintf('%s/figures_rms_HPT_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

orderPlot = [1:46 70:71 47:59];                                            % change here
run('titleNames.m')                                                        % change here
for f = cell2mat(orderPlot)
    fprintf(sprintf('\nPlotting figure %d...\n', f))
    figure(f)
    
    plot(rmsAll(:,f), 'b');
    % axis control
    ax = gca;
    ax.XTick = xTickDispl;
    ax.XTickLabel = xLabel;
    ax.XTickLabelRotation = 20;  % rotation
    ax.YLabel.String = 'Deflection (mm)';
    ax.Title.String = ['HPT: ' titleName_HPT{f}];
    ax.Units = 'normalized';
    ax.Position = [0.05 0.19 0.94 0.72];  % control ax's position in figure
    set(gca, 'fontsize', 20);
    set(gca, 'fontname', 'Times New Roman', 'fontweight', 'bold');
    xlim([1  size(rmsAll, 1)]);
    grid on
    % size control
    fig = gcf;
    fig.Units = 'pixels';
    fig.Position = [20 50 2500 580];  % control figure's position
    fig.Color = 'w';
    
    % save
    saveas(gcf, sprintf('%s/rms_HPT_chan_%d.tif', dir.figFolder, f));
    fprintf('\nrms HPT channel %d saved.\n', f);
end

run('rms_HPT_makeDocFile.m');



