function sessionConf = exportSessionConf(sessionName,varargin)
% This function exports a configuration file for a session so
% that processing can be offloaded to a non-networked machine.
% INPUTS:
%   sessionName = 'R0036_20150225a';
%   varargin, saveDir: where you want this config file save

sessionConf = struct;

for iarg = 1 : 2 : nargin - 1
    switch varargin{iarg}
        case 'sessionConfPath'
            sessionConfPath = varargin{iarg + 1};
        case 'nasPath'
            nasPath = varargin{iarg + 1};
    end
end

sessionConf.sessionName = sessionName;
[~,sessionConf.ratID] = sql_getSubjectFromSession(sessionName);
chMap = sql_getChannelMap(sessionConf.ratID);
sessionConf.chMap = chMap.chMap;
sessionConf.tetrodeNames = chMap.tetNames;

%Get tetrode validMasks, lfpChannels
try
    sessionConf.validMasks = sql_getAllTetChannels(sessionConf.sessionName);
    sessionConf.lfpChannels = sql_getLFPChannels(sessionConf.sessionName);
    sessionConf.singleWireIndex = sql_getSingleWires(sessionConf.sessionName); 
    
    %Code that sorts the initial validMasks into tetrode and single wire
    %matrices
    temp = sessionConf.singleWireIndex*ones(1,4);
    sessionConf.singleWires = sessionConf.validMasks.*temp;
    sessionConf.validMasks = sessionConf.validMasks.*(1-temp);
catch
    disp('No tetrode session found: validMasks and lfpChannels not valid');
end

if exist('nasPath','var')
    sessionConf.nasPath = nasPath;
else
    sessionConf.nasPath = sql_findNASpath(sessionConf.ratID);
end

leventhalPaths = buildLeventhalPaths(sessionConf);
sessionConf.leventhalPaths = leventhalPaths;
sessionConf.sevFiles = getChFileMap(leventhalPaths.channels);

sessionConf.Fs = 0;
if isempty([sessionConf.sevFiles])
    disp('No SEV files found');
else
    idx = find(cellfun('isempty',sessionConf.sevFiles) == 0);
    header = getSEVHeader(sessionConf.sevFiles{idx(1)});
    sessionConf.Fs = header.Fs;
end

if exist('sessionConfPath','var')
    filename = ['session_conf_',sessionName,'.mat'];
    filePath = fullfile(sessionConfPath,filename);
    save(filePath,'sessionConf');
    sessionConf.file = filePath;
end