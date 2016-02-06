function leventhalPaths = buildLeventhalPaths(sessionConf,varargin)

leventhalPaths = {};
subjectID = sessionConf.sessionName(1:5);

%create files within the path for rawdata, processed, graphs, and channels
leventhalPaths.rawdata = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-rawdata'],sessionConf.sessionName);
leventhalPaths.processed = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-processed'],sessionConf.sessionName);
leventhalPaths.graphs = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-graphs'],sessionConf.sessionName);
leventhalPaths.channels = fullfile(leventhalPaths.rawdata,sessionConf.sessionName);
leventhalPaths.finished = fullfile(leventhalPaths.processed,[sessionConf.sessionName,'_finished']);


% pass in makeFolders (ie. {'rawData'})
if nargin == 2
    makeFolders = varargin{1};
    allFields = fieldnames(leventhalPaths);
    for ii=1:length(makeFolders)
        %check if the folder is a field
        if ismember(makeFolders{ii},allFields)
            if ~exist(leventhalPaths.(makeFolders{ii}),'dir')
                mkdir(leventhalPaths.(makeFolders{ii}));
            end
        end
    end
end