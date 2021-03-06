function [CSV_struct] = pvp_makeCSVFileKernel2(frame_pathname, pvp_time, pvp_activity, truth_CSV_struct, other_CSV_struct, DCR_CSV_struct)

  global NFEATURES NCOLS NROWS N
  global pvp_patch_size
  global pvp_density_thresh
  global pvp_training_flag
  global ODD_subdir
  global pvp_reconstruct_sparse
  global make_bootstrap_chips_flag 
  global make_target_mask_flag 

  %%keyboard;
  CSV_struct = struct;
  if ~isempty(pvp_activity)
    pvp_reconstruct_sparse = true;
    CSV_struct.num_active = nnz(pvp_activity);

    CSV_struct.frame_filename = strFolderFromPath(frame_pathname);
    CSV_struct.Frame = CSV_struct.frame_filename(1:strfind(CSV_struct.frame_filename, ".png")-1);
    disp(["Frame = ", CSV_struct.Frame]);
    CSV_struct.pvp_time = pvp_time;
    CSV_struct.mean_activity = mean(pvp_activity(:));
    CSV_struct.sum_activity = sum(pvp_activity(:));
  else
    pvp_reconstruct_sparse = false;
    if 0  %% imfinfo broken...assume N has been defined previously
      frame_info = imfinfo(frame_pathname);
      NCOLS = frame_info.Width;
      NROWS = frame_info.Height;
      if strcmp(frame_info.ColorType, "grayscale")
	NFEATURES = 1;
      else
	NFEATURES = 3;
      endif
      N = NFEATURES * NCOLS * NROWS;
    endif
    pvp_activity = sparse(N, 1);
  endif

  hit_list = [];
  miss_list = [];
  %%keyboard;
  if 0 %% pvp_training_flag == 0   %% no ground truth provided
    [hit_list] = pvp_dbscan(pvp_activity);  
  elseif make_bootstrap_chips_flag
    [pvp_num_active_BB_mask, ...
     pvp_num_active_BB_notmask, ...
     pvp_num_BB_mask, ...
     pvp_num_BB_notmask, ...
     hit_list, ...
     miss_list, ...
     pvp_max_confidence] = ...
	pvp_numActiveInBoundingBox2(pvp_activity, ...
				    truth_CSV_struct, ...
				    other_CSV_struct, ...
				    DCR_CSV_struct);
    CSV_struct.num_active_BB_mask = pvp_num_active_BB_mask;
    CSV_struct.num_active_BB_notmask = pvp_num_active_BB_notmask;
    CSV_struct.num_BB_mask = pvp_num_BB_mask;
    CSV_struct.num_BB_notmask = pvp_num_BB_notmask;
    CSV_struct.max_confidence = pvp_max_confidence;

    if make_bootstrap_chips_flag
      [num_target_chips, num_distractor_chips] = ...
	  pvp_bootstrapChips(frame_pathname, hit_list, miss_list, truth_CSV_struct);
    endif
  elseif make_target_mask_flag
    pvp_makeTargetMask(frame_pathname, truth_CSV_struct, DCR_CSV_struct);
  endif

  CSV_struct.hit_list = hit_list;
  CSV_struct.miss_list = miss_list;

  %%keyboard;
  global pvp_overlay_original
  pvp_overlay_original = 1;
  global pvp_draw_BB
  pvp_draw_BB = 1;
  if pvp_reconstruct_sparse
    [pvp_image] = ...
	pvp_reconstructSparse(frame_pathname, ...
			      pvp_time, ...
			      pvp_activity);

    if pvp_draw_BB
      [pvp_image] = pvp_drawBoundingBox(pvp_image, hit_list);
    endif
    
    %%CSV_struct.pvp_image = pvp_image;
    pvp_image_title = CSV_struct.frame_filename;
    if ~pvp_overlay_original 
      pvp_image_title = ["no_overlay", filesep];
    endif
    pvp_image_pathname = [ODD_subdir, pvp_image_title];
    imwrite(pvp_image, pvp_image_pathname);
  endif
  
  
endfunction %% pvp_makeCSVFileKernel



