function createDDTFiles(sessionConf)
% [] handle 50um

leventhalPaths = buildLeventhalPaths(sessionConf,{'processed'});
fullSevFiles = getChFileMap(leventhalPaths.channels); %SLEEP
validChannelMatrix = sessionConf.chMap(:,2:end).*sessionConf.validMasks;
[b,a] = butter(4, [0.02 0.5]);

for ii=1:length(validChannelMatrix)
    if isempty(nonzeros(validChannelMatrix(ii,:)))
        continue;
    end
    sevs = [];
    channelsToConvert = validChannelMatrix(ii,:); %transpose for ease of mat2str later
    for iCh=1:4
        if channelsToConvert(iCh) == 0
            continue;
        end
        disp(['Working on ch',num2str(channelsToConvert(iCh))]);
        [sev,header] = read_tdt_sev(fullSevFiles{channelsToConvert(iCh)});
        sev = filtfilt(b,a,double(sev));
        sev = artifactThresh(sev,1,1000);
        if isempty(sevs)
            sevs = zeros(4,length(sev));
        end
        sevs(iCh,:) = sev;
    end
    disp(['+ Writing DDT for ',mat2str(channelsToConvert)]);
    ddt_write_v(fullfile(leventhalPaths.processed,[sessionConf.sessionName,'_','T',num2str(ii),'_ch',mat2str(channelsToConvert),'.ddt']),...
        4,length(sev),header.Fs,sevs/1000); %SLEEP, processed/sleep
end