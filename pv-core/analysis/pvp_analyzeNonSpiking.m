%%keyboard;
more off
%%
close all
clear all
expNum = 1;
				% set paths, may not be applicable to all octave installations
%%pvp_matlabPath;

plot_2AFC_flag = 1;
plot_weights_flag = 0;
noplot_flag = false; %% true; %% 

if ~noplot_flag
  try
    setenv('GNUTERM', 'x11');
  catch
    noplot_flag = true;
  end %% try
endif
				% Make the following global parameters available to all functions for convenience.
global N_image NROWS_image NCOLS_image
global N NROWS NCOLS % for the current layer
global NFEATURES  % for the current layer
global NO NK dK % for the current layer
global ROTATE_FLAG % orientation axis rotated by DTH / 2
global THETA_MAX
THETA_MAX = 1 * pi;
global COMPRESSED_FLAG
COMPRESSED_FLAG = 0;


global num_trials first_trial last_trial skip_trial
global OUTPUT_PATH SPIKE_PATH twoAFC_path activity_path

global MIN_INTENSITY
MIN_INTENSITY = 0;

global NUM2STR_FORMAT
NUM2STR_FORMAT = '%04.4i';

global FLAT_ARCH_FLAG
FLAT_ARCH_FLAG = 1;

global TOPDOWN_FLAG
TOPDOWN_FLAG = 0;

global TRAINING_FLAG
TRAINING_FLAG = -2;

global G2_FLAG G4_FLAG G6_FLAG
G2_FLAG = 1;
G4_FLAG = 0;
G6_FLAG = 0;

global DIRTY_FLAG
DIRTY_FLAG = 1;

if DIRTY_FLAG == 1
  kernel_str = 'dirty';
else
  kernel_str = 'clean';
endif

MNIST_flag = 0;
bowtie_flag = 0;
animal_flag = 0;
dogcat_flag = 1;

NFC = 4;
global FC_STR
				%FC_STR = ['_', num2str(4), 'fc'];
FC_STR = [num2str(NFC), 'fc'];

num_trials = 0; %%320; %%  %% cannot exceed ~1024 for 256x256 image because
num_single_trials = 1; %%20 + num_trials * noplot_flag;
%%octave 3.2.3 can't compute offsets greater than 32 bits
if ~TOPDOWN_FLAG
  first_trial = 1;
else
  first_trial = 2; 
endif %TOPDOWN_FLAG
last_trial = num_trials;
skip_trial = 1;
tot_trials = length( first_trial : skip_trial : num_trials );

RAW_HIST_FLAG = 1;
RECONSTRUCT_FLAG = 1;
DEBUG_FLAG = 1;

global G_STR
G_STR = '';
if ((MNIST_flag == 0) && (bowtie_flag == 0) && (animal_flag == 0) && ...
    (dogcat_flag == 0))
  if abs(TRAINING_FLAG) == 1
    G_STR = '_G1/';
  elseif abs(TRAINING_FLAG) == 2
    G_STR = '_G2/';
  elseif abs(TRAINING_FLAG) == 3
    G_STR = '_G3/';
  elseif abs(TRAINING_FLAG) == 4
    G_STR = '_G4/';
  endif
elseif MNIST_flag == 1
  G_STR = '_6/';
elseif ((bowtie_flag == 1) || (animal_flag == 1) || (dogcat_flag == 1))
  G_STR = '/';
endif
machine_path = ...
    "/nh/compneuro/Data/";

global target_path
target_path = [];
target_path = ...
    [machine_path, "ImageNet/PetaVision/CatVsNoCatDog/Test/activity/cat2/canny3way"];
%%    [machine_path, "repo/neovision-programs-petavision/Heli/Challenge/activity/Car/canny3way"];
if ~isempty(target_path)
  target_path = [target_path, G_STR];
  if ((MNIST_flag == 0) &&  (animal_flag == 0) && (dogcat_flag == 0))
    target_path = [target_path, FC_STR, '/'];
  endif
endif % ~isempty(target_path)

%%if num_trials > num_single_trials || RAW_HIST_FLAG
  distractor_path = ...
    [machine_path, "ImageNet/PetaVision/CatVsNoCatDog/Test/activity/nocatdog2/canny3way"];
%%      [];
%%else
%%  distractor_path = [];
%%endif
if ~isempty(distractor_path)
  distractor_path = [distractor_path, G_STR];
  if ((MNIST_flag == 0) &&  (animal_flag == 0) && (dogcat_flag == 0))
    distractor_path = [distractor_path, FC_STR, '/'];
  endif
endif % ~isempty(distractor_path)

