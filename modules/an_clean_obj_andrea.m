function out_img = an_clean_obj_andrea( in_img,fl_img, in_thresh )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

in_img=imopen(in_img,strel('disk',3));

area_th=10;
out_img=zeros(size(in_img));

bw_props=regionprops(bwareaopen(in_img,area_th),fl_img,...
    'PixelIdxList','MeanIntensity',...
    'Area','MajorAxisLength','MinorAxisLength','Perimeter',...
    'EquivDiameter', 'Eccentricity', 'Solidity'...
    );

thresh_fields=fieldnames(in_thresh);

clus_round = mat2cell((4*[bw_props.Area]*pi./[bw_props.Perimeter].^2), 1, ones(1, 1, numel(bw_props)));

[bw_props(1:numel(bw_props)).Roundness] = deal(clus_round{:});



for count=1:length(bw_props)
    %     bw_props(count).Roundness=(4*bw_props(count).Area*pi)/(bw_props(count).Perimeter.^2);
    
    pick_region=zeros(1,numel(thresh_fields));
    for t_count=1:numel(thresh_fields)        
        
        if bw_props(count).(thresh_fields{t_count})>=in_thresh.(thresh_fields{t_count})
            pick_region(t_count)=1;
        end
        %         disp(pick_region)
    end
    %     disp(pick_region)
    if all(pick_region)==1
        out_img(bw_props(count).PixelIdxList)=in_img(bw_props(count).PixelIdxList);
    end
    
    
end
% a=5;

end

%%
