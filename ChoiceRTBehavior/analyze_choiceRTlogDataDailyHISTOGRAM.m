function sessionSummary = analyze_choiceRTlogDataDailyHISTOGRAM(~, implantSide, varargin)
%
% USAGE: sessionSummary = analyze_choiceRTlogDataDaily(ratID, implantSide)
%
% INPUTS:
%   ratID - string containing the rat ID (e.g., 'R0001'). Should have 5
%       characters
%   implantSide - use 'left' to indicate left implant. Anything else
%       assumed to be right. 'left' should be used as default (i.e., prior
%       to implantation)
%
% VARARGS:
%   'recordingdirectory' - 
%   'hostIP' - IP address of the sql DB host server

%   'user' - user name to login to the sql DB
%   'password' - password to login to the sql DB
%   'dbname' - name of the sql DB
%   'sqljava_version' - version of the sql-java interface
%   'toplevldir' - top level data directory - if applied, overrides query
%       of sql database to find the data storage directory
% OUTPUTS:
%   sessionSummary - structure containing session summary information from
%       the last .log file checked. This is mainly useful for
%       troubleshooting the software
%
% CHOICE RT DIFFICULTY LEVELS:
%   0 - Poke Any: rat pokes any port, as soon as it pokes a pellet is
%       delivered
%   1 - Very Easy: single port is lit, pellet delivered as soon as the port
%       is poked
%   2 - Easy: 
%   3 - Standard:  
%   4 - Advanced: 
%   5 - Choice VE: 
%   6 - Choice Easy: 
%   7 - Choice Standard: 
%   8 - Choice Advanced: 
%   9 - Testing: 
%
% UPDATE LOG:
% 08/27/2014 - don't have to navigate to the parent folder first, requires
%   user to specify the rat ID as an input argument

choiceRTdifficulty = cell(1, 10);
choiceRTdifficulty{1}  = 'poke any';
choiceRTdifficulty{2}  = 'very easy';
choiceRTdifficulty{3}  = 'easy';
choiceRTdifficulty{4}  = 'standard';
choiceRTdifficulty{5}  = 'advanced';
choiceRTdifficulty{6}  = 'choice VE';
choiceRTdifficulty{7}  = 'choice easy';
choiceRTdifficulty{8}  = 'choice standard';
choiceRTdifficulty{9}  = 'choice advanced';
choiceRTdifficulty{10} = 'testing';

figUnits = 'centimeters';

figProps.m = 3; figProps.n = 3;
figProps.width = 8.5 * 2.54;
figProps.height = 8 * 2.54;
figProps.topMargin = 6;
figProps.panelWidth = 6 * ones(1,3);
figProps.panelHeight = (figProps.height - 2*figProps.topMargin)/figProps.m * ones(1,3);
figProps.colSpacing = 1 * ones(1,2);
figProps.rowSpacing = 2 * ones(1,2);
fullPanelWidth = sum(figProps.panelWidth) + sum(figProps.colSpacing);
ltMargin = (figProps.width - fullPanelWidth) / 2;
fullPanelHeight = sum(figProps.panelHeight) + sum(figProps.rowSpacing);
botMargin = (figProps.height - figProps.topMargin - fullPanelHeight);
       
topLevelDir = 'X:\data\ChoiceTask\';

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'topleveldir'
            topLevelDir = varargin{iarg + 1}; 
        
%         case 'recordingdirectory',
%             recordingDirectory = varargin{iarg + 1};
%         case 'hostip'
%             hostIP = varargin{iarg + 1};
%         case 'user'
%             user = varargin{iarg + 1};
%         case 'password'
%             password = varargin{iarg + 1};
%         case 'dbname'
%             dbName = varargin{iarg + 1};
%          case 'sqljava_version'
%              sqlJava_version = varargin{iarg + 1};     
    end
end

parentFolder = fullfile(topLevelDir, ...
                        'R0343', ...
                        ['R0343' '-rawdata']);
% if ismac
%     % change the pc formatted 
%     topLevelDir = fullfile('/Volumes',recordingDirectory,'ChoiceTask');
% elseif ispc
%     % figure out the IP address for where the data are stored
%     topLevelDir = sql_findNASpath(ratID, ...
%                                   'hostip', hostIP, ...
%                                   'user', user, ...
%                                   'password', password, ...
%                                   'dbname', dbName, ...
%                                   'sqljava_version', sqlJava_version);  
% elseif isunix
%         % in case we ever use unix machines for this analysis
% end

cd(parentFolder);