twoAFC_path = target_path;
SPIKE_PATH = target_path; %[machine_path, 'kernel/input/spiking_target10K', FC_STR];
				%twoAFC_path = [twoAFC_path, G_STR, '/'];
				%spiking_path = [spiking_path, G_STR, '/'];
activity_path = {target_path; distractor_path};
OUTPUT_PATH = twoAFC_path;

min_target_flag = 2 - ~isempty(target_path);
max_target_flag = 1 + ~isempty(distractor_path);

pvp_order = 1;
ROTATE_FLAG = 1;
				% initialize to size of image (if known), these should be overwritten by each layer
NROWS_image=256;
NCOLS_image=256;
NROWS = NROWS_image;
NCOLS = NCOLS_image;
NFEATURES = 8;

NO = NFEATURES; % number of orientations
NK = 1; % number of curvatures
dK = 0; % spacing between curvatures (1/radius)

my_gray = [.666 .666 .666];
num_targets = 1;
fig_list = [];

global NUM_BIN_PARAMS
NUM_BIN_PARAMS = 20;

global NUM_WGT_PARAMS
NUM_WGT_PARAMS = 5;

global N_LAYERS
global SPIKING_FLAG
global pvp_index
SPIKING_FLAG = 0;
[layerID, layerIndex] = pvp_layerID;

read_activity = [layerIndex.retina, layerIndex.l1Pooling1X1, layerIndex.l1Clique];
%%read_activity = [layerIndex.l1Clique];
read_activity = [read_activity, layerIndex.l2Clique, layerIndex.l3Clique]; 
read_activity = [read_activity, layerIndex.l4Clique];
num_layers = N_LAYERS;

if RECONSTRUCT_FLAG
  reconstruct_activity = read_activity;
else
  reconstruct_activity = [];
endif

				%acivity_array = cell(num_layers, num_trials);
num_2AFC_tests = 1;
ave_activity = zeros(2, num_layers, num_trials);
std_activity = zeros(2, num_layers, num_trials);
max_activity = zeros(2, num_layers, num_trials);
mnz_activity = zeros(2, num_layers, num_trials);
snz_activity = zeros(2, num_layers, num_trials); % sum of positive
				% values only
global num_hist_bins
num_hist_bins = 100;
hist_activity_bins = cell(num_layers, 1);
for layer = 1 : num_layers
  hist_activity_bins{layer} = []; 
endfor
hist_activity = zeros(2, num_hist_bins, num_layers);
hist_activity_cell = cell(2, num_layers);
act_time = zeros(num_layers, num_trials);
				% 1 == ave, 2 == max, 3 ==
				% ave > 0, 4 == sum > 0
twoAFC_test_str = cell(4, 1);
twoAFC_test_str{1} = 'ave  ';
twoAFC_test_str{2} = 'sum  ';
twoAFC_test_str{3} = 'mnz';
twoAFC_test_str{4} = 'snz';

twoAFC = zeros(2, num_layers, num_trials, num_2AFC_tests);

num_rows = ones(num_layers, num_trials);
num_cols = ones(num_layers, num_trials);
num_features = ones(num_layers, num_trials);
pvp_layer_header = cell(N_LAYERS, 1);

activity = cell(2,1);

raw_hist_count = 0;
reconstruct_count = num_single_trials;

for j_trial = first_trial : skip_trial : last_trial    
  
  %% Analyze activity layer by layer
  for layer = read_activity;
    
    %% layer names, L -> retina, V1; G->lateral; T->topdown
