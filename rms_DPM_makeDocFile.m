import mlreportgen.dom.*;

dir.docFile = sprintf('%s/rms_DPM_%s', dir.figSave, dateSave); % set file path
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

% dateObj = Paragraph(datetime('now','Format','yyyy-MM-dd'));
% datestr(datetime('now'),'yyyy-MM-dd');
dateObj = Paragraph(datestr(datetime('now'),'yyyy-mm-dd'));
dateObj.Bold = false;
dateObj.FontSize = '18';
dateObj.HAlign = 'center';
% append(dateObj, ['' datetime('now','Format','yyyy-MM-dd') '']);
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

countTable = countTable + 1;
tableObj{countTable} = Table();
rowImg{2} = TableRow();
rowCap{2} = TableRow();
c = 1;
for l = 1 : size(rmsAll, 2)
    imgsize = size(imread(sprintf('%s/rms_DPM_chan_%d.tif', dir.figFolder, l))); % get image size
    width = [num2str(1.15 * imgsize(2)/imgsize(1)) 'in'];
    images{l} = Image(sprintf('%s/rms_DPM_chan_%d.tif', dir.figFolder, l)); % read images from folder
    images{l}.Height = '1.15in';
    images{l}.Width = width;
    append(rowImg{2}, TableEntry(images{l}));
    
    if exist('countFig', 'var'), countFig = countFig + 1;
    else countFig = 1; 
    end
    
%     % make image captions
%     imageCaps{l} = Paragraph(sprintf('Fig %d. %s', countFig, imageCap{l}));
%     imageCaps{l}.Bold = false;
%     % imageNetPerformCap.FontSize = '18';
%     imageCaps{l}.HAlign = 'center';
%     append(rowCap{2}, TableEntry(imageCaps{l}));
    
    if mod(c,1) == 0 % change here to customize column number of table
        append(tableObj{countTable},rowImg{2});
%         append(tableObj{countTable},rowCap{2});
        rowImg{2} = TableRow();
%         rowCap{2} = TableRow();
    elseif l == size(rmsAll, 2)
        append(tableObj{countTable},rowImg{2});
%         append(tableObj{countTable},rowCap{2});
    end
    c = c + 1;
end
tableObj{countTable}.HAlign = 'center';
append(doc, tableObj{countTable});

%% insert next section
% countSect = countSect + 1;
% sect{5} = DOCXPageLayout;
% sect{5}.PageSize.Orientation = 'portrait';
% sect{5}.SectionBreak = 'Next Page';
% sect{5}.PageSize.Height = '8.27in';
% sect{5}.PageSize.Width = '11.69in';
% append(doc, sect{5});

close(doc);

fprintf('\nDocument generated.\n')







