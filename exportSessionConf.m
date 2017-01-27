function sessionConf = exportSessionConf(sessions__name,varargin)
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

sessionConf.sessions__name = sessions__name;
[sessionConf.subjects__id,sessionConf.subjects__name] = sql_getSubjectFromSession(sessions__name);
eib_electrodes = sqlv2_getEibElectrodes(sessionConf.subjects__id);
session_electrodes = sqlv2_getSessionElectrodes(sessionConf.sessions__name);

% % chMap = sql_getChannelMap(sessionConf.subjects__name);
% % sessionConf.chMap = chMap.chMap;
% % sessionConf.tetrodeNames = chMap.tetNames;

%Get tetrode validMasks, lfpChannels
% % try
% %     sessionConf.validMasks = sql_getAllTetChannels(sessionConf.sessions__name);
% %     sessionConf.lfpChannels = sql_getLFPChannels(sessionConf.sessions__name);
% %     sessionConf.singleWires = sql_getSingleWires(sessionConf.sessions__name); 
% % catch
% %     disp('No tetrode session found: validMasks and lfpChannels not valid');
% % end

if exist('nasPath','var')
    sessionConf.nasPath = nasPath;
else
    sessionConf.nasPath = sql_findNASpath(sessionConf.subjects__name);
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
    filename = ['session_conf_',sessions__name,'.mat'];
    filePath = fullfile(sessionConfPath,filename);
    save(filePath,'sessionConf');
    sessionConf.file = filePath;
end