%%    if layer <= 3
%%      layer_level = layer - 1;
%%    else
%%      layer_level = layer - 3 - ( 3 + G4_FLAG ) * ( layer > (6 + G4_FLAG) );
%%    endif % layer < 3
%%    if layer <= 3
%%      layer_label = 'L';
%%    elseif layer <= ( 6 + G4_FLAG + 2 * G6_FLAG)
%%      layer_label = 'ODD_';
%%    else
%%      layer_label = 'T';
%%    endif % layer < 3
    layer_label = layerID{ 1, layer };

    %% account for delays between layers
    if TOPDOWN_FLAG
      i_trial = j_trial + (layer - 1) * (layer <= ( 6 + G4_FLAG ) ) + ...
	  (layer - 1 - 3 - G4_FLAG + 2) * (layer > ( 6 + G4_FLAG ) );
    else
      i_trial = j_trial + (layer - 1);
    endif %TOPDOWN_FLAG
    
    for target_flag = min_target_flag : max_target_flag
      
      OUTPUT_PATH = activity_path{target_flag};
      activity{target_flag} = [];
      
      %% Read spike events
      hist_bins_tmp = ...
          hist_activity_bins{layer};
      %%keyboard;
      [act_time(layer, j_trial),...
       activity{target_flag}, ...
       hist_activity_tmp, ...
       hist_activity_bins{layer}, ...
       pvp_layer_header{layer, 1}] = ...
          pvp_readActivity(layer, i_trial, hist_bins_tmp, pvp_order);

      hist_activity(target_flag, :, layer) = ...
          hist_activity(target_flag, :, layer) + ...
          hist_activity_tmp;
      
      hist_activity_cell{target_flag, layer} = hist_activity_tmp;
      
      if isempty(activity{target_flag}) || ~any(activity{target_flag})
        continue;
      endif

      ave_activity(target_flag, layer, j_trial) = ...
	  mean( activity{target_flag}(:) );
      std_activity(target_flag, layer, j_trial) = ...
	  std( activity{target_flag}(:) );
      sum_activity(target_flag, layer, j_trial) = ...
	  sum( activity{target_flag}(:) );
      mnz_activity(target_flag, layer, j_trial) = ...
	  mean( activity{target_flag}( activity{target_flag} > 0 ) );
      snz_activity(target_flag, layer, j_trial) = ...
	  mean( activity{target_flag}( activity{target_flag} > 0.5 ) );

      subindex_str = ['(', num2str(target_flag), ',', ...
			num2str(layer), ',', ...
			num2str(j_trial), ') = '];			  
      disp([layerID{layer}, ': ', ...
	    'ave_activity', ...
	    subindex_str, ...
	    num2str(ave_activity(target_flag, layer, j_trial))]);

      if 0 %% DEBUG_FLAG
	subindex_str = ['(', num2str(target_flag), ',', ...
			  num2str(layer), ',', ...
			  num2str(j_trial), ') = '];			  
	disp([layerID{layer}, ': ', ...
	      'std_activity', ...
	      subindex_str, ...
	      num2str(std_activity(target_flag, layer, j_trial))]);
	disp([layerID{layer}, ': ', ...
	      'sum_activity', ...
	      subindex_str, ...
	      num2str(sum_activity(target_flag, layer, j_trial))]);
	disp([layerID{layer}, ': ', ...
	      'mnz_activity', ...
	      subindex_str, ...
	      num2str(mnz_activity(target_flag, layer, j_trial))]);
	disp([layerID{layer}, ': ', ...
	      'snz_activity', ...
	      subindex_str, ...
	      num2str(snz_activity(target_flag, layer, j_trial))]);
      endif

      write_activity_flag = 0;
      zip_activity_flag = 1;
      if write_activity_flag == 1
        if (zip_activity_flag == 1)
          activity_filename = ['V1_G', num2str(layer-1),'_', ...
			       num2str(j_trial, NUM2STR_FORMAT), '.mat.z']
          activity_filename = [OUTPUT_PATH, activity_filename]
          %%save("-z", "-mat", activity_filename, "activity" );
          save('-mat', activity_filename, 'activity{target_flag}' );
        else
          activity_filename = ['V1_G', num2str(layer-1), '_', ...
			       num2str(j_trial, NUM2STR_FORMAT), '.mat']
          activity_filename = [OUTPUT_PATH, activity_filename]
          save('-mat', activity_filename, 'activity{target_flag}' );
        endif
        
      endif
      
      
      num_rows(layer, j_trial) = NROWS;
      num_cols(layer, j_trial) = NCOLS;
      num_features(layer, j_trial) = NFEATURES;
      
				% plot reconstructed image
      reconstruct_activity2 = ...
	  ismember( layer, reconstruct_activity ) && ...
	  ( mod(reconstruct_count-1,num_single_trials) == 0 ); % * ...
