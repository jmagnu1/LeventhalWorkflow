function check_dataCollection(nasPath,subjectID,varargin)
    % either enter start and end sessions, or just the single session to check
    % usage: check_dataCollection('/Volumes/RecordingsLeventhal2/ChoiceTask','R0088','20151027a','20151102a');
    rawdata = fullfile(nasPath,subjectID,[subjectID,'-rawdata']);
    folders = dir(rawdata);

    sessionStart = varargin{1};
    sessionEnd = '';
    if nargin == 2
        sessionEnd = varargin{2};
    end

    display = false;
    disp(char(repmat(46,1,20)));
    for ii=1:length(folders)
        if strcmp(folders(ii).name,[subjectID,'_',sessionStart])
            display = true;
        end
        if ~display
            continue;
        end

        foldersName = folders(ii).name;
        disp(foldersName);

        searchFor('log',rawdata,foldersName);
        searchFor('tsq',rawdata,foldersName);
        searchFor('tev',rawdata,foldersName);
        searchFor('avi',rawdata,foldersName);
        
        sessionContents = dir(fullfile(rawdata,foldersName,'sleep'));
        if isempty(sessionContents)
            formatDisp(false,'Sleep Folder');
        else
            disp('-- Sleep Folder');
            searchFor('log',rawdata,fullfile(foldersName,'sleep'));
            searchFor('tsq',rawdata,fullfile(foldersName,'sleep'));
            searchFor('tev',rawdata,fullfile(foldersName,'sleep'));
            searchFor('avi',rawdata,fullfile(foldersName,'sleep'));
        end
        
        disp('');

        if ~isempty(sessionEnd)
            if strcmp(folders(ii).name,[subjectID,'_',sessionEnd])
                display = false;
            end
        else
            display = false;
        end
    end
    disp(char(repmat(46,1,20)));
end

function searchFor(searchTerm,rawdata,foldersName)
    sessionContents = dir(fullfile(rawdata,foldersName,['*.',searchTerm]));
    if isempty(sessionContents)
        formatDisp(false,searchTerm);
    else
        formatDisp(true,searchTerm,sessionContents.bytes);
    end
end

function formatDisp(found,label,bytes)
    if found
        disp(['Found ',upper(label),': ',formatBytes(bytes)]);
    else
        disp(['!!! ',upper(label),' Not Found']);
    end
end