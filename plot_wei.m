
%% plot
% make xlabel
t = 1;Date = {};xlabel=[];
for year = 2014:2016
    for month = 1:12
        Date{t,1} = sprintf('%d-%02d-01',year,month); 
        xlabel(t) = datenum(Date{t,1});
        if month == 1
            xLabel{t,1} = datestr(xlabel(t),'yyyy-mm-dd');
        else
            xLabel{t,1} = sprintf('%02d-01',month); 
        end
        t=t+1;
    end
end
dateSave = datestr(datetime('now'), formatOut);
dir.figFolder = sprintf('%sfigures_rms_rsg_%s/', dir.figSave, dateSave);
if ~exist(dir.figFolder, 'dir')
    mkdir(dir.figFolder)
end

loc=[13:18 20 19 21:55 78:81 56:65]; sensors = {};

for i = 1:length(loc)
    if i<=24
        sensors{i,1} = sprintf('BHD-Strain-G03-%03d',i);
    elseif i<=36
        sensors{i,1} = sprintf('BHD-Strain-G07-%03d',i-24);
    elseif i<=42
        sensors{i,1} = sprintf('BHD-Strain-G08-%03d',i-36);
    elseif i<=45
        sensors{i,1} = sprintf('BHD-Strain-G09-%03d',i-42);
    elseif i<=47
        sensors{i,1} = sprintf('BHD-Strain-G09-%03d',i-41);
    else
        sensors{i,1} = sprintf('BHD-Strain-G11-%03d',i-47);
    end
end
        
        
for m = 1 : size(rmsAll, 2)
    figure(m)
    plot(rmsAll(:,m));
    
    % axis control
    ax = gca;    ax.XTick = (xlabel-dateStart)*144;
    ax.XTickLabel = xLabel;    ax.XTickLabelRotation = 20;  % rotation
    ax.TickLength = [0 0];
    
%     xlabel = 'Date';
    ax.YLabel.String = 'RMS (??)';
    ax.Title.String = sprintf('RMS:%s',sensors{m,1});
    
    set(gca, 'fontsize', 14);    set(gca, 'fontname', 'Times New Roman');
    % xlim([1  size(xDate, 2)]);
%     grid on
    
    % size control
    fig = gcf;    fig.Units = 'normalized';
    fig.Position = [0 0.5 1 0.4];  % control figure's position
%     fig.Position = [0 0.75 1 0.08];  % control figure's position
    % set(gcf,'color','w');
    fig.Color = 'w';    ax.Units = 'normalized';
    ax.Position = [0.05 0.19 0.94 0.72];  % control ax's position in figure
    
    % save
    saveas(gcf, sprintf('%s%s.tif', dir.figFolder, sensors{m,1}));
    fprintf('/nrms rsg channel %d saved./n', m);
    close    
    
end
run('rms_rsg_makeDocFile.m');
