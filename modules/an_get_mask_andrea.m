function [ out_file_name ] = an_get_mask_andrea( bf_file, fl_file, ot_file, fold_path )
% function [ out_file_name ] = an_get_mask_andrea( bf_file, fl_file, ot_file,img_write_path,fold_path )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% out_file_name=[img_write_path,'out_bf_mask.tif'];
for file_count=1:length(bf_file)
    bf_name=bf_file(file_count).name;
    fl_name=fl_file(file_count).name;
    ot_name=ot_file(file_count).name;
    
    bf_img=mat2gray(imread([fold_path,bf_name]));
    fl_img=mat2gray(imread([fold_path,fl_name]));
    
    imshow(bf_img*2+imadjust(fl_img),[])
    pro_totMask = zeros( size(bf_img) ); % accumulate all single object masks to this one
    h = imfreehand( gca ); setColor(h,'red');
    position = wait( h );
    BW = createMask( h );
    count=0;
    while sum(BW(:)) > 300 % less than 10 pixels is considered empty mask
        count=count+1;
        pro_totMask(BW) = count; % add mask to global mask
        % you might want to consider removing the old imfreehand object:
        %       delete( h ); % try the effect of this line if it helps you or not.
        
        % ask user for another mask
        h = imfreehand( gca ); setColor(h,'red');
        position = wait( h );
        BW = createMask( h );
    end
    
    out_file_name=[fold_path,ot_name];
%     if file_count==1
        imwrite(uint8(pro_totMask),out_file_name, 'tif' )
%     else
%         imwrite(uint8(pro_totMask),out_file_name,'tif','WriteMode','append')
%     end
    
    close
    
end


end

