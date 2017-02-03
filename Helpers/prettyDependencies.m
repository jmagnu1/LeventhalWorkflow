function prettyDependencies(depFun)

[fList,pList] = matlab.codetools.requiredFilesAndProducts(depFun);
clc;

disp('File Dependencies');
disp('---');
for ii=1:length(fList)
    disp(fList{ii});
end

disp([10,'Product Dependencies']);
disp('---');
for ii=1:length(pList)
    disp(pList(ii).Name);
end