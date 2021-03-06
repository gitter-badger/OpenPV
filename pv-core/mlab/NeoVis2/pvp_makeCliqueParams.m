function [pvp_params_file] = ...
      pvp_makeCliqueParams(...
			   pvp_target_id, ...
			   pvp_target_flag, ...
			   pvp_num_ODD_kernels, ...
			   pvp_bootstrap_str, ...
			   pvp_edge_type, ...
			   pvp_clique_id, ...
			   pvp_version_str, ...
			   pvp_num_versions, ...
			   pvp_input_path, ...
			   pvp_num_weight_files, ...
			   pvp_file_of_weights_file, ...
			   pvp_params_template, ...
			   pvp_frame_size, ...
			   pvp_num_frames, ...
			   pvp_fileOfFrames, ...
			   pvp_fileOfMasks, ...
			   pvp_output_path, ...
			   pvp_checkpoint_read_path, ...
			   pvp_checkpoint_write_path, ...
			   pvp_params_filename)
  
  %%keyboard;
  global PVP_VERBOSE_FLAG
  if ~exist("PVP_VERBOSE_FLAG") || isempty(PVP_VERBOSE_FLAG)
    PVP_VERBOSE_FLAG = 0;
  endif
  global pvp_home_path
  global pvp_workspace_path
  global pvp_mlab_path
  global pvp_clique_path
  if isempty(pvp_home_path)
    pvp_home_path = ...
	[filesep, "home", filesep, "gkenyon", filesep];
    %%[filesep, "Users", filesep, "gkenyon", filesep];
  endif
  if isempty(pvp_workspace_path)
    pvp_workspace_path = ...
	[pvp_home_path, "workspace", filesep];
  endif
  if isempty(pvp_mlab_path)
    pvp_mlab_path = ...
	[pvp_workspace_path, "PetaVision", filesep, "mlab", filesep];
  endif
  if isempty(pvp_clique_path)
    pvp_clique_path = ...
	[pvp_workspace_path, "SynthCog3", filesep];
  endif

  more off;
  begin_time = time();

  num_argin = 0;
  dataset_id = tolower(DATASET_ID); %% 
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_target_id") || isempty(pvp_target_id)
    pvp_target_id =  input("pvp_target_id ({""cat""", """nocatdog""}, {""Car""", """NotCar""}, {""amoeba""", """noamoeba""}): ");%% 
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_target_flag") || isempty(pvp_target_flag)
    pvp_target_flag =  input("pvp_target_flag (1,2): ");%% 
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_num_ODD_kernels") || isempty(pvp_num_ODD_kernels)
    pvp_num_ODD_kernels =  input("pvp_num_ODD_kernels (1,2,3): "); %%
  endif
  pvp_num_ODD_kernels_str = "";
  if pvp_num_ODD_kernels > 1
    pvp_num_ODD_kernels_str = num2str(pvp_num_ODD_kernels);
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_bootstrap_str") %% string can be empty
    pvp_bootstrap_str =  input("pvp_bootstrap_str (""""): ");%%
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_edge_type") || isempty(pvp_edge_type)
    pvp_edge_type =  input("pvp_edge_type (""canny"", ""DoG""): ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_clique_id") || isempty(pvp_clique_id)
    pvp_clique_id =  input("pvp_clique_id ("""",""3way""): ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_version_str") %% string can be empty
    pvp_version_str =  input("pvp_version_str ("""", ""001""): ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_num_versions") || isempty(pvp_num_versions)
    pvp_num_versions = input("pvp_num_versions (1,2, ...): ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_input_path") || isempty(pvp_input_path)
    pvp_input_path = input("pvp_input_path: ");
  else
    disp(["pvp_input_path = ", pvp_input_path]);
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_num_weight_files") || isempty(pvp_num_weight_files)
    pvp_num_weight_files = input("pvp_num_weight_files ([0,0]): "); 
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_file_of_weights_file") 
    pvp_file_of_weights_file = cell(1,2);
    for target_flag = 1:2
      pvp_file_of_weights_file{1, target_flag} = input(["pvp_file_of_weights_file{",num2str(target_flag),"}: "]);
    endfor
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_params_template") || isempty(pvp_params_template)
    pvp_params_template = input("pvp_params_template: ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_frame_size") || isempty(pvp_frame_size)
    pvp_frame_size =  input("pvp_frame_size: ");
  else
    disp(["frame_size = ", num2str(pvp_frame_size)]);
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_num_frames") %% || isempty(pvp_num_frames)
    pvp_num_frames = input("pvp_num_frames: ");
  else
    disp(["pvp_num_frames = ", num2str(pvp_num_frames)]);
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_fileOfFrames") || isempty(pvp_fileOfFrames)
    pvp_fileOfFrames = input("pvp_fileOfFrames: ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_fileOfMasks") %% || isempty(pvp_fileOfMasks)
    pvp_fileOfMasks =  input("pvp_fileOfMasks: ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_output_path") || isempty(pvp_output_path)
    pvp_output_path = input("pvp_output_path: ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_checkpoint_read_path") || isempty(pvp_checkpoint_read_path)
    pvp_checkpoint_read_path = input("pvp_checkpoint_read_path (""""): ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_checkpoint_write_path") || isempty(pvp_checkpoint_write_path)
    pvp_checkpoint_write_path = input("pvp_checkpoint_write_path: ");
  endif
  num_argin = num_argin + 1;
  if nargin < num_argin || ~exist("pvp_params_filename") || isempty(pvp_params_filename)
    pvp_params_filename = input("pvp_params_filename: ");
  endif
  
  pvp_version_id = str2num(pvp_version_str);
  disp(["pvp_version_id = ", num2str(pvp_version_id)]);



  pvp_params_file = [pvp_input_path, pvp_params_filename];
  pvp_params_fid = ...
      fopen(pvp_params_file, "w");
  if pvp_params_fid < 0
    disp(["fopen failed: ", pvp_params_file]);
    return;
  endif
  
  pvp_template_fid = ...
      fopen(pvp_params_template, "r");
  if pvp_template_fid < 0
    disp(["fopen failed: ", pvp_params_template]);
    return;
  endif

  start_frame_index = pvp_version_id;
  skip_frame_index_str = num2str(pvp_num_versions);
  disp(["pvp_checkpoint_read_path = ", pvp_checkpoint_read_path]);
  pvp_checkpoint_read_flag = "false";
  checkpoint_ndx = 0;
  pvp_checkpoint_read_parent = "";
  if ~isempty(pvp_checkpoint_read_path)
    pvp_checkpoint_read_flag = "true";
    checkpoint_folder = strFolderFromPath(pvp_checkpoint_read_path);
    checkpoint_ndx = str2num(checkpoint_folder(11:end-1));
    pvp_checkpoint_read_parent = strExtractPath(pvp_checkpoint_read_path);
    start_frame_index = start_frame_index + (checkpoint_ndx+0) * pvp_num_versions;
  endif
  start_frame_index_str = num2str(start_frame_index);
  disp(["start_frame_index_str = ", start_frame_index_str]);

  %%keyboard;
  %% note, the syntax ["""", ..., """"] is to specify double quotes in a string, the second double quote escapse the third double quote, the first and last indicate a string
  pvp_params_token_left = "$$$_";
  pvp_params_token_right = "_$$$";
  pvp_params_hash = ...
      {"numSteps", "numSteps", num2str(pvp_num_frames + 2*pvp_num_ODD_kernels + 4); ...
       "outputPath", "outputPath", ["""", pvp_output_path, """"]; ...
       "checkpointRead", "checkpointRead", ...
       pvp_checkpoint_read_flag; ...
       "checkpointReadDir", "checkpointReadDir", ...
       ["""", pvp_checkpoint_read_parent, """"]; ...
       "checkpointReadDirIndex", "checkpointReadDirIndex", ...
       num2str(checkpoint_ndx); ...
       "checkpointWriteDir", "checkpointWriteDir", ...
       ["""", pvp_checkpoint_write_path, """"]; ...
       "printParamsFilename", "printParamsFilename", ...
       ["""", pvp_output_path, pvp_params_filename, """"]; ...
       "imageListPath", "imageListPath", ["""", pvp_fileOfFrames, """"]; ...
       "image_start_frame_index", "start_frame_index", start_frame_index_str; ...
       "image_skip_frame_index", "skip_frame_index", skip_frame_index_str; ...
       "maskListPath", "imageListPath", ["""", pvp_fileOfMasks, """"]; ...
       "mask_start_frame_index", "start_frame_index", start_frame_index_str; ...
       "mask_skip_frame_index", "skip_frame_index", skip_frame_index_str; ...
       "endStim", "endStim", num2str(pvp_num_frames); ...
       "VgainL1Clique", "Vgain", num2str(0.25, "%5.3f"); ...
       "VgainL2Clique", "Vgain", num2str(0.25, "%5.3f"); ...
       "VgainL3Clique", "Vgain", num2str(0.25, "%5.3f"); ...
       "VgainL4Clique", "Vgain", num2str(0.25, "%5.3f"); ...
       "numWeightFilesTarget", "numWeightFiles", num2str(pvp_num_weight_files(1)); ...
       "initWeightsFileL1Pool1X1toL1CliqueTarget", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{1}, """"]; ...  
       "initWeightsFileL1Pool1X1toL1PostTarget", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{1}, """"]; ...  
       "numWeightFilesDistractor", "numWeightFiles", num2str(pvp_num_weight_files(2)); ...
       "initWeightsFileL1Pool1X1toL1CliqueDistractor", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{2}, """"]; ...
       "initWeightsFileL1Pool1X1toL1Pool1X1Distractor", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{2}, """"]; ...
       "initWeightsFileL2Pool2X2toL2CliqueTarget", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{1}, """"]; ...  
       "initWeightsFileL2Pool2X2toL2PostTarget", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{1}, """"]; ...  
       "numWeightFilesDistractor", "numWeightFiles", num2str(pvp_num_weight_files(2)); ...
       "initWeightsFileL2Pool2X2toL2CliqueDistractor", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{2}, """"]; ...
       "initWeightsFileL2Pool2X2toL2Pool2X2Distractor", "initWeightsFile", ...
       ["""", pvp_file_of_weights_file{2}, """"] ...
       };

  %%       "VgainL1Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       "VgainL2Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       "VgainL3Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       "VgainL4Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       "VgainL5Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       "VgainL6Clique", "Vgain", num2str(0.25, "%5.3f"); ...
  %%       };
  pvp_num_params = size(pvp_params_hash, 1);
  
  %%keyboard;
  while(~feof(pvp_template_fid))
    pvp_template_str = fgets(pvp_template_fid);
    pvp_params_str = pvp_template_str;
    for pvp_params_ndx = 1 : pvp_num_params
      pvp_str_ndx = ...
	  strfind(pvp_template_str, ...
		  [pvp_params_token_left, ...
		   pvp_params_hash{pvp_params_ndx, 1}, ...
		   pvp_params_token_right]);
      if ~isempty(pvp_str_ndx)
	pvp_hash_len = ...
	    length(pvp_params_hash{pvp_params_ndx, 1}) + ...
	    length(pvp_params_token_left) + ...
	    length(pvp_params_token_right);
	pvp_template_len = ...
	    length(pvp_template_str);
	pvp_prefix = pvp_template_str(1:pvp_str_ndx-1);
	pvp_suffix = pvp_template_str(pvp_str_ndx+pvp_hash_len:pvp_template_len-1);
	pvp_params_str = ...
	    [pvp_prefix, ...
	     pvp_params_hash{pvp_params_ndx, 2}, ...
	     " = ", ...
	     num2str(pvp_params_hash{pvp_params_ndx, 3}), ...
	     pvp_suffix, ";", "\n"];
	break;
      endif
    endfor  %% pvp_params_ndx
    fputs(pvp_params_fid, pvp_params_str);
    %%keyboard;
  endwhile
  fclose(pvp_params_fid);
  fclose(pvp_template_fid);

endfunction %% pvp_makeParams
