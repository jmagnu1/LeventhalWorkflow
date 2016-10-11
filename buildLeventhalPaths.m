function leventhalPaths = buildLeventhalPaths(sessionConf)

leventhalPaths = {};
subjectID = sessionConf.ratID;

%create files within the path for rawdata, processed, graphs, and channels
leventhalPaths.rawdata = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-rawdata'],sessionConf.sessionName);
leventhalPaths.processed = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-processed'],sessionConf.sessionName);
leventhalPaths.graphs = fullfile(sessionConf.nasPath,subjectID,[subjectID,'-graphs'],sessionConf.sessionName);
leventhalPaths.analysis =  fullfile(sessionConf.nasPath,subjectID,[subjectID,'-analysis'],sessionConf.sessionName);
leventhalPaths.channels = fullfile(leventhalPaths.rawdata,sessionConf.sessionName);
leventhalPaths.finished = fullfile(leventhalPaths.processed,[sessionConf.sessionName,'_finished']);

allFields = fieldnames(leventhalPaths);
for ii=1:numel(allFields)
    thePath = getfield(leventhalPaths,allFields{ii});
    if ~exist(thePath,'dir')
        disp(['Creating directory: ',thePath]);
        mkdir(thePath);
    end
end
nexPath = fullfile(leventhalPaths.finished,[sessionConf.sessionName '.nex']);
leventhalPaths.nex = '';
if exist(nexPath,'file')
    leventhalPaths.nex = nexPath;
end

% % pass in makeFolders (ie. {'rawdata'})
% if nargin == 2
%     makeFolders = varargin{1};
%     for ii=1:length(makeFolders)
%         %check if the folder is a field
%         if ismember(makeFolders{ii},allFields)
%             if ~exist(leventhalPaths.(makeFolders{ii}),'dir')
%                 mkdir(leventhalPaths.(makeFolders{ii}));
%             end
%         end
%     end
% end