%%	  ( reconstruct_count <= num_single_trials ); % * ...
      if reconstruct_activity2
        size_activity = ...
	    [ 1 , num_features(layer, j_trial), ...
	     num_cols(layer, j_trial), num_rows(layer, j_trial) ];
        recon_filename = ...
	    ['recon ', layer_label, num2str(layer), '_', ...
	     num2str(j_trial, NUM2STR_FORMAT), '_', ...
	     num2str(target_flag)];
	if ~noplot_flag
	  fig_tmp = figure;
	  set(fig_tmp, 'Name', recon_filename);
	else
	  fig_tmp = [];
	endif
        fig_tmp = ...
	    pvp_reconstruct(activity{target_flag}, ...
			    recon_filename, fig_tmp * ~noplot_flag, ...
			    size_activity, ...
			    ~noplot_flag);
        fig_list = [fig_list; fig_tmp];
	drawnow("expose");
	
      endif
      
      twoAFC(target_flag, layer, j_trial, 1) = ...
	  ave_activity(target_flag, layer, j_trial);
      twoAFC(target_flag, layer, j_trial, 2) = ...
	  sum_activity(target_flag, layer, j_trial);
      twoAFC(target_flag, layer, j_trial, 3) = ...
	  mnz_activity(target_flag, layer, j_trial);
      twoAFC(target_flag, layer, j_trial, 4) = ...
	  snz_activity(target_flag, layer, j_trial);

    endfor  % target_flag
    
  endfor  % layer
  
  if ~noplot_flag && RAW_HIST_FLAG && ( mod(raw_hist_count-1,num_single_trials)==0 )
    
    raw_hist_filename = ...
        ['raw hist ', ...
         num2str(j_trial, NUM2STR_FORMAT)];
    fig_tmp = figure('Name', raw_hist_filename);
    fig_list = [fig_list; fig_tmp];
    
    for layer = read_activity;
      
      for target_flag = min_target_flag : max_target_flag

	subplot_index = find(read_activity == layer);	
	subplot(length(read_activity), 1, subplot_index);
	hold on
	if target_flag == 1
	  red_hist = 1;
	  blue_hist = 0;
	  bar_width = 0.8;
	else
	  red_hist = 0;
	  blue_hist = 1;
	  bar_width = 0.6;
        endif
	if any(hist_activity_cell{target_flag,layer}(:))
	  bh = bar(hist_activity_bins{layer, 1}, ...
		   log( squeeze( hist_activity_cell{target_flag,layer}(:) ) + 1), ...
		   bar_width);
	  hold on
	  set( bh, 'EdgeColor', [red_hist 0 blue_hist] );
	  set( bh, 'FaceColor', [red_hist 0 blue_hist] );
	endif
	
      endfor  % target_flag
    endfor  % layer
  endif % raw_hist_flag
  
  reconstruct_count = reconstruct_count + 1;
  raw_hist_count = raw_hist_count + 1;
   
  %%keyboard;
  if ~noplot_flag
    if exist(target_path, "dir")
      pvp_saveFigList( fig_list(1:2:end), target_path, 'png');
    elseif exist(distractor_path, "dir")
      pvp_saveFigList( fig_list(2:2:end), distractor_path, 'png');
    endif
    if exist(distractor_path, "dir")
      pvp_saveFigList( fig_list(2:2:end), distractor_path, 'png');
    elseif exist(target_path, "dir")
      pvp_saveFigList( fig_list(1:2:end), target_path, 'png');
    endif
    close all;
    fig_list = [];
  endif

endfor % j_trial


twoAFC_filename = ...
    ['twoAFC', num2str(expNum), '.mat']
twoAFC_filename = [twoAFC_path, twoAFC_filename]
if plot_2AFC_flag == 1
  if exist("twoAFC") && ~isempty(twoAFC)
    save('-mat', twoAFC_filename, 'twoAFC', 'tot_trials', ...
	 'ave_activity', 'std_activity', 'sum_activity', 'mnz_activity', 'snz_activity');
  elseif exist(twoAFC_filename,"file")
    load(twoAFC_filename);
  else
    disp("twoAFC not found");
    plot_2AFC_flag = 0;
  endif
endif

%% 2AFC analysis

