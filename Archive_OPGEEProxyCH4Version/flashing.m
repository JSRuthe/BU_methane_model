function [EF_FF] = flashing(Emissions, Activity, j, frac_control)
% The approach here to estimating tank flashing emissions is based on
% Zavala Araiza et al (2017). Flash emissions are categorized as either
% continuous or intermittent based on the maximum rate of dumping from
% separators (140 bbl/sep/day from Zavala Araiza is converted to a well basis 
% using 1.64, the average number of wells per site according to Enverus
% data). 

IsFlash = rand;

% Vector of flash emissions has 999 elements
RandomIndex = floor((rand*999)+1);

% If a tank is controlled, then the flash emission factor is zero.
if IsFlash < frac_control
    EF_FF = 0;
else
    % If throughput from the well to the separator is less than the dump
    % threshold, then the dumping is itermittent.
    if (Activity.prod_bbl(j)/Activity.wells(j)) < (140/1.64)
        % Intermittent
        IsIntDump = rand;
        
        % Dumping occurs more frequently the closer the well productivity
        % is to the dump threshold
        if IsIntDump < ((Activity.prod_bbl(j)/Activity.wells(j)) / (140/1.64))
            
            % kg CH4/well/day
            EF_FF = Emissions.HARC(RandomIndex)*(140/1.64);
        else
            EF_FF = 0;
        end
    else
        % Continuous
        
        % kg CH4/well/day
        EF_FF = Emissions.HARC(RandomIndex)*(Activity.prod_bbl(j)/Activity.wells(j));
    end
end
end
