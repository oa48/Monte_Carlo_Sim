function [num] = monToNum(mon)

if strcmp('Jan', mon)
    num = 1;
elseif strcmp('Feb', mon)
    num = 2;
elseif strcmp('Mar', mon)
    num = 3;
elseif strcmp('Apr', mon)
    num = 4;
elseif strcmp('May', mon)
    num = 5;
elseif strcmp('Jun', mon)
    num = 6;
elseif strcmp('Jul', mon)
    num = 7;
elseif strcmp('Aug', mon)
    num = 8;
elseif strcmp('Sep', mon)
    num = 9;
elseif strcmp('Oct', mon)
    num = 10;
elseif strcmp('Nov', mon)
    num = 11;
elseif strcmp('Dec', mon)
    num = 12;
end
end