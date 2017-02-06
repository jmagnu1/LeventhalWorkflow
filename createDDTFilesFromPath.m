% recordingPath = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0142/R0142-rawdata/R0142_20161216a/R0142_20161216a';

function createDDTFilesFromPath(recordingPath)
    sevFiles = dir(fullfile(recordingPath,'*.sev'));
    sevFilenames = natsort({sevFiles(:).name}');
    [Selection,ok] = listdlg('PromptString','Select SEV files:',...
            'SelectionMode','multiple','ListSize',[800 500],'ListString',char(sevFilenames));
    selectedFiles = {sevFilenames{Selection}}';
    for iFile = 1:length(selectedFiles)
        disp([selectedFiles{iFile}]);
        sevFile = fullfile(recordingPath,selectedFiles{iFile});
        [sevFilt,header] = filterSev(sevFile);
        ddtFile = strrep(sevFile,'.sev','.ddt');
        ddt_write_v(ddtFile,1,length(sevFilt),header.Fs,sevFilt/1000);
    end
end