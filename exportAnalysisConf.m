function analysisConf = exportAnalysisConf(subjectID,nasPath)

analysisConf = struct;
analysisConf.ratID = subjectID;
analysisConf.nasPath = nasPath;

% get all data folders that exist
dataDirs = dir2(fullfile(nasPath,subjectID,[subjectID,'-processed']));
allNeurons = {};
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
end

neuronIds = listdlg('PromptString','Select neurons:',...
                'SelectionMode','multiple','ListSize',[200 200],...
                'ListString',allNeurons);

analysisConf.neurons = allNeurons(neuronIds);
