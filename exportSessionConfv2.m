function sessionConf = exportSessionConfv2(sessions__name,varargin)
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
[sessionConf.subjects__id,sessionConf.subjects__name] = sqlv2_getSubjectFromSession(sessions__name);
% eib_electrodes = sqlv2_getEibElectrodes(sessionConf.subjects__id);
sessionConf.session_electrodes = sqlv2_getSessionElectrodes(sessionConf.sessions__name);

if exist('nasPath','var')
    sessionConf.nasPath = nasPath;
else
    sessionConf.nasPath = sqlv2_findNASpath(sessionConf.subjects__name);
end

sessionConf.leventhalPaths = buildLeventhalPathsv2(sessionConf);
% sessionConf.leventhalPaths = leventhalPaths;
sessionConf.sevFiles = getChFileMap(sessionConf.leventhalPaths.channels);

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