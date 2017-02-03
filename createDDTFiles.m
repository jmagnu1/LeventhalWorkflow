function createDDTFiles(sessionConf)
% 20161013: [Investigating whether or not sampling rate and general timing
% is maintained across workflow]
% I used this function to generate a DDT file based on a long
% ephys recording where I turned on the PZ4 roughly 80 minutes into the
% recording, creating a well defined "blip". Next I used a threshold to
% identify the blip in Offline Sorter and exported the single timestamp to
% a NEX file, and then compared that timestamp to the one I got from
% plotting the original data: 4.095999975106679e-05 (seconds)
% From this I can confidently say the discrepency is negligable and this
% workflow is solid.
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