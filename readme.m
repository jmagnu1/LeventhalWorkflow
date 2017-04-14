nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
sessionConf = exportSessionConfv2('R0142_20161201a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);
processedPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\R0117\R0117-processed';
combineSessionNex_wf(processedPath);