graphFolder=[parentFolder(1:end-7) 'graphs'];
if ~exist(graphFolder, 'dir')
    mkdir(graphFolder);
end

direct=dir(['R0343' '*']);

%paper dimensions # centimeters units
% X = 21.0;                  %# A3 paper size
% Y = 29.7;                  %# A3 paper size
% xMargin = 1;               %# left ht margins from page borders
% yMargin = 1;               %# bottom/top margins from page borders
% xSize = X - 2*xMargin;     %# figure size on paper (width)
% ySize = Y - 2*yMargin;     %# figure size on paper (height)

%font
fontTitle=25;
fontFigure=18;

% numFolders = length(direct) - 3;
numFolders = length(direct);

sessionSummary = initSessionSummary();

for iDir=1:numFolders %#ok<ALIGN>
%     ii = iDir + 3;
    ii = iDir;
    
    textString{1} = [direct(ii).name '_LogAnalysis.pdf'];
    graphName = fullfile(graphFolder, textString{1});
    if exist(graphName, 'file'); continue; end

    fprintf('%d of %d directories\n', iDir, numFolders)

    cd(direct(ii).name);

%    outcome - 0 = successful
%              1 = false start, started before GO tone
%              2 = false start, failed to hold for PSSHT (for
%                  stop-signal/go-nogo; not relevant for simple choice task)
%              3 = rat started in the wrong port
%              4 = rat exceeded the limited hold
%              5 = rat went the wrong way after the tone
%              6 = rat failed to go back into a side port in time
%              7 = Outcome wasn't recorded in the data file


    RTbins = 0.05 : 0.05 : 0.95;
    MTbins = 0.05 : 0.05 : 0.95; 

    dirs=dir(fullfile(pwd,'*.log'));
    numLogs = length(dirs);
    switch numLogs
        case 0         % skip if no .log files present
            cd(parentFolder);
            continue;
        case 1
            validLogIdx = 1;
        case 2
            for iLog = 1 : length(dirs)
                if isempty(strfind(dirs(iLog).name, 'old'))
                    validLogIdx = iLog;
                    break;
                end
            end
        otherwise      % skip if more than one .log files present
            cd(parentFolder);
            continue;
    end   
    logData = readLogData(dirs(validLogIdx).name);

%     if length(fieldnames(logData))>=27 && length(logData.Attempt)>20   % only analyze data from valid log files with > 20 attempts
        
