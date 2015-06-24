function [ Sheet1T,out_table1 ] = an_andrea_add_missing( Sheet1T,out_table1 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
out_table1colmissing = setdiff(Sheet1T.Properties.VariableNames, out_table1.Properties.VariableNames);
Sheet1Tcolmissing = setdiff(out_table1.Properties.VariableNames, Sheet1T.Properties.VariableNames);
out_table1 = [out_table1 array2table(nan(height(out_table1), numel(out_table1colmissing)), 'VariableNames', out_table1colmissing)];
Sheet1T = [Sheet1T array2table(nan(height(Sheet1T), numel(Sheet1Tcolmissing)), 'VariableNames', Sheet1Tcolmissing)];
% [Sheet1T;out_table1]

end

