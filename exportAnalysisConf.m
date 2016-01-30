function analysisConf = exportAnalysisConf(ratID,nasPath)

analysisConf = struct;
analysisConf.ratID = ratID;
analysisConf.nasPath = nasPath;

% get all data folders that exist
dataDirs = dir2(fullfile(nasPath,ratID,[ratID,'-processed']));
allNeurons = {};
allSessionNames = {};
for iDataDir=1:length(dataDirs)
    if ~dataDirs(iDataDir).isdir
        continue;
    end
    
    % requires network
    sessionConf = exportSessionConf(dataDirs(iDataDir).name,'nasPath',nasPath);
    if ~exist(sessionConf.nexPath)
        disp(['No NEX: ',sessionConf.nexPath]);
        continue;
    end
    [nvar, names, types] = nex_info(sessionConf.nexPath);
    neuronNames = cellstr(deblank(names(types(:,1)==0,:)));
    allNeurons = [allNeurons;neuronNames];
    for ii=1:length(neuronNames)
        allSessionNames = [allSessionNames;sessionConf.sessionName];
    end
end

neuronIds = listdlg('PromptString','Select neurons:',...
                'SelectionMode','multiple','ListSize',[200 200],...
                'ListString',allNeurons);

analysisConf.neurons = allNeurons(neuronIds);
analysisConf.sessionNames = allSessionNames(neuronIds);
