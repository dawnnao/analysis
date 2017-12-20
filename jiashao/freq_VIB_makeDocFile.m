import mlreportgen.dom.*;

dir.docFile = sprintf('%s/freq_VIB_%s', dir.figSave, dateSave); % set file path
reportType = 'docx';
doc = Document(dir.docFile, reportType);
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
    rowImg = TableRow();
    rowCap = TableRow();
    c = 1;
    for p = orderPlot{g}
        imgsize = size(imread(sprintf('%s/freq_VIB_chan_%d.tif', dir.figFolder, p))); % get image size
        width = [num2str(1.15 * imgsize(2)/imgsize(1)) 'in'];
        images{p} = Image(sprintf('%s/freq_VIB_chan_%d.tif', dir.figFolder, p)); % read images from folder
        images{p}.Height = '1.15in';
        images{p}.Width = width;
        append(rowImg, TableEntry(images{p}));

        if exist('countFig', 'var'), countFig = countFig + 1;
        else countFig = 1; 
        end

    %     % make image captions
    %     imageCaps{l} = Paragraph(sprintf('Fig %d. %s', countFig, imageCap{l}));
    %     imageCaps{l}.Bold = false;
    %     % imageNetPerformCap.FontSize = '18';
    %     imageCaps{l}.HAlign = 'center';
    %     append(rowCap, TableEntry(imageCaps{l}));

        if mod(c,1) == 0 % change here to customize column number of table
            append(tableObj{countTable}, rowImg);
    %         append(tableObj{countTable},rowCap);
            rowImg = TableRow();
    %         rowCap = TableRow();
    %     elseif l == dimens(2)
    %         append(tableObj{countTable}, rowImg);
    %         append(tableObj{countTable}, rowCap);
        end
        c = c + 1;
    end
    tableObj{countTable}.HAlign = 'center';
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
% rptview(doc.OutputPath);
fprintf('\nDocument generated.\n')




