function check_nexData(nexData)

disp(char(repmat(46,1,20)));
for ii=1:length(nexData.events)
    disp([num2str(ii),': ',nexData.events{ii}.name,', ',num2str(length(nexData.events{ii}.timestamps)),' events']);
end
disp(char(repmat(46,1,20)));