function showRawTetrodeWires(sessionConf,varargin)
%function to graph the raw data and high-pass filtered data side by side to
%identify bad wires
%
%Inputs:
%   sessionConf
%   optional: numSegments -- the number of segments
%             segmentLength -- length of segment
%             'validMask' -- only plot the wires that are valid
%             tWindow - [tStart,tEnd] of plot
% Ex: showRawTetrodeWires(sessionConf, 'validMask',0,'tWindow',[5,6])
%
%Outputs:
%   none
%   Displays figure with 8 graphs, raw data on the left and filtered data
%   on the right

    numSegments = 3;
    segmentLength = 5e4;
    validMaskSwitch = 0;
    tWindow = 0 ;
    for iarg = 1 : 2 : nargin - 1
        switch varargin{iarg}
            case 'numSegments'
                numSegments = varargin{iarg + 1};
            case 'segmentLength'
                segmentLength = varargin{iarg + 1};
            case 'tWindow'
                tWindow = varargin{iarg +1};
                numSegments = 1;
            case 'validMask'
                validMaskSwitch = 1;
        end
    end

    
    leventhalPaths = buildLeventhalPaths(sessionConf);
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    disp(['Found ',num2str(length(fullSevFiles)),' SEV files...']);
    
    if validMaskSwitch == 0
        validTetrodes = sessionConf.chMap(:,1);
    else
        %Combine both singlesWires and validTetrodes into list of valid
        %ports
        validTetrodes = [find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));...
             find(any(sessionConf.singleWires,2).*sessionConf.chMap(:,1))];
    end
    
    %create a path for the figure to be saved
    figurePath = fullfile(leventhalPaths.graphs,'rawTetrodeWires');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

%     hsRaw = cell(4,1);
%     hsHp = cell(4,1);
    %Loop through valid tetrodes to get the tetrode names and channels
    for iTet=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(iTet)};
        tetrodeChannels = sessionConf.chMap(validTetrodes(iTet),2:end);
        % handle issue of only having 64 SEV files but 128 in chMap
        if min(tetrodeChannels) > length(fullSevFiles)
            disp(['Breaking at ',tetrodeName,' (no more SEV files)']);
            break;
        end
        tetrodeFilenames = fullSevFiles(tetrodeChannels);
        %Loop through each segment
        for iSeg=1:numSegments
            h = formatSheet();
            hold on;
            %Loop through each channel
            for iCh=1:4
                disp(['Reading ',tetrodeFilenames{iCh}]);
                %Read in data from eat SEV file
                [sev,header] = read_tdt_sev(tetrodeFilenames{iCh});
                %find the start and end points for the graph
                if tWindow == 0
                    segmentStart = round(length(sev)/(numSegments+1)*iSeg);
                    segmentEnd = segmentStart + segmentLength;
                else    
                    segmentStart = round(sessionConf.Fs*tWindow(1));
                    segmentEnd   = round(sessionConf.Fs*tWindow(2));
                end
                %create a subplot where raw data is on the left side
                hsRaw(iCh) = subplot(4,2,iCh*2-1);
                %plot the SEV data
               
                %Title the graph
                title([tetrodeName,'w',num2str(iCh),', ',num2str(segmentStart),...
                    ':',num2str(segmentEnd),' raw']);
                if tWindow ==0
                    plot(sev(segmentStart:segmentEnd));
                    xlim([0 segmentLength]);xlabel('samples');
                else
                    plot(linspace(segmentStart./sessionConf.Fs, segmentEnd./sessionConf.Fs,(tWindow(2)-tWindow(1)).*sessionConf.Fs),...
                            sev(segmentStart:segmentEnd-1))
                    xlim([tWindow(1) tWindow(2)]);xlabel('time(s)');
                end
                ylabel('uV');
                
                %Put the subplots for filtered data on the right side
                hsHp(iCh) = subplot(4,2,iCh*2);
                %Plot data filtered through a high pass filter
                
                
                %Name the graph
                title([tetrodeName,'w',num2str(iCh),', ',num2str(segmentStart),...
                    ':',num2str(segmentEnd),' raw']);
                ylim([-500 500]);ylabel('uV');
                if tWindow ==0
                    plot(wavefilter(sev(segmentStart:segmentEnd),6));
                    xlim([0 segmentLength]);xlabel('samples');
                else
                    plot(linspace(segmentStart./sessionConf.Fs, segmentEnd./sessionConf.Fs,(tWindow(2)-tWindow(1)).*sessionConf.Fs),...
                        wavefilter(sev(segmentStart:segmentEnd-1),6))
                    xlim([tWindow(1) tWindow(2)]);xlabel('time(s)');
                end
            end
            linkaxes(hsRaw,'x');
            linkaxes(hsHp,'x');
            if tWindow ==0
                saveas(h,fullfile(figurePath,[tetrodeName,'_',num2str(segmentStart),...
                    '-',num2str(segmentEnd)]),'pdf');
            else
                saveas(h,fullfile(figurePath,[tetrodeName,'_',num2str(tWindow(1)),...
                    '-',num2str(tWindow(2))]),'pdf');
            end
            close(h);
        end
    end
end

function h = formatSheet()
% Function to formatht the page that the figure will be saved in
    h = figure;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperType','A4');
    set(h,'PaperUnits','centimeters');
    set(h,'PaperPositionMode','auto');
    set(h,'PaperPosition', [1 1 28 19]);
end