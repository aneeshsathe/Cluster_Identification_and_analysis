function [out_table1,out_table2] = an_write_excel_andrea( out_img, crop_im,fluo_name,obj_count )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% in_props2=regionprops(logical(out_img),crop_im,'MeanIntensity','Area','PixelIdxList');
in_props2=regionprops(logical(out_img),crop_im,...
    'MeanIntensity','Area','Perimeter','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'EquivDiameter','Solidity');


Intensity=([in_props2.MeanIntensity].*[in_props2.Area])';
Roundness=((4*[in_props2.Area]*pi)./([in_props2.Perimeter].^2))';
clus_num=numel(in_props2);

FileName=repmat({fluo_name},clus_num,1);
CellNo=repmat(obj_count,clus_num,1);

ClusterNo=(1:clus_num)';
if clus_num>0
% ClusterNo=(1:clus_num)';
clus_sum_area= sum([in_props2(:).Area]);
clus_mean=mean([in_props2(:).Area]);
clus_min= min([in_props2(:).Area]);
clus_max= max([in_props2(:).Area]);
clus_median= median([in_props2(:).Area]);
cell_clus_prop= {in_props2(:).Area};
else
%     ClusterNo=0;
clus_sum_area= 0;
clus_mean=0;
clus_min= 0;
clus_max= 0;
clus_median= 0;
cell_clus_prop= {0};
end

% out_table1=table({fluo_name},obj_count,clus_num, clus_sum_area,clus_mean,clus_min,clus_max,clus_median,cell_clus_prop(:)');
% numel(cell_clus_prop)>1
if numel(cell_clus_prop)>1
out_table1=[table({fluo_name},obj_count,clus_num, clus_sum_area,clus_mean,clus_min,clus_max,clus_median, ...
    'VariableNames',{'FileName','CellNo','NoOfClusters','TotalArea','MeanArea','MinArea','MaxArea', 'MedianArea'}),...
    cell2table(cell_clus_prop,'VariableNames',strseq('AreaClusNo',1:numel(cell_clus_prop)))];
else
    out_table1=[table({fluo_name},obj_count,clus_num, clus_sum_area,clus_mean,clus_min,clus_max,clus_median, ...
    'VariableNames',{'FileName','CellNo','NoOfClusters','TotalArea','MeanArea','MinArea','MaxArea', 'MedianArea'}),...
    table(cell_clus_prop{:},'VariableNames',strseq('AreaClusNo',1:numel(cell_clus_prop)))];
end


out_table2=table(FileName,CellNo, ClusterNo,Intensity);
out_table2=[out_table2,struct2table(in_props2),table(Roundness)];


end

%% TRASH
% Area=[in_props2.Area]';
% MeanIntensity=[in_props2.MeanIntensity]';
% out_table2=table(FileName,CellNo, ClusterNo,Area,MeanIntensity);




