function check_dataCollection(nasPath,subjectID,varargin)
    % either enter start and end sessions, or just the single session to check
    % usage: check_dataCollection('/Volumes/RecordingsLeventhal2/ChoiceTask','R0088','20151027a','20151102a');
    %[] tally missing files
    
    rawdata = fullfile(nasPath,subjectID,[subjectID,'-rawdata']);
    folders = dir(rawdata);

    sessionStart = varargin{1};
    sessionEnd = '';
    if length(varargin) == 2
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

        tab = 1;
        searchFor('log',rawdata,foldersName,tab);
        searchFor('tsq',rawdata,foldersName,tab);
        searchFor('tev',rawdata,foldersName,tab);
        searchFor('avi',rawdata,foldersName,tab);
        
        sessionContents = dir(fullfile(rawdata,foldersName,foldersName));
        if isempty(sessionContents)
            formatDisp(false,'Ephys',0,tab);
        else
            formatDisp(true,'Ephys',sum([sessionContents(:).bytes]),tab);
        end
        
        tab = 2;
        sessionContents = dir(fullfile(rawdata,foldersName,'sleep'));
        if isempty(sessionContents)
            formatDisp(false,'Sleep',0,tab);
        else
            disp([tabChars(tab-1),fullfile(foldersName,'sleep')]);
            searchFor('log',rawdata,fullfile(foldersName,'sleep'),tab);
            searchFor('tsq',rawdata,fullfile(foldersName,'sleep'),tab);
            searchFor('tev',rawdata,fullfile(foldersName,'sleep'),tab);
            searchFor('avi',rawdata,fullfile(foldersName,'sleep'),tab);
            sessionContents = dir(fullfile(rawdata,foldersName,'sleep',[foldersName,'_sleep']));
            if isempty(sessionContents)
                formatDisp(false,'Sleep Ephys',0,tab);
            else
                formatDisp(true,'Sleep Ephys',sum([sessionContents(:).bytes]),tab);
            end
        end
        
        fprintf('\n')

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

function searchFor(searchTerm,rawdata,foldersName,tab)
    sessionContents = dir(fullfile(rawdata,foldersName,['*.',searchTerm]));
    if isempty(sessionContents)
        formatDisp(false,searchTerm,0,tab);
    else
        formatDisp(true,searchTerm,sessionContents(1).bytes,tab);
    end
end

function formatDisp(found,label,bytes,tab)
    if found
        disp([tabChars(tab),'[X] ',upper(label),' (',formatBytes(bytes),')']);
    else
        disp([tabChars(tab),'[ ] ',upper(label)]);
    end
end

function t = tabChars(tab)
    t = char(repmat(32,1,tab*4));
end