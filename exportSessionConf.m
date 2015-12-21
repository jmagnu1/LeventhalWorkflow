function sessionConf = exportSessionConf(sessionName,varargin)
% This function exports a configuration file for a session so
% that processing can be offloaded to a non-networked machine.
% INPUTS:
%   sessionName : ex. R0036_20150225a
%   varargin, saveDir: where you want this config file save, right now the
%   extractSpikesTDT script prompts for the location of this file
%
%sessionConf will contain sessionName, chMap, tetrodeNames, validMasks,
%lfpChannels,singleWireIndex,nasPath
%by Default, nasPath will be path to nas unless you change it through
%varargin to reflect a local path on  your computer

%default settings
sessionConf = struct;
sessionConf.waveLength = 48; %~2ms
sessionConf.peakLoc = 16;  %.65 ms
 %see getSpikeLocations.m

for iarg = 1 : 2 : nargin - 1
    switch varargin{iarg}
        case 'sessionConfPath'
            sessionConfPath = varargin{iarg + 1};
        case 'nasPath'
            nasPath = varargin{iarg + 1};
        case 'peakLoc'
            sessionConf.peakLoc = varargin{iarg+1};
        case 'waveLength'    
            sessionConf.waveLength = varargin{iarg+1};
    end
end

%set up fields of struct

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
sevFiles = dir(fullfile(leventhalPaths.channels,'*.sev'));
if isempty(sevFiles)
    disp('No SEV files found');
    sessionConf.Fs = 0;
else
    header = getSEVHeader(fullfile(leventhalPaths.channels,sevFiles(1).name));
    sessionConf.Fs = header.Fs;
end

sessionConf.deadTime = round(sessionConf.Fs/1000);
%add nexPath(str pointing to combined.nex location) to sessionconf
sessionConf.nexPath = fullfile(leventhalPaths.processed,'Processed',[sessionConf.sessionName '_combined.nex']);

if exist('sessionConfPath','var')
    filename = ['session_conf_',sessionName,'.mat'];
    filePath = fullfile(sessionConfPath,filename);
    save(filePath,'sessionConf');
    sessionConf.file = filePath;
end