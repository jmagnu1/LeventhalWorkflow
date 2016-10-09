function mappedSevFiles = getChFileMap(channelPath)
    % Function that returns a of SEV files within a channel path
    % Look for all .SEV files within the path that was input
    sevFiles = dir(fullfile(channelPath,'*.sev'));
    mappedSevFiles = cell(length(sevFiles),1);
    for ii=1:length(sevFiles)
        sevCh = getSEVChFromFilename(sevFiles(ii).name);
        mappedSevFiles{sevCh} = fullfile(channelPath,sevFiles(ii).name);
    end
end

function ch = getSEVChFromFilename(name)
    C = strsplit(name,'_');
    C = strsplit(C{end},'.'); %C{1} = chXX
    ch = str2double(C{1}(3:end));
end