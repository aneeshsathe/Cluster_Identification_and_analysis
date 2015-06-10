function an_write_im_andrea( totMask,out_im1,out_im2,out_im3,out_im4,pix_list,img_write_path,fluo_name )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
tMp=bwperim(totMask);

RGB = insertText(out_im1+tMp,vertcat(pix_list.Centroid),1:numel(pix_list),'AnchorPoint','LeftBottom','FontSize',40);
%     imshow(RGB)

%     out_im=[repmat(out_im1+tMp,1,1,3),repmat(out_im2+tMp,1,1,3);repmat(out_im3+tMp,1,1,3),repmat(out_im4+tMp,1,1,3)];
out_im=[RGB,repmat(out_im2+tMp,1,1,3);repmat(out_im3+tMp,1,1,3),repmat(out_im4+tMp,1,1,3)];

imwrite(out_im,[img_write_path,'OUTcell_',fluo_name],'tif')

end

