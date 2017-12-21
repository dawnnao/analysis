import mlreportgen.dom.*;

dir.docFile = sprintf('%s/stats_%s_%s', dir.figSave, nickName, dateSave); % set file path
reportType = 'docx';
templateName = 'Auto_Report_Template_test';
doc = Document(dir.docFile, reportType, templateName);
open(doc);

%% cover
% set page size
s = doc.CurrentPageLayout;
s.PageSize.Orientation  ='portrait';
s.PageSize.Height = '11.69in';
s.PageSize.Width = '8.27in';

% insert blank
cBlank = 0; frag = 4;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

% make tile
titleObj{1} = Paragraph('Continuous SHM Data Inspection Auto-Report');
titleObj{1}.Bold = false;
titleObj{1}.FontSize = '26';
titleObj{1}.HAlign = 'center';
append(doc, titleObj{1});

titleObj{2} = Paragraph('Version: 0.1');
titleObj{2}.Bold = false;
titleObj{2}.FontSize = '18';
titleObj{2}.HAlign = 'center';
append(doc, titleObj{2});

% insert blank
cBlank = cBlankNew; frag = 12;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

% make author
arthurObj = Paragraph('Center of Data Science and Engineering for Civil Infrastructure');
arthurObj.Bold = false;
arthurObj.FontSize = '18';
arthurObj.HAlign = 'center';
append(doc, arthurObj);

% insert blank
cBlank = cBlankNew; frag = 2;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

dateObj = Paragraph(datestr(datetime('now'),'yyyy-mm-dd'));
dateObj.Bold = false;
dateObj.FontSize = '18';
dateObj.HAlign = 'center';
append(doc, dateObj);

countFig = 0; % initialization for image count
countTable = 0;

%% figures
% insert next section and set page layout
countSect = 1;
sect{countSect} = DOCXPageLayout;
sect{countSect}.PageSize.Orientation = 'portrait';
sect{countSect}.SectionBreak = 'Next Page';
sect{countSect}.PageSize.Height = '11.69in';
sect{countSect}.PageSize.Width = '8.27in';
sect{countSect}.PageMargins.Left = '0.75in';
sect{countSect}.PageMargins.Right = '0.75in';
sect{countSect}.PageMargins.Top = '0.8in';
sect{countSect}.PageMargins.Bottom = '0.8in';
append(doc, sect{countSect});

% imageCap = labelName; % images captions (cell format)

for g = 1 : length(orderPlot)
    
    % make tile
    hintObj = Paragraph(sprintf('group %d:', g));
    hintObj.Bold = false;
    hintObj.FontSize = '16';
    hintObj.HAlign = 'left';
    append(doc, hintObj);
    
    % insert blank
    cBlank = 0; frag = 1;
    cBlankNew = cBlank + frag;
    for n = cBlank+1 : cBlankNew
        blankObj{n} = Paragraph('');
        append(doc, blankObj{n});
    end

    countTable = countTable + 1;
    tableObj{countTable} = Table();
    rowImg{1} = TableRow();
    rowImg{2} = TableRow();
    rowCap = TableRow();
    c = 1;
    for p = orderPlot{g}
        % stats basic
        imgsize = size(imread(sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, p))); % get image size
        width = [num2str(1.15 * imgsize(2)/imgsize(1)) 'in'];
        images{p} = Image(sprintf('%s/stats_%s_chan_%d_basic.tif', dir.figFolderBasic, nickName, p)); % read images from folder
%         images{p}.Style = 'Figure_Content';
        images{p}.Height = '1.15in';
        images{p}.Width = width;
        append(rowImg{1}, TableEntry(images{p}));
        % stats freq
        imgsize = size(imread(sprintf('%s/stats_%s_chan_%d_freq.tif', dir.figFolderFreq, nickName, p))); % get image size
        width = [num2str(1.15 * imgsize(2)/imgsize(1)) 'in'];
        images{p} = Image(sprintf('%s/stats_%s_chan_%d_freq.tif', dir.figFolderFreq, nickName, p)); % read images from folder
%         images{p}.Style = 'Figure_Content';
        images{p}.Height = '1.15in';
        images{p}.Width = width;
        append(rowImg{2}, TableEntry(images{p}));
        
        % make image captions
%         if exist('countFig', 'var'), countFig = countFig + 1;
%         else countFig = 1; 
%         end
%         imageCaps{l} = Paragraph(sprintf('Fig %d. %s', countFig, imageCap{l}));
%         imageCaps{l}.Bold = false;
%         % imageNetPerformCap.FontSize = '18';
%         imageCaps{l}.HAlign = 'center';
%         append(rowCap, TableEntry(imageCaps{l}));
    
        % append images
        if mod(c,1) == 0 % change here to customize column number of table
            append(tableObj{countTable},rowImg{1});
            append(tableObj{countTable},rowImg{2});
%             append(tableObj{countTable},rowCap);
            rowImg{1} = TableRow();
            rowImg{2} = TableRow();
%             rowCap = TableRow();
    %   elseif l == size(statsAll, 2)
    %         append(tableObj{countTable},rowImg{f});
    %         append(tableObj{countTable},rowCap);
        end
        
        % append overall caption
        if p == orderPlot{g}(end)
            overallCap = Paragraph();
            overallCap.HAlign = 'center';
            append(rowCap, TableEntry(overallCap));
            append(tableObj{countTable}, rowCap);
            rowCap = TableRow();
        end
        
        c = c + 1;
    end
    tableObj{countTable}.HAlign = 'center';
%     tableObj{countTable}.Style = 'Figure_Content';
    append(doc, tableObj{countTable});
    
    % insert blank
    cBlank = 0; frag = 4;
    cBlankNew = cBlank + frag;
    for n = cBlank+1 : cBlankNew
        blankObj{n} = Paragraph('');
        append(doc, blankObj{n});
    end
end

%% insert next section
close(doc);
rptview(doc.OutputPath);
fprintf('\nDocument generated.\n')



