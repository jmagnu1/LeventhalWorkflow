% run sql_createSessionsFromRaw('R0036');

function showmeSEV(sessionConf,tetrodeNum,wireNum)

leventhalPaths = buildLeventhalPaths(sessionConf);
fullSevFiles = getChFileMap(leventhalPaths.channels);
for ii=wireNum
    sevCh = sessionConf.chMap(tetrodeNum,ii+1);
    [sev,header] = read_tdt_sev(fullSevFiles{sevCh});
    figure('position',[0 100*ii 800 300]);
    startIdx = round((length(sev)/2));
    endIdx = startIdx + round(header.Fs)*5 - 1;
    plot(linspace(0,(endIdx-startIdx)/header.Fs*1000,endIdx-startIdx+1),sev(1,startIdx:endIdx));
    xlabel('ms');
    ylabel('uV');
    xlim([0 (endIdx-startIdx)/header.Fs*1000]);
    title(['ch',num2str(sevCh),', T',num2str(ii),', w',num2str(ii)]);
end