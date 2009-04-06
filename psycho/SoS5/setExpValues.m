function exp = setExpValues(fd, nl)
    
    global manual_timing
    
    num_trials = 20;
    num_duration_vals = 3;
    tot_combinations = 2 * num_duration_vals * nl;
    tot_trials = num_trials * tot_combinations;
    
    if manual_timing
        exp = struct( ...
            'num_trials', num_trials, ...
            'skip_flag',  10, ...
            'num_duration_vals', num_duration_vals, ...
            'tot_combinations', tot_combinations, ...
            'tot_trials', tot_trials, ...
            'duration_min', .5 * fd, ...
            'duration_max', 2.5 * fd, ...
            'duration', zeros(tot_trials,1), ...
            'response_time', zeros(tot_trials, 2), ...
            'choice', repmat( 10 , tot_trials, 1 ));

    else
        exp = struct( ...
            'num_trials', num_trials, ...
            'skip_flag',  10, ...
            'num_duration_vals', num_duration_vals, ...
            'tot_combinations', tot_combinations, ...
            'tot_trials', tot_trials, ...
            'duration_min', .5 * fd, ...
            'duration_max', 2.5 * fd, ...
            'duration', zeros(tot_trials,1), ...
            'response_time', zeros(tot_trials, 2), ...
            'choice', repmat( 10 , tot_trials, 1 ), ...
            'VBLTimestamp', zeros(tot_trials,2), ...     
            'StimulusOnsetTime', zeros(tot_trials,2), ...    
            'FlipTimestamp', zeros(tot_trials,2), ...    
            'Missed', zeros(tot_trials,2), ...   
            'Beampos', zeros(tot_trials,2));  
    end
end