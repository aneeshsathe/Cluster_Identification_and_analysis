clear;clc;
tic
%%

fold_path='C:\Users\Nyx\Desktop\attachments\';

%set Thresh for bw
in_bw_thresh=0.5;

in_thresh.Area=100;
% in_thresh.MajorAxisLength=5;
% in_thresh.MinorAxisLength=5;
% in_thresh.MeanIntensity=0.1;
% in_thresh.Perimeter=15;
% in_thresh.EquivDiameter=3.5;
% in_thresh.Eccentricity=0.45;
% in_thresh.Solidity=0.55;
% in_thresh.Roundness=0.4;

%Adjust local contrast enchancement parameter
lcep=[4 4]; %To divide cropped cell into M*N tiles

%%
addpath(genpath([fileparts(mfilename('fullpath')),'\modules\']))

%%
img_write_path=[fold_path,'results',date,'\'];

mkdir(img_write_path)

%% Get File names

file_list=dir([fold_path,'*.tif']);

[ bf_file, fl_file, ot_file ]=an_file_gen_andrea(file_list);



%% Cells already outlined?

% cell_out=input('Options:\n1) Outline cells\n2) Use file of outlined cells\n 3) Enter full filepath to outlined cells stack eg: C:\Images\xyzfolder\out_bf_mask.tif\nEnter 1,2 or 3:');
cell_out=input('Options:\n1) Outline cells\n2) Use file of outlined cells\n \nEnter 1 or 2:');

if cell_out==1
    disp('Outline, then double-click to confirm. Double-click for next image.')
    % Create BF masks
    %     [ out_file_name ] = an_get_mask_andrea( bf_file, fl_file, ot_file,img_write_path,fold_path );
    
    [ out_file_name ] = an_get_mask_andrea( bf_file, fl_file, ot_file, fold_path );
    return
    % elseif cell_out==3
    %     out_file_name=input('Enter full filepath to outlined cells stack \neg: C:\Images\xyzfolder\out_bf_mask.tif\nEnter filepath:');
else
    out_file_name=[img_write_path,'out_bf_mask.tif'];
end


%%
myfilter = fspecial('gaussian',[15 15], 0.5);
% myfilter = fspecial('disk',5);
for file_count=1:length(bf_file)
    fluo_name=fl_file(file_count).name;
    fl_img_raw=imread([fold_path,fluo_name]);
    fl_img=mat2gray(fl_img_raw);
    
    totMask=imread([fold_path,ot_file(file_count).name]);
    %     totMask=imread(out_file_name,'Index',file_count);
    
    [out_im1,out_im2,temp_im,out_im3,out_im4]=deal(zeros(size(totMask)));
    
    pix_list=regionprops(totMask,'PixelIdxList','BoundingBox','Image','Centroid','SubarrayIdx');
    
    for obj_count=1:length(pix_list)
        
        %         bb=[floor(pix_list(obj_count).BoundingBox(1)),...
        %             floor(pix_list(obj_count).BoundingBox(2)),...
        %             floor(pix_list(obj_count).BoundingBox(3))-1,...
        %             floor(pix_list(obj_count).BoundingBox(4))-1];
        bb=[floor(pix_list(obj_count).BoundingBox(1)),...
            floor(pix_list(obj_count).BoundingBox(2)),...
            floor(pix_list(obj_count).BoundingBox(3)),...
            floor(pix_list(obj_count).BoundingBox(4))];
        
        %         size(imcrop(fl_img,bb))
        %         size(pix_list(obj_count).Image)
        %         temp_cl_img2=imcrop(fl_img,bb).*pix_list(obj_count).Image;
        %         temp_cl_img=an_gray(imadjust(imcrop(fl_img,bb))).*pix_list(obj_count).Image;
        
        crop_im=fl_img(pix_list(obj_count).SubarrayIdx{:}) ;
        raw_crop_im=fl_img_raw(pix_list(obj_count).SubarrayIdx{:}) ;
        
        %         crop_im=imcrop(fl_img,bb);
        
        temp_cl_img=imfilter(imadjust(crop_im),myfilter, 'replicate');
        %         temp_cl_img=an_gray(adapthisteq(temp_cl_img,'NumTiles',lcep,'Distribution','rayleigh')).*pix_list(obj_count).Image;
        temp_cl_img=an_andr_gray(adapthisteq(temp_cl_img,'NumTiles',lcep,'Distribution','rayleigh'),in_bw_thresh).*pix_list(obj_count).Image;
        
        out_img =an_clean_obj_andrea( temp_cl_img,mat2gray(crop_im),in_thresh);
        
        
        %         y_list=bb(1):bb(1)+bb(3);
        %         x_list=bb(2):bb(2)+bb(4);
        x_list=pix_list(obj_count).SubarrayIdx{1};
        y_list=pix_list(obj_count).SubarrayIdx{2};
        
        
        %         temp_im_store=@(in_img,out_im) temp_im_store(temp_im, in_img,out_im,x_list,y_list,pix_list(obj_count).PixelIdxList );
        
        
        out_im1=temp_im_store( imadjust(crop_im).*pix_list(obj_count).Image, out_im1, temp_im, x_list, y_list, pix_list(obj_count).PixelIdxList );
        out_im2=temp_im_store( temp_cl_img, out_im2, temp_im, x_list, y_list, pix_list(obj_count).PixelIdxList );
        out_im3=temp_im_store( out_img, out_im3, temp_im, x_list, y_list, pix_list(obj_count).PixelIdxList );
        out_im4=temp_im_store( imadjust(crop_im).* out_img, out_im4, temp_im, x_list, y_list, pix_list(obj_count).PixelIdxList );
        
        %         out_im1(pix_list(obj_count).PixelIdxList )=imadjust(crop_im).*pix_list(obj_count).Image;
        %         out_im2(pix_list(obj_count).PixelIdxList )=temp_cl_img;
        %         out_im3(pix_list(obj_count).PixelIdxList )=out_img;
        %         out_im4(pix_list(obj_count).PixelIdxList )=imadjust(crop_im).* out_img;
        
        
        
        
        
        %         out_im1(x_list,y_list)=imadjust(imcrop(fl_img,bb)).*pix_list(obj_count).Image;
        %         temp_im(x_list,y_list)=temp_cl_img;
        
        %         out_im2(pix_list(obj_count).PixelIdxList)=temp_im(pix_list(obj_count).PixelIdxList);
        %         out_im2=temp_im_store( temp_cl_img, out_im2, temp_im, x_list, y_list, pix_list(obj_count).PixelIdxList );
        % out_im2=temp_im_store(temp_cl_img,out_im2);
        %         out_im2(pix_list(obj_count).PixelIdxList)=temp_cl_img(pix_list(obj_count).SubarrayIdx);
        %         out_im3(x_list,y_list)=out_img;
        %         out_im4(x_list,y_list)=imadjust(imcrop(fl_img,bb)).* out_img;
        %         imwrite(out_im,[img_write_path,'cell_',num2str(obj_count),'_',fluo_name],'tif')
        
        if file_count==1&&obj_count==1
            [Sheet1T,Sheet2T] = an_write_excel_andrea( out_img, raw_crop_im,fluo_name,obj_count );
        else
            [out_table1,out_table2] = an_write_excel_andrea( out_img,  raw_crop_im,fluo_name,obj_count );
            
            [ Sheet1T,out_table1 ] = an_andrea_add_missing( Sheet1T,out_table1 );
            Sheet1T=[Sheet1T;out_table1];
            [ Sheet2T,out_table2 ] = an_andrea_add_missing( Sheet2T,out_table2 );
            Sheet2T=[Sheet2T;out_table2];
        end
        
        disp(['Image ', num2str(file_count) ,' of ',num2str(length(bf_file)),'  Cell ', num2str(obj_count), ' of ', num2str(length(pix_list))])
    end
    %Write Images
    an_write_im_andrea( totMask,out_im1,out_im2,out_im3,out_im4,pix_list,img_write_path,fluo_name )
    
end

%% Prepare summary of 
% out_table1colmissing = setdiff(Sheet1T.Properties.VariableNames, out_table1.Properties.VariableNames);
% Sheet1Tcolmissing = setdiff(out_table1.Properties.VariableNames, Sheet1T.Properties.VariableNames);
% out_table1 = [out_table1 array2table(nan(height(out_table1), numel(out_table1colmissing)), 'VariableNames', out_table1colmissing)];
% Sheet1T = [Sheet1T array2table(nan(height(Sheet1T), numel(Sheet1Tcolmissing)), 'VariableNames', Sheet1Tcolmissing)];
% [Sheet1T;out_table1]
%% Write Excel
xls_name=[img_write_path,'results_',date,'.xlsx'];
warning('off','MATLAB:xlswrite:AddSheet');
writetable(Sheet1T,xls_name,'Sheet','ClustPerCell')
writetable(Sheet2T,xls_name,'Sheet','ClustProp')
writetable(struct2table(in_thresh),xls_name,'Sheet','ThresholdSettings')
%Remove Default Sheets
RemoveSheet123(xls_name);

disp('Done Writing Excel File')
toc
