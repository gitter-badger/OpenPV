function [v_array] = pv_readV(fname, neuron_ndx)

global output_path N n_time_steps begin_step

%read membrane potentials
filename = fname;
filename = [output_path, filename];
if begin_step > n_time_steps
    begin_step = 1;
end
v_array = zeros( n_time_steps - begin_step + 1, numel(neuron_ndx) );
if exist(filename, 'file')
    fid = fopen(filename, 'r', 'native');
    fread(fid, N * ( begin_step - 1 ), 'float');
    for i_step = begin_step : n_time_steps
        [v_step, Ntmp] = fread(fid, N, 'float');
        v_array(i_step - begin_step + 1,:) = ...
            v_step( neuron_ndx );
    end
    fclose(fid);
    %disp(['ave_rate = ', num2str(ave_rate)]);
else
    disp(['Skipping, could not open ', filename]);
end


