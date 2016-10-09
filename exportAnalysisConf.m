function analysisConf = exportAnalysisConf(ratID,nasPath)

analysisConf = struct;
analysisConf.ratID = ratID;
analysisConf.nasPath = nasPath;
analysisConf.sessionConfs = {};

% get all data folders that exist
dataDirs = dir2(fullfile(nasPath,ratID,[ratID,'-processed']));
allNeurons = {};
allSessionNames = {};
sessionCount = 1;
for iDataDir=1:length(dataDirs)
    if ~dataDirs(iDataDir).isdir
        continue;
    end
    % requires network
    sessionConf = exportSessionConf(dataDirs(iDataDir).name,'nasPath',nasPath);
    analysisConf.sessionConfs{sessionCount} = sessionConf;
    leventhalPaths = buildLeventhalPaths(sessionConf);
    [nvar, names, types] = nex_info(leventhalPaths.nex);
    neuronNames = cellstr(deblank(names(types(:,1)==0,:)));
    allNeurons(sessionCount) = neuronNames;
    for ii=1:length(neuronNames)
        allSessionNames = [allSessionNames;sessionConf.sessionName];
    end
    sessionCount = sessionCount + 1;
end

neuronIds = listdlg('PromptString','Select neurons:',...
                'SelectionMode','multiple','ListSize',[250 500],...
                'ListString',allNeurons);

analysisConf.neurons = allNeurons(neuronIds);
analysisConf.sessionNames = allSessionNames(neuronIds);