%         h_fig = figure('units', 'centimeters', ...
%                        'color', 'w', ...
%                        'position',[1 1 X Y]);

        if ~isfield(logData, 'outcome')
            cd(parentFolder);
            continue;
        end    % sometimes, sessions get started and stopped before any trials occur
        
        sessionSummary.correct      = (logData.outcome == 0);
        sessionSummary.wrongMove    = (logData.outcome == 5);
        sessionSummary.complete     = sessionSummary.correct | sessionSummary.wrongMove;
        sessionSummary.falseStart   = (logData.outcome == 1);
        sessionSummary.wrongStart   = (logData.outcome == 3);
        sessionSummary.targetRight  = (logData.Target > logData.Center);
        sessionSummary.moveRight    = (logData.SideNP > logData.Center);
        sessionSummary.ftr          = (logData.outcome == 4 | logData.outcome == 6);
        sessionSummary.LHviol       = (logData.outcome == 4);
        sessionSummary.MHviol       = (logData.outcome == 6);

        if strcmpi(implantSide, 'left')
            sessionSummary.targetContra = sessionSummary.targetRight;
            sessionSummary.targetIpsi   = ~sessionSummary.targetRight;

            sessionSummary.moveContra   = sessionSummary.moveRight;
            sessionSummary.moveIpsi     = ~sessionSummary.moveRight & logData.SideNP > 0;

        else
            sessionSummary.targetContra = ~sessionSummary.targetRight;
            sessionSummary.targetIpsi   = sessionSummary.targetRight;

            sessionSummary.moveContra   = ~sessionSummary.moveRight & logData.SideNP > 0;
            sessionSummary.moveIpsi     = sessionSummary.moveRight;
        end

        correctTargetContra = sessionSummary.correct & sessionSummary.targetContra;
        correctTargetIpsi   = sessionSummary.correct & sessionSummary.targetIpsi;

        completeTargetContra = sessionSummary.complete & sessionSummary.targetContra;
        completeTargetIpsi   = sessionSummary.complete & sessionSummary.targetIpsi;

        sessionSummary.acc(1) = sum(correctTargetIpsi) / sum(completeTargetIpsi);
        sessionSummary.acc(2) = sum(correctTargetContra) / sum(completeTargetContra);
        sessionSummary.acc(3) = sum(sessionSummary.correct) / sum(sessionSummary.complete);

        %center accuracy
        correctCenter2   = sessionSummary.correct & logData.Center == 2;
        correctCenter3   = sessionSummary.correct & logData.Center == 4;
        correctCenter4   = sessionSummary.correct & logData.Center == 8;

        completeTargetCenter2 = sessionSummary.complete & logData.Center == 2;
        completeTargetCenter3   = sessionSummary.complete & logData.Center == 4;
        completeTargetCenter4   = sessionSummary.complete & logData.Center == 8;
        sessionSummaryCenter.acc(1) = sum(correctCenter2) / sum(completeTargetCenter2);
        sessionSummaryCenter.acc(2) = sum(correctCenter3) / sum(completeTargetCenter3);
        sessionSummaryCenter.acc(3) = sum(correctCenter4) / sum(completeTargetCenter4);

        plotMatrix = [zeros(3, 3)];
        % ipsi, contra, all number of attempts
        plotMatrix(1, 1) = sum(sessionSummary.targetIpsi);
        plotMatrix(2, 1) = sum(sessionSummary.targetContra);
        plotMatrix(3, 1) = length(sessionSummary.correct);

        plotMatrix(1, 2) = sum(completeTargetIpsi);
        plotMatrix(2, 2) = sum(completeTargetContra);
        plotMatrix(3, 2) = sum(sessionSummary.complete);

        plotMatrix(1, 3) = sum(correctTargetIpsi);
        plotMatrix(2, 3) = sum(correctTargetContra);
        plotMatrix(3, 3) = sum(sessionSummary.correct);
        
        [h_fig, h_axes, figProps] = createFigPanels5(figProps, 'units', figUnits);
        
        axes(h_axes(1,1));
        set(gca,'FontSize',14)
        bar(plotMatrix);
        set(gca,'xticklabel',{'ipsi','contra','all'}, ...
                'ylim',[0 350]);
        title('# trials','fontsize',fontFigure);
        h_leg = legend('Attempt','Complete','Correct','Location','NorthWest');
        set(h_leg, 'fontsize',10);

        axes(h_axes(1,2));
        set(gca,'FontSize',14)
        bar(sessionSummary.acc);
        set(gca,'xticklabel',{'ipsi','contra','all'}, ...
                'ylim',[0 1.1]);
        title('accuracy','fontsize',fontFigure);


        axes(h_axes(1,3));
        set(gca,'FontSize',14)
        plotMatrix = zeros(3, 6);
        % first row - ipsi directed trials; 2nd row - contra directed trials; 3rd
        % row - all trials
        outcomeList = [0,1,3,4,6,5];
        for i_outcome = 1 : 6
            plotMatrix(1, i_outcome) = sum(logData.outcome == outcomeList(i_outcome) & ...
                                           sessionSummary.targetIpsi);
            plotMatrix(2, i_outcome) = sum(logData.outcome == outcomeList(i_outcome) & ...
                                           sessionSummary.targetContra);
            plotMatrix(3, i_outcome) = sum(logData.outcome == outcomeList(i_outcome));
        end
        plotMatrix(1,:) = plotMatrix(1,:) ./ sum(sessionSummary.targetIpsi);
        plotMatrix(2,:) = plotMatrix(2,:) ./ sum(sessionSummary.targetContra);
        plotMatrix(3,:) = plotMatrix(3,:) ./ length(sessionSummary.correct);
        
        bar(plotMatrix, 'stack');
        title('trial outcomes','fontsize',fontFigure);
        set(gca,'xticklabel',{'ipsi','contra','all'}, ...
                'ylim',[0 1.1]);
        [h_leg,~,~,~] = legend('cor','fs','ws','lh','mh','wrong','Location','SouthEast');
        legPos = zeros(1,4);
        legPos(1) = sum(figProps.panelWidth(1:2)) + sum(figProps.colSpacing) + figProps.panelWidth(3)/1.65 + ltMargin;
        legPos(2) = botMargin + sum(figProps.panelHeight) + sum(figProps.rowSpacing) + 1;
        legPos(3) = 2.2;
        legPos(4) = 2.5;
        set(h_leg, 'units',figUnits,'fontsize', 10, 'position',legPos);

