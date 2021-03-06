clear;clc;
tic
%%

fold_path='Y:\Andrea_EPH_cluster\Data\';

in_thresh.Area=500;
in_thresh.MajorAxisLength=5;
in_thresh.MinorAxisLength=5;
in_thresh.MeanIntensity=0.1;
% in_thresh.Perimeter=15;
% in_thresh.EquivDiameter=3.5;
% in_thresh.Eccentricity=0.45;
% in_thresh.Solidity=0.55;
% in_thresh.Roundness=0.2;

%Adjust local contrast enchancement parameter
lcep=[8 8]; %To divide cropped cell into M*N tiles

%%
addpath(genpath([fileparts(mfilename('fullpath')),'\modules\']))

%%
img_write_path=[fold_path,'results',date,'\'];

mkdir(img_write_path)

%% Get File names

file_list=dir([fold_path,'*.tif']);
[ bf_file, fl_file, ot_file ]= an_class.filenamegen (file_list);
% [ bf_file, fl_file, ot_file ]=an_file_gen_andrea(file_list);



%% Cells already outlined?

% cell_out=input('Options:\n1) Outline cells\n2) Use file of outlined cells\n 3) Enter full filepath to outlined cells stack eg: C:\Images\xyzfolder\out_bf_mask.tif\nEnter 1,2 or 3:');
cell_out=input('Options:\n1) Outline cells\n2) Use file of outlined cells\n \nEnter 1 or 2:');

if cell_out==1
    disp('Outline, then double-click to confirm. Double-click for next image.')
    % Create BF masks
    [ out_file_name ] =an_class.getmask( bf_file, fl_file, ot_file, fold_path );
    return
else
    out_file_name=[img_write_path,'out_bf_mask.tif'];
end


%%
myfilter = fspecial('gaussian',[15 15], 0.5);

for file_count=1:length(bf_file)
    fluo_name=fl_file(file_count).name;
    fl_img_raw=imread([fold_path,fluo_name]);
    fl_img=mat2gray(fl_img_raw);
    
    totMask=imread([fold_path,ot_file(file_count).name]);
    
    [out_im1,out_im2,out_im3,out_im4]=deal(zeros(size(totMask)));
    
    pix_list=regionprops(totMask,'PixelIdxList','BoundingBox','Image','Centroid');
    
    for obj_count=1:length(pix_list)
        bb=an_class.bb(pix_list(obj_count).BoundingBox);

        crop_im=imcrop(fl_img,bb);
        temp_cl_img=imfilter(imadjust(crop_im),myfilter, 'replicate');
        temp_cl_img=an_class.auto_thresh(adapthisteq(temp_cl_img,'NumTiles',lcep,'Distribution','rayleigh')).*pix_list(obj_count).Image;
        
        out_img =an_class.cleanobj( temp_cl_img,mat2gray(crop_im),in_thresh);
         

        y_list=bb(1):bb(1)+bb(3);
        x_list=bb(2):bb(2)+bb(4);
        
        out_im1(x_list,y_list)=imadjust(imcrop(fl_img,bb)).*pix_list(obj_count).Image;
        out_im2(x_list,y_list)=temp_cl_img;
        out_im3(x_list,y_list)=out_img;
        out_im4(x_list,y_list)=imadjust(imcrop(fl_img,bb)).* out_img;
        %         imwrite(out_im,[img_write_path,'cell_',num2str(obj_count),'_',fluo_name],'tif')
        
        if file_count==1&&obj_count==1
            [Sheet1T,Sheet2T] = an_write_excel_andrea( out_img, imcrop(fl_img_raw,bb),fluo_name,obj_count );
        else
            [out_table1,out_table2] = an_write_excel_andrea( out_img,  imcrop(fl_img_raw,bb),fluo_name,obj_count );
            Sheet1T=[Sheet1T;out_table1];
            Sheet2T=[Sheet2T;out_table2];
        end
        
        disp(['Image ', num2str(file_count) ,' of ',num2str(length(bf_file)),'  Cell ', num2str(obj_count), ' of ', num2str(length(pix_list))])
    end
    %Write Images
    an_class.saveImages( totMask,out_im1,out_im2,out_im3,out_im4,pix_list,img_write_path,fluo_name )
    
end

%% Write Excel
an_class.saveresults(img_write_path,Sheet1T,Sheet2T,in_thresh)

disp('Done Writing Excel File')
toc
