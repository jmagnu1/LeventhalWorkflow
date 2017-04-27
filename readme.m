insert into sessions (`subject_id`,`name`,`date`,`time`,`behavior_id`,`ephys_system_id`,`chamber_id`,`comment`) values(142,'R0142_20161218a','2016/12/18','00:00:00',3,2,2,'');

subjects__name = 'R0154';
% nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
nasPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask';
sessionConf = exportSessionConfv2([subjects__name,'_20170228a'],'nasPath',nasPath);
nexData = TDTtoNex(sessionConf);
processedPath = fullfile(nasPath,subjects__name,[subjects__name,'-processed']);
combineSessionNex_wf(processedPath);