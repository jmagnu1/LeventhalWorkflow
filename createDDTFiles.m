function createDDTFiles(sessionConf)
    validChannelMatrix = sessionConf.chMap(:,2:end).*sessionConf.validMasks;

    for ii=1:length(validChannelMatrix)
        % skip row if all are zeros
        if isempty(nonzeros(validChannelMatrix(ii,:)))
            continue;
        end
        channelsToConvert = validChannelMatrix(ii,:);

        if sessionConf.singleWires(ii) == 0
            sevs = [];
            for iCh=1:4
                if channelsToConvert(iCh) == 0
                    continue;
                end
                disp(['Working on ch',num2str(channelsToConvert(iCh))]);
                sevFile = sessionConf.sevFiles{channelsToConvert(iCh)};
                [sevFilt,header] = filterSev(sevFile);
                if isempty(sevs) % initialize
                    sevs = zeros(4,length(sevFilt));
                end
                sevs(iCh,:) = sevFilt;
            end
            writePath = fullfile(sessionConf.leventhalPaths.processed,[sessionConf.sessionName,'_','T',num2str(ii),'_ch',mat2str(channelsToConvert),'.ddt']);
            ddt_write_v(writePath,4,length(sevFilt),header.Fs,sevs/1000);
        else
            sevs = [];
            for iCh=1:4
                if channelsToConvert(iCh) == 0
                    continue;
                end
                singleWireChannels = zeros(1,4);
                singleWireChannels(iCh) = channelsToConvert(iCh);
                disp(['Working on ch',num2str(channelsToConvert(iCh))]);
                sevFile = sessionConf.sevFiles{channelsToConvert(iCh)};
                [sevFilt,header] = filterSev(sevFile);
                sevs(1,:) = sevFilt;
                writePath = fullfile(sessionConf.leventhalPaths.processed,[sessionConf.sessionName,'_','T',num2str(ii),'_ch',mat2str(singleWireChannels),'.ddt']);
                ddt_write_v(writePath,1,length(sevFilt),header.Fs,sevs/1000);
            end
        end
    end
end

function [sevFilt,header] = filterSev(sevFile)
    [b,a] = butter(4, [0.02 0.5]); % high pass
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = filtfilt(b,a,double(sev));
    sevFilt = artifactThresh(sevFilt,1,1000);
end