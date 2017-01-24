function strList = appendLetters2String(baseString)
% function to add "a", "b", "c", etc. to a base string
%
% INPUTS:
%   baseString - string to which a letter should be appended
%
% OUTPUTS:
%   strList - character array where each row is baseString with a lower
%       case ltter appended to it

letList = 'abcdefghijklmnopqrstuvwxyz';
strList = [baseString letList(1)];

for ii = 2 : length(letList)
    strList(ii,:) = [baseString letList(ii)];
end