%Parse this section out as its own function?


        axes(h_axes(2,1));
        hold on
        set(gca, 'FontSize',14)
        sessionSummary.ipsiRT   = logData.RT(completeTargetIpsi);
        sessionSummary.contraRT = logData.RT(completeTargetContra);
        sessionSummary.allRT    = logData.RT(sessionSummary.complete);
        
        d = diff(RTbins)/2;
        RTedges = [RTbins(1)-d(1), RTbins(1:end-1)+d, RTbins(end)+d(end)];
        
        ipsiHist = histogram(sessionSummary.ipsiRT, RTedges, 'DisplayStyle', 'stairs', 'EdgeColor', 'm');
        contraHist = histogram(sessionSummary.contraRT, RTedges, 'DisplayStyle', 'stairs', 'EdgeColor', 'b');
        allHist = histogram(sessionSummary.allRT, RTedges, 'DisplayStyle', 'stairs', 'EdgeColor', 'k'); 
        
        plot(RTedges, ipsiHist);
        plot(RTedges, contraHist);
        plot(RTedges, allHist);
        title('completed RT','fontsize', fontFigure);
        h_leg = legend('Ipsi','Contra','All','Location','NorthEast');
        set(h_leg, 'fontsize',10);
        hold off

        axes(h_axes(2,2));
        set(gca,'FontSize',14)
        sessionSummary.ipsiMT   = logData.MT(completeTargetIpsi);
        sessionSummary.contraMT = logData.MT(completeTargetContra);
        sessionSummary.allMT    = logData.MT(sessionSummary.complete);

        ipsiHist   = hist(sessionSummary.ipsiMT, MTbins);
        contraHist = hist(sessionSummary.contraMT, MTbins);
        allHist    = hist(sessionSummary.allMT, MTbins);

        plot(MTbins, ipsiHist, 'color', 'm');
        hold on
        plot(MTbins, contraHist, 'color', 'b');
        plot(MTbins, allHist, 'color', 'k');
        title('completed MT','fontsize',fontFigure);
        h_leg = legend('Ipsi','Contra','All','Location','NorthEast');
        set(h_leg, 'fontsize',10);

        axes(h_axes(2,3));
        set(gca,'FontSize',14)
        sessionSummary.ipsiRTMT   = logData.MT(completeTargetIpsi) + logData.RT(completeTargetIpsi);
        sessionSummary.contraRTMT = logData.MT(completeTargetContra) + logData.RT(completeTargetContra);
        sessionSummary.allRTMT    = logData.MT(sessionSummary.complete) + logData.RT(sessionSummary.complete);

        ipsiHist   = hist(sessionSummary.ipsiRTMT, MTbins);
        contraHist = hist(sessionSummary.contraRTMT, MTbins);
        allHist    = hist(sessionSummary.allRTMT, MTbins);

        plot(MTbins, ipsiHist, 'color', 'm');
        hold on
        plot(MTbins, contraHist, 'color', 'b');
        plot(MTbins, allHist, 'color', 'k');
        title('completed RT+MT','fontsize',fontFigure);
        h_leg = legend('Ipsi','Contra','All','Location','NorthEast');
        set(h_leg, 'fontsize',10);

        axes(h_axes(3,1));
        set(gca,'FontSize',14)
        bar(sessionSummaryCenter.acc);
        set(gca,'xticklabel',{'Port2','Port3','Port4'}, ...
                'ylim',[0 1.1]);
        title('accuracy','fontsize',fontFigure);

        A=cell(1,3);

        A{1} = ['Subject: ' logData.subject];
        A{2} = ['Date: ' logData.date];
        A{3} = ['Task Level: ' choiceRTdifficulty{logData.taskLevel+1}];
%         A{3} = ['Task Level: ' int2str(logData.taskLevel)];
%         mls = sprintf('%s\n%s\n%s',A{1,1},A{1,2},A{1,3});
        textString{1} = [direct(ii).name '_LogAnalysis'];
        
        h_figAxes = createFigAxes(h_fig);
        axes(h_figAxes);
        
        textBot = 16.5;
        textLeft = 5;
        text('units','centimeters',...
             'fontsize', 14, ...
             'position',[textLeft, textBot], ...
             'string', A);
             

%  set(gcf, 'PaperPosition', [xMargin yMargin xSize ySize]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%        set(gcf, 'PaperSize', [X Y]); %Keep the same paper size
%        uicontrol('Style','text',...
%                 'String',mls,...
%                 'Position',[160 2510 1600 150],...
%                 'BackgroundColor','white','fontsize',fontTitle);
        cd(graphFolder);
        figure(h_fig);
%        export_fig(graphName,'-pdf','-q101','-painters','-nocrop');
        saveas(gcf, textString{1}, 'pdf')
        close(h_fig);
        cd(parentFolder);
    end
    cd(parentFolder);
end