max_target_flag = size(twoAFC, 1);
min_target_flag = 1;
tot_trials = size(twoAFC, 3); %length( first_trial : skip_trial : num_trials );
plot_hist_activity_flag = 0 && plot_2AFC_flag;
%%plot_2AFC_flag = (tot_trials > num_single_trials) && plot_2AFC_flag;
if max_target_flag > min_target_flag

  if plot_hist_activity_flag
    
    subplot_index = 0;
    num_subplots = length(read_activity);
    hist_name = 'Cum Pixel Dist';
    fig_tmp = figure('Name', hist_name);
    fig_list = [fig_list; fig_tmp];
    for layer = read_activity
      subplot_index = subplot_index + 1;
      subplot(num_subplots, 1, subplot_index);
      hist_activity_tmp = ...
	  hist_activity(1, :, layer) / ...
	  sum( squeeze( hist_activity(1, :, layer) ) );
      cum_activity_target = ...
	  1 - cumsum( hist_activity_tmp );
      hist_activity_tmp = ...
	  hist_activity(2, :, layer) / ...
	  sum( squeeze( hist_activity(2, :, layer) ) );
      cum_activity_distractor = ...
	  1 - cumsum( hist_activity_tmp );
      twoAFC_correct = 0.5 + 0.5 * ...
	  ( cum_activity_target - cum_activity_distractor );
      bar( hist_activity_bins{layer}, twoAFC_correct );  
    endfor
    hist_filename = ...
	['hist_activity', '.mat']
    hist_filename = [OUTPUT_PATH, hist_filename]
    %%save("-z", "-mat", hist_filename, "hist_activity" );
    save('-mat', hist_filename, 'hist_activity');

  endif

  
  if plot_2AFC_flag

    artificial_trials = [1:75, 151:225, 301:375, 451:525];
    natural_trials = [76:150, 226:300, 376:450, 526:599];
    body_trials = [1:150];
    far_trials = [151:300];
    head_trials = [301:450];
    middle_trials = [451:599];
    all_trials =  [1:size(twoAFC,3)];
    twoAFC_trials = all_trials; %%all_trials; 
        
    mean_2AFC = squeeze( mean( twoAFC(:,:,twoAFC_trials,:), 3 ) );
    std_2AFC = squeeze( std( twoAFC(:,:,twoAFC_trials,:), 0, 3 ) );

    twoAFC_correct = zeros(num_layers, size(twoAFC,4));
    twoAFC_errorbar = zeros(num_layers, size(twoAFC,4));

    baseline_layer = 4; %% 0;
    percent_change_flag = 1; %%0;
    cum_change_flag = 1; %%0;

    twoAFC_list = [1];
    for i_2AFC_test = twoAFC_list %%1 : num_2AFC_tests
      
      [twoAFC_hist, twoAFC_bins, twoAFC_calc] = ...
	  pvp_calc2AFCHist(twoAFC(:,:,twoAFC_trials,i_2AFC_test), ...
			   read_activity, ...
			   1, ...
			   twoAFC_test_str{i_2AFC_test}, ...
			   baseline_layer, ...
			   percent_change_flag, ...
			   cum_change_flag);
      if ~noplot_flag
	[fig_list_tmp] = ...
	    pvp_plot2AFCHist(twoAFC_hist, ...
			     twoAFC_bins, ...
			     read_activity, ...
			     twoAFC_test_str{i_2AFC_test});
	fig_list = [fig_list; fig_list_tmp];
      endif
      
      [twoAFC_cumsum, twoAFC_ideal] = ...
	  pvp_calc2AFCCumsum(twoAFC_hist, ...
			     read_activity, ...
			     1, ...
			     twoAFC_test_str{i_2AFC_test});
      plot_ideal = 0;
      if plot_ideal
	[fig_list_tmp] = ...
	    pvp_plot2AFCIdeal(twoAFC_ideal, ...
			      twoAFC_bins, ...
			      read_activity, ...
			      1, ...
			      twoAFC_test_str{i_2AFC_test});
	fig_list = [fig_list; fig_list_tmp];
      endif

      
      [twoAFC_ROC, twoAFC_AUC] = ...
	  pvp_calc2AFCROC(twoAFC_cumsum, ...
			  read_activity, ...
			  1, ...
			  twoAFC_test_str{i_2AFC_test});
      if ~noplot_flag
	[fig_list_tmp] = ...
	    pvp_plot2AFCROC(twoAFC_ROC, ...
			    read_activity, ...
			    1, ...
			    twoAFC_test_str{i_2AFC_test});
	fig_list = [fig_list; fig_list_tmp];
      endif

      
      disp(twoAFC_test_str{i_2AFC_test});
      for layer = read_activity
	for target_flag = 1 : 2;
	  disp( ['mean_2AFC(', num2str(target_flag), ',', ...
			    num2str(layer), ',', num2str(i_2AFC_test), ') = ', ...
		 num2str(mean_2AFC(target_flag, layer, i_2AFC_test)), ...
		 '+/- ', 
		 num2str(std_2AFC(target_flag, layer, i_2AFC_test)), ...
		 ] );
	endfor
      endfor
      for layer = read_activity
	twoAFC_tmp = ...
	    squeeze(twoAFC_calc(:, layer, :, i_2AFC_test));
	twoAFC_correct(layer, i_2AFC_test) = ...
	    sum( squeeze(twoAFC_tmp(1, twoAFC_trials) >
			 twoAFC_tmp(2, twoAFC_trials) ) ) / ...
	    ( length(twoAFC_trials) + (length(twoAFC_trials) == 0) );
	if ( twoAFC_correct(layer, i_2AFC_test) * length(twoAFC_trials) ) ~= 0
	  twoAFC_errorbar(layer, i_2AFC_test) = ...
	      sqrt( 1 - twoAFC_correct(layer, i_2AFC_test) ) / ...
	      sqrt(twoAFC_correct(layer, i_2AFC_test) * ...
		   length(twoAFC_trials) );
	else
	  twoAFC_errorbar(layer, i_2AFC_test) = 0;
	endif
	disp( ['twoAFC_correct(', num2str(layer), ...
			       ',', num2str(i_2AFC_test), ') = ', ...
	       num2str(twoAFC_correct(layer, i_2AFC_test)), ...
	       "+/-", ...
	       num2str(twoAFC_errorbar(layer, i_2AFC_test))] );
	disp( ['twoAFC_AUC(', num2str(layer), ...
			       ',', num2str(i_2AFC_test), ') = ', ...
	       num2str(twoAFC_AUC(layer, 1))] );
      endfor %% layer
      
    endfor % i_2AFC_test
    
    save('-mat', twoAFC_filename, 'twoAFC', 'twoAFC_hist', ...
	 'twoAFC_cumsum', 'twoAFC_ideal', 'twoAFC_correct',
	 'twoAFC_errorbar', ...
	 'twoAFC_ROC', ...
	 'twoAFC_AUC', ...
	 'tot_trials', ...
	 'ave_activity', 'std_activity', 'sum_activity', 'mnz_activity', 'snz_activity');
    
  endif

  if ~noplot_flag
    pvp_saveFigList( fig_list, twoAFC_path, 'png');
    fig_list = [];
  endif
  
