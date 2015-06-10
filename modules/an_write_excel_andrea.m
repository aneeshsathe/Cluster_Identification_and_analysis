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



out_table1=table({fluo_name},obj_count,clus_num,'VariableNames',{'FileName','CellNo','NoOfClusters'});

out_table2=table(FileName,CellNo, ClusterNo,Intensity);
out_table2=[out_table2,struct2table(in_props2),table(Roundness)];


end

%% TRASH
% Area=[in_props2.Area]';
% MeanIntensity=[in_props2.MeanIntensity]';
% out_table2=table(FileName,CellNo, ClusterNo,Area,MeanIntensity);




