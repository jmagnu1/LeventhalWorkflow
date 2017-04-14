% recordingPath = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0142/R0142-rawdata/R0142_20161216a/R0142_20161216a';

function createDDTFilesFromPath(recordingPath,isSingleWire,Selection)
    % can handle multiple single wires but only one tetrode
    % for tetrode: select 4 channels at a time
    sevFiles = dir(fullfile(recordingPath,'*.sev'));
    sevFilenames = natsort({sevFiles(:).name}');
    if ~exist('Selection','var')
        [Selection,ok] = listdlg('PromptString','Select SEV files:',...
            'SelectionMode','multiple','ListSize',[800 800],'ListString',char(sevFilenames));
    end
    selectedFiles = {sevFilenames{Selection}}';
    
    sevs = [];
    allChs = [];
    sevCount = 1;
    for iFile = 1:length(selectedFiles)
        disp([selectedFiles{iFile}]);
        ch = getSEVChFromFilename(selectedFiles{iFile});
        allChs = [allChs ch];
        sevFile = fullfile(recordingPath,selectedFiles{iFile});
        sevFileParts = strsplit(selectedFiles{iFile},'_');
        sevFileBase = [strjoin({sevFileParts{1:end-1}},'_'),'_ch'];
        [sevFilt,header] = filterSev(sevFile);
        sevs(sevCount,:) = sevFilt;
        if isSingleWire
            ddtFile = strrep(sevFile,'.sev','.ddt');
            ddt_write_v(ddtFile,1,length(sevFilt),header.Fs,sevs/1000);
            sevCount = 1;
        else
            sevs(sevCount,:) = sevFilt;
            sevCount = sevCount + 1;
        end
    end
    if ~isSingleWire
        multFilename = [sevFileBase,'[',num2str(allChs),']','.ddt'];
        ddtFile = fullfile(recordingPath,multFilename);
        ddt_write_v(ddtFile,sevCount-1,length(sevFilt),header.Fs,sevs/1000);
    end
end