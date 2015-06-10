function [ bf_file, fl_file, ot_file ] = an_file_gen_andrea( file_list )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

file_count=0;

for count=1:length(file_list)
    
    nm=strfind(file_list(count).name,'TRITC');
    
    if ~isempty(nm)
        file_count=file_count+1;
        
        fl_file(file_count).name=file_list(count).name;        
        
        for count2=1:length(file_list)
            if ~isempty(strfind(file_list(count2).name,fl_file(file_count).name(1:nm-3)))&&isempty(strfind(file_list(count2).name,'TRITC'))
                bf_file(file_count).name=file_list(count2).name;
            end
        end
        
    end
end

%% outline file name gen
for f_c=1:numel(bf_file)
ot_file(f_c).name=[bf_file(f_c).name(1:find(bf_file(f_c).name=='_',1,'last')),'OT.TIF'];
end


end

