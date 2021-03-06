function fig_list = ...
      pvp_plotRaster(layer, ...
		     epoch_struct, ...
		     layer_struct, ...
		     target_struct, ...
		     raster_epoch, ...
		     fig_list)

  global BIN_STEP_SIZE DELTA_T
  global pvp_order
  global my_gray

  %% start loop over epochs
  for i_epoch = 1 : epoch_struct.num_epochs
    disp(['i_epoch = ', num2str(i_epoch)]);
    
    %% raster plot
    if  ~ismember( i_epoch, raster_epoch )
      continue;
    endif %%

    %% read spike train for this epoch
    [spike_array] = ...
        pvp_readSparseSpikes(layer, ...
			     i_epoch, ...
			     epoch_struct, ...
			     layer_struct, ...
			     pvp_order);
    if isempty(spike_array)
      continue;
    endif %%
    
    plot_title = ...
        [layer_struct.layerID{layer}, ...
         ' Raster',...
         '(', ...
           int2str(layer)', ...
           ',', ...
           int2str(i_epoch), ...
           ')'];
    fig_tmp = figure('Name',plot_title);
    fig_list = [fig_list; fig_tmp];
    axis([epoch_struct.begin_time(i_epoch,layer) ...
	  epoch_struct.end_time(i_epoch,layer) ...
	  0 layer_struct.num_neurons(layer)])
    axis normal
    hold on
    [spike_time, spike_id] = ...
        find(spike_array);
    spike_time = spike_time*DELTA_T + epoch_struct.begin_time(i_epoch,layer);
    lh = plot(spike_time, spike_id, '.k');
    axis normal
    set(lh,'Color', my_gray);
    
    for i_target=1:target_struct.num_targets
      [spike_time, spike_id] = ...
          find(spike_array(:, ...
			   target_struct.target_ndx_all{layer, i_target}));
      spike_time = spike_time*DELTA_T + epoch_struct.begin_time(i_epoch,layer);
      plot(spike_time, ...
	   target_struct.target_ndx_all{layer, i_target}(spike_id), '.r');
      axis normal
    endfor %% i_target
    
    [spike_time, spike_id] = ...
        find(spike_array(:, ...
			 target_struct.clutter_ndx_all{layer}));
    spike_time = spike_time*DELTA_T + epoch_struct.begin_time(i_epoch,layer);
    plot(spike_time*DELTA_T, ...
	 target_struct.clutter_ndx_all{layer}(spike_id), '.b');
    axis normal
  endfor %% i_epoch
