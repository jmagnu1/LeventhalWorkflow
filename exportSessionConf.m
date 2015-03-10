function sessionConf = exportSessionConf(sessionName,varargin)
% This function exports a configuration file for a session so
% that processing can be offloaded to a non-networked machine.
% INPUTS:
%   sessionName : ex. R0036_20150225a
%   varargin, saveDir: where you want this config file save, right now the
%   extractSpikesTDT script prompts for the location of this file

for iarg = 1 : 2 : nargin - 1
    switch varargin{iarg}
        case 'sessionConfPath'
            sessionConfPath = varargin{iarg + 1};
    end
end

sessionConf = struct;
sessionConf.sessionName = sessionName;
[~,sessionConf.ratID] = sql_getSubjectFromSession(sessionName);
chMap = sql_getChannelMap(sessionConf.ratID);
sessionConf.chMap = chMap.chMap;
sessionConf.validMasks = sql_getAllTetChannels(sessionConf.sessionName);
sessionConf.tetrodeNames = chMap.tetNames;

sessionConf.nasPath = sql_findNASpath(sessionConf.ratID);
leventhalPaths = buildLeventhalPaths(sessionConf.nasPath,sessionConf.sessionName);
sevFiles = dir(fullfile(leventhalPaths.session,'*.sev'));
header = getSEVHeader(fullfile(leventhalPaths.session,sevFiles(1).name));
sessionConf.Fs = header.Fs;

sessionConf.waveLength = 24;
sessionConf.peakLoc = 8;
sessionConf.deadTime = round(sessionConf.Fs/1000); %see getSpikeLocations.m

if exist('sessionConfPath','var')
    filename = ['session_conf_',sessionName,'.mat'];
    filePath = fullfile(sessionConfPath,filename);
    save(filePath,'sessionConf');
    sessionConf.file = filePath;
end