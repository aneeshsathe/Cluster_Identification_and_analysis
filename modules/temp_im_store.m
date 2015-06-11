function [ out_im ] = temp_im_store( in_img, out_im, temp_im, x_list, y_list,PixelIdxList )
%TEMP_IM_STORE Summary of this function goes here
%   Detailed explanation goes here
temp_im(x_list,y_list)=in_img;
% temp_im(PixelIdxList)=in_img;
out_im(PixelIdxList)=temp_im(PixelIdxList);

end

