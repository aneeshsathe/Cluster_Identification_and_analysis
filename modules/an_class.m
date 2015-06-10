classdef an_class
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        in_thresh
    end
    
    methods
        function a=an_class(in_thresh)
            a.in_thresh=in_thresh;
        end
        
         function out_img = cleanobj( in_img,fl_img)
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
            
            thresh_fields=fieldnames(a.in_thresh);
            
            clus_round = mat2cell((4*[bw_props.Area]*pi./[bw_props.Perimeter].^2), 1, ones(1, 1, numel(bw_props)));
            
            [bw_props(1:numel(bw_props)).Roundness] = deal(clus_round{:});
            
            for count=1:length(bw_props)
                %     bw_props(count).Roundness=(4*bw_props(count).Area*pi)/(bw_props(count).Perimeter.^2);
                
                pick_region=zeros(1,numel(thresh_fields));
                for t_count=1:numel(thresh_fields)
                    
                    if bw_props(count).(thresh_fields{t_count})>=a.in_thresh.(thresh_fields{t_count})
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
        
    end
    
    methods(Static)
        function out_bb=bb(in_bb)
            out_bb= [floor(in_bb(1)),floor(in_bb(2)),floor(in_bb(3))-1,floor(in_bb(4))-1];
            
        end
        
        function out_img = auto_thresh(I)
            %AN_GRAY returns graythresholded img
            %   Detailed explanation goes here
            
            out_img=im2bw(I,graythresh(I));
        end

%%  
%         function out_img = cleanobj( in_img,fl_img, in_thresh )
%             %UNTITLED2 Summary of this function goes here
%             %   Detailed explanation goes here
%             
%             in_img=imopen(in_img,strel('disk',3));
%             
%             area_th=10;
%             out_img=zeros(size(in_img));
%             
%             bw_props=regionprops(bwareaopen(in_img,area_th),fl_img,...
%                 'PixelIdxList','MeanIntensity',...
%                 'Area','MajorAxisLength','MinorAxisLength','Perimeter',...
%                 'EquivDiameter', 'Eccentricity', 'Solidity'...
%                 );
%             
%             thresh_fields=fieldnames(in_thresh);
%             
%             clus_round = mat2cell((4*[bw_props.Area]*pi./[bw_props.Perimeter].^2), 1, ones(1, 1, numel(bw_props)));
%             
%             [bw_props(1:numel(bw_props)).Roundness] = deal(clus_round{:});
%             
%             
%             
%             for count=1:length(bw_props)
%                 %     bw_props(count).Roundness=(4*bw_props(count).Area*pi)/(bw_props(count).Perimeter.^2);
%                 
%                 pick_region=zeros(1,numel(thresh_fields));
%                 for t_count=1:numel(thresh_fields)
%                     
%                     if bw_props(count).(thresh_fields{t_count})>=in_thresh.(thresh_fields{t_count})
%                         pick_region(t_count)=1;
%                     end
%                     %         disp(pick_region)
%                 end
%                 %     disp(pick_region)
%                 if all(pick_region)==1
%                     out_img(bw_props(count).PixelIdxList)=in_img(bw_props(count).PixelIdxList);
%                 end
%                 
%                 
%             end
%             % a=5;
%             
%         end
%         
%%
        function [ out_file_name ] = getmask( bf_file, fl_file, ot_file, fold_path )
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
                while sum(BW(:)) > 10 % less than 10 pixels is considered empty mask
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
        
        function [ bf_file, fl_file, ot_file ] = filenamegen( file_list )
            %UNTITLED3 Summary of this function goes here
            %   Detailed explanation goes here
            
            file_count=0;
            
            for count=1:length(file_list)
                
                nm=strfind(file_list(count).name,'TRITC');
                
                if ~isempty(nm)
                    file_count=file_count+1;
                    
                    fl_file(file_count).name=file_list(count).name;
                    
                    for count2=1:length(file_list)
                        if ~isempty(strfind(file_list(count2).name,fl_file(file_count).name(1:nm-3)))
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
        
        function saveresults(img_write_path,Sheet1T,Sheet2T,in_thresh)
            xls_name=[img_write_path,'results_',date,'.xlsx'];
            warning('off','MATLAB:xlswrite:AddSheet');
            writetable(Sheet1T,xls_name,'Sheet','ClustPerCell')
            writetable(Sheet2T,xls_name,'Sheet','ClustProp')
            writetable(struct2table(in_thresh),xls_name,'Sheet','ThresholdSettings')
            %Remove Default Sheets
            RemoveSheet123(xls_name);
        end
        
        function saveImages( totMask,out_im1,out_im2,out_im3,out_im4,pix_list,img_write_path,fluo_name )
            %UNTITLED3 Summary of this function goes here
            %   Detailed explanation goes here
            tMp=bwperim(totMask);
            
            RGB = insertText(out_im1+tMp,vertcat(pix_list.Centroid),1:numel(pix_list),'AnchorPoint','LeftBottom','FontSize',40);
            %     imshow(RGB)
            
            %     out_im=[repmat(out_im1+tMp,1,1,3),repmat(out_im2+tMp,1,1,3);repmat(out_im3+tMp,1,1,3),repmat(out_im4+tMp,1,1,3)];
            out_im=[RGB,repmat(out_im2+tMp,1,1,3);repmat(out_im3+tMp,1,1,3),repmat(out_im4+tMp,1,1,3)];
            
            imwrite(out_im,[img_write_path,'OUTcell_',fluo_name],'tif')
            
        end


        
        
    end
    
end

