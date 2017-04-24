insert into sessions (`subject_id`,`name`,`date`,`time`,`behavior_id`,`ephys_system_id`,`chamber_id`,`comment`) values(142,'R0142_20161218a','2016/12/18','00:00:00',3,2,2,'');

nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
sessionConf = exportSessionConfv2('R0142_20161201a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);
processedPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\R0117\R0117-processed';
combineSessionNex_wf(processedPath);