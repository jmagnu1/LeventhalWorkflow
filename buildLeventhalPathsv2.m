function leventhalPaths = buildLeventhalPathsv2(sessionConf)

leventhalPaths = {};
subjects__name = sessionConf.subjects__name;

%create files within the path for rawdata, processed, graphs, and channels
leventhalPaths.rawdata = fullfile(sessionConf.nasPath,subjects__name,[subjects__name,'-rawdata'],sessionConf.sessions__name);
leventhalPaths.processed = fullfile(sessionConf.nasPath,subjects__name,[subjects__name,'-processed'],sessionConf.sessions__name);
leventhalPaths.graphs = fullfile(sessionConf.nasPath,subjects__name,[subjects__name,'-graphs'],sessionConf.sessions__name);
leventhalPaths.analysis =  fullfile(sessionConf.nasPath,subjects__name,[subjects__name,'-analysis'],sessionConf.sessions__name);
leventhalPaths.channels = fullfile(leventhalPaths.rawdata,sessionConf.sessions__name);
leventhalPaths.finished = fullfile(leventhalPaths.processed,[sessionConf.sessions__name,'_finished']);

allFields = fieldnames(leventhalPaths);
for ii=1:numel(allFields)
    thePath = getfield(leventhalPaths,allFields{ii});
    if ~exist(thePath,'dir')
        disp(['Creating directory: ',thePath]);
        mkdir(thePath);
    end
end
nexPath = fullfile(leventhalPaths.finished,[sessionConf.sessions__name '.nex']);
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