endif

%%keyboard;
fig_list = [];

%% plot connections
if plot_weights_flag == 1 && ~noplot_flag
  global N_CONNECTIONS
  global NXP NYP NFP
  global NUM_ARBORS
  global MAX_ARBORS
  MAX_ARBORS = 1;
  make_kernel_movie = MAX_ARBORS > 1;
  if make_kernel_movie
    target_kernel_path = [target_path, "target_kernels", filesep];
    mkdir(target_kernel_path);
    distractor_kernel_path = [distractor_path, "distractor_kernels", filesep];
    mkdir(distractor_kernel_path);
    ODD_kernel_path = [target_path, "ODD_kernels", filesep];
    mkdir(ODD_kernel_path);
  endif
  [connID, connIndex, num_arbors] = pvp_connectionID();
  %% num_arbors specifies the number of arbors to be explicitly extracted
  %% the value returned by pvp_connectionID is overwritten by the value stored in the header
  %% if num_arbors == 1, then multiple arbors are compressed into a single weight array
  %% if num_arbors > 1, then the "first" k = MAX_ARBORS arbors are output explicitly
  %% flags are used to specify how the "first" k arbors are determined, which could be either 
  %% literally the first k or else the k largest arbors, largest being say the arbors with the most 
  %% non-zero weights
  if TRAINING_FLAG > 0
    plot_weights = []; %N_CONNECTIONS;
  else
    if max_target_flag > min_target_flag
      plot_weights = ( N_CONNECTIONS - 1) : ( N_CONNECTIONS+(TRAINING_FLAG<=0) );
    else
      plot_weights = ( N_CONNECTIONS - 1 ) : ( N_CONNECTIONS+(TRAINING_FLAG<=0) );
    endif
  endif
  weights = cell(N_CONNECTIONS+(TRAINING_FLAG<=0), MAX_ARBORS);
  weight_invert = ones(N_CONNECTIONS+(TRAINING_FLAG<=0), MAX_ARBORS);
  weight_invert(6,1) = -1; %% 
  weight_invert(9,1) = -1; %% 
  weight_invert(12,1) = -1; %%-1;
  weight_invert(15,1) = -1; %%-1;
  pvp_conn_header = cell(N_CONNECTIONS+(TRAINING_FLAG<=0), 1);
  nxp = cell(N_CONNECTIONS+(TRAINING_FLAG<=0), MAX_ARBORS);
  nyp = cell(N_CONNECTIONS+(TRAINING_FLAG<=0), MAX_ARBORS);
  offset = cell(N_CONNECTIONS+(TRAINING_FLAG<=0), MAX_ARBORS);
  FLAT_ARCH_FLAG = 0;
  write_pvp_kernel_flag = 0;
  write_mat_kernel_flag = 1;
  make_weight_hist_flag = 1;
  for i_conn = plot_weights
    weight_min = 10000000.;
    weight_max = -10000000.;
    weight_ave = 0;
    if i_conn == N_CONNECTIONS - 1
      kernel_path = target_kernel_path;
    elseif i_conn == N_CONNECTIONS 
      kernel_path = distractor_kernel_path;
    elseif i_conn == N_CONNECTIONS + 1
      kernel_path = ODD_kernel_path;
    endif 
    if i_conn < N_CONNECTIONS+1
      weights_filename = ['w', num2str(i_conn-1),'_last.pvp'];
      weights_filename = [SPIKE_PATH, weights_filename];   
      if ~exist(weights_filename,'file')
	error(['~exist(weights_filename,''file'') in pvp file: ', weights_filename]);
      endif
      [pvp_conn_header{i_conn, 1}, pvp_index] = pvp_readWeightHeader(weights_filename);
      if isempty(pvp_conn_header{i_conn, 1})
	disp(['isempty(pvp_conn_header) in pvp file: ', weights_filename]);
	return;
      endif
      num_arbors(i_conn) = pvp_conn_header{i_conn,1}(pvp_index.NUM_ARBORS);
      NUM_ARBORS = num_arbors(i_conn);
      [weights_tmp, nxp_tmp, nyp_tmp, offset_tmp] ...
	  = pvp_readWeights(weights_filename, pvp_conn_header{i_conn,1});
      num_patches = pvp_conn_header{i_conn,1}(pvp_index.WGT_NUMPATCHES);
      for i_arbor = 1 : MAX_ARBORS %% min(MAX_ARBORS, NUM_ARBORS)
	weights{i_conn, i_arbor} = cell(num_patches,1);
	for i_patch = 1 : num_patches
	  weights{i_conn, i_arbor}{i_patch} = weights_tmp{i_patch, i_arbor};
	endfor
      endfor
      NXP = pvp_conn_header{i_conn,1}(pvp_index.WGT_NXP);
      NYP = pvp_conn_header{i_conn,1}(pvp_index.WGT_NYP);
      NFP = pvp_conn_header{i_conn,1}(pvp_index.WGT_NFP);
      if NXP <= 1 || NYP <= 1
	continue;
      endif
      for i_arbor = 1 : MAX_ARBORS %% min(MAX_ARBORS, NUM_ARBORS)
	for i_patch = 1:num_patches
	  weight_min = min( min(weights{i_conn,i_arbor}{i_patch}(:)), weight_min );
	  weight_max = max( max(weights{i_conn,i_arbor}{i_patch}(:)), weight_max );
	  weight_ave = weight_ave + mean(weights{i_conn, i_arbor}{i_patch}(:));
	endfor
      endfor
      weight_ave = weight_ave / num_patches;
      disp( ['weight_min = ', num2str(weight_min)] );
      disp( ['weight_max = ', num2str(weight_max)] );
      disp( ['weight_ave = ', num2str(weight_ave)] );
      if ~TRAINING_FLAG
	continue;
      endif
    elseif i_conn == N_CONNECTIONS + 1
      for i_arbor = 1 : MAX_ARBORS %% min(MAX_ARBORS, NUM_ARBORS)
	w_max_target = max(weight_invert(i_conn-2,1)*weights{i_conn-2,i_arbor}{i_patch}(:));
	w_max_distractor = max(weight_invert(i_conn-1,1)*weights{i_conn-1,i_arbor}{i_patch}(:));
	disp('calculating ODD kernels');
	pvp_conn_header{i_conn} = pvp_conn_header{i_conn-1,1};
	pvp_conn_header_tmp = pvp_conn_header{i_conn,1};
	num_patches = pvp_conn_header_tmp(pvp_index.WGT_NUMPATCHES);
	nxp{i_conn} = nxp{i_conn-1,1};
	nyp{i_conn} = nyp{i_conn-1,1};
	for i_patch = 1:num_patches
	  weights{i_conn,1}{i_patch} = ...
	      (weight_invert(i_conn-2,1)*weights{i_conn-2,i_arbor}{i_patch} - ...
	       weight_invert(i_conn-1,1)*weights{i_conn-1,i_arbor}{i_patch});
	  weight_min = min( min(weights{i_conn,i_arbor}{i_patch}(:)), weight_min );
	  weight_max = max( max(weights{i_conn,i_arbor}{i_patch}(:)), weight_max );
	  weight_ave = weight_ave + mean(weights{i_conn,i_arbor}{i_patch}(:));
	endfor
      endfor
      weight_ave = weight_ave / num_patches;
      disp( ['weight_min = ', num2str(weight_min)] );
      disp( ['weight_max = ', num2str(weight_max)] );
      disp( ['weight_ave = ', num2str(weight_ave)] );
      if write_pvp_kernel_flag && NUM_ARBORS == MAX_ARBORS
	%%keyboard;
	NCOLS = pvp_conn_header_tmp(pvp_index.NX);
	NROWS = pvp_conn_header_tmp(pvp_index.NY);
	NFEATURES = pvp_conn_header_tmp(pvp_index.NF);
	N = NROWS * NCOLS * NFEATURES;
	weights_size = [ NFP, NXP, NYP];
	pvp_writeKernel( weights(i_conn,:), weights_size, kernel_str );
      endif % write_pvp_kernel_flag
    else
      continue;
    endif  % i_conn < N_CONNECTIONS + 1
    if make_weight_hist_flag
      num_weight_hist_bins = 20;
      weight_hist_bin_size = (weight_max - weight_min) / num_weight_hist_bins; 
      weight_hist_bins = ...
	  [weight_min+(weight_hist_bin_size/2) : weight_hist_bin_size : weight_max-(weight_hist_bin_size/2)];
      weight_hist = zeros(1,num_weight_hist_bins);
    endif
    for i_arbor = MAX_ARBORS %% min(NUM_ARBORS, MAX_ARBORS)
      if write_mat_kernel_flag
	mat_weights = weights{i_conn,i_arbor};
	mat_weights_filename = ...
	    [kernel_str, num2str(expNum), '_', num2str(i_conn), '_a', num2str(i_arbor), '.mat']
	mat_weights_filename = [twoAFC_path, mat_weights_filename]
	%%save("-z", "-mat", geisler_weights_filename, "geisler_weights");
	save('-mat', mat_weights_filename, 'mat_weights');
      endif % write_mat_kernel_flag
      NK = 1;
      NO = floor( NFEATURES / NK );
      skip_patches = num_patches;
      for i_patch = 1 : skip_patches : num_patches
	NCOLS = NXP; %%nxp{i_conn, i_arbor}(i_patch);
	NROWS = NYP; %%nyp{i_conn, i_arbor}(i_patch);
	N = NROWS * NCOLS * NFEATURES;
	patch_size = [1 NFEATURES  NCOLS NROWS];
	NO = NFP;
	plot_name = ...
	    [connID{i_conn}, '_', ...
			       int2str(i_conn), '_', ...
			       int2str(i_arbor), '_', ...
			       int2str(i_patch) ];
	pixels_per_cell = 5;
	[fig_tmp, recon_colormap, recon_image] = ...
	    pvp_reconstruct(weights{i_conn,i_arbor}{i_patch}*weight_invert(i_conn,1), ...
			    plot_name, ...
			    [], patch_size, ~noplot_flag, ...
			    pixels_per_cell);
	fig_list = [fig_list; fig_tmp];
	if make_kernel_movie
	  kernel_pathname = [kernel_path, plot_name, ".png"];
	  imwrite(recon_image, kernel_pathname);
	endif
	plot_recon_subsection = 0;
	plot_recon_subsection
	if plot_recon_subsection
	  weights_sub = ...
	      weights{i_conn,i_arbor}{i_patch}*weight_invert(i_conn,i_arbor);
	  weights_sub = ...
	      reshape(weights_sub, patch_size);
	  sub_size = floor( NROWS / 8 );
	  row_start = floor((NROWS/2) - (sub_size/2));
	  row_end = ceil(row_start + sub_size - 1);
	  col_start = floor((NCOLS/2) - (sub_size/2));
	  col_end = col_start + sub_size - 1;
	  weights_sub = ...
	      weights_sub(1,:, col_start:col_end, row_start:row_end);
	  patch_size_sub = [1 NFEATURES  sub_size sub_size];
	  plot_name_sub = ...
	      [connID{i_conn}, '(', ...
				 int2str(i_conn), ',', ...
				 int2str(i_arbor), ',', ...
				 int2str(i_patch), ')', ...
	       " insert"];
	  pixels_per_cell_sub = 5*sub_size;
	  [fig_sub, recon_colormap] = ...
	      pvp_reconstruct(weights_sub(:), ...
			      plot_name_sub, ...
			      [], patch_size_sub, ~noplot_flag, ...
			      pixels_per_cell_sub);
	  fig_list = [fig_list; fig_sub];      
	endif
      endfor %% i_patch
      if make_weight_hist_flag
	weight_hist_tmp = ...
	    hist(weights{i_conn,i_arbor}{i_patch}, ...
		  weight_hist_bins);
	weight_hist = weight_hist + weight_hist_tmp;
      endif
    endfor %% i_arbor
    disp(["weight_hist = ", mat2str(weight_hist)]);
    if make_weight_hist_flag && ~noplot_flag
      fig_tmp = figure;
      plot_name = ...
	  [connID{i_conn}, '(', ...
			     int2str(i_conn), ')' ];
      bar(weight_hist_bins, weight_hist);
      fig_list = [fig_list; fig_tmp];
    endif
  endfor %% i_conn
  FLAT_ARCHITECTURE = 0;
  if ~noplot_flag
    pvp_saveFigList( fig_list, OUTPUT_PATH, 'jpg');
  endif
  %%close all;
  %%fig_list = [];
endif