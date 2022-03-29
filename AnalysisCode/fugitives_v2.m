function [Data_Out] = fugitives_v2(n, j, maxit, Activity, Emissions, EquipGas, EquipOil, Data_Out, Basin_Select)

%  Equipment-level outputs are as follows:
%       row 1  - Wells
%       row 2  - Header
%       row 3  - Heater
%       row 4  - separators
%       row 5  - Meter
%       row 6  - Tanks - leaks
%       row 7  - Tanks - vents
%       row 8  - Recip Compressor
%       row 9  - Dehydrators
%       row 10 - CIP
%       row 11 - PC
%       row 12 - LU
%       row 13 - completions
%       row 14 - workovers
%       row 15 - Tank Venting
%       row 16 - Flare methane

if Basin_Select == 0
    % Activity factors for rows 1-11 are based on GHGRP data for reporting year
    % 2015. See GHGRP_Master Excel file. [Double checked 21.6.29)
    
    %WL    HD          HE      SE      ME          TAL         TAV
    AF.Gas = [1;    0;          0.1321; 0.7102; 0.8399;     0.40570;    0.40570;...
        
    %  CR      DE          CIP         PC
    0.0814; 0.02987;    0.2023;     1.8743];

    AF.Oil = [1;    0.2234;     0.1859; 0.3689; 0;          0.815404;   0.815404;...

    0;      0;          0.08612;    1.1051];

    % According to GHGRP Data, 49% of storage tanks are controlled. 
     %frac_control = 0.489;    
     frac_control = 0.765; 
else
    % Import equipment leakage activity matrices
    raw_data = importdata('AF_equip_leaks.csv');
    AF_leaks = raw_data(Basin_Select,:);
    % Need two columns for tanks
    AF_leaks = [AF_leaks(1:6) AF_leaks(6:10)];
    AF.Gas = AF_leaks;
    AF.Oil = AF_leaks;

    % Import flash frac vector and select based on chosen Basin ID
    %raw_data = importdata('flash_frac.csv');
    raw_data = importdata('flash_frac_thru.csv');
    frac_control = raw_data(Basin_Select); 
end

% Loss rates (fraction 0-1) for gathering, processing, transmission, distribution, respectively
% (based on Mitchell et al. 2015, Zimmerle et al. 2015, Alvarez et al.
% 2018)
EF_offsite = [0.00243; 0.0008; 0.0026; 0.0016]; % Loss rates

% To reduce computation time if many Monte Carlo realizations are performed
%, total wells processed can be reduced. If n.sample is the maximum number
%of wells to be processed in a single tranche, then the code will first
%check if the actual number of wells in the tranche exceeds n.sample. If
%so, then each parameter is reduced proportional to actual wells / n.sample
if Activity.wells(j) > n.sample
    sample = Activity.wells(j) / n.sample;
    Activity.prod_bbl(j) = Activity.prod_bbl(j) / sample;
    Activity.prod_kg(j) = Activity.prod_kg(j) / sample;
    Activity.prod_scf(j) = Activity.prod_scf(j) / sample;
    Activity.wells(j) = n.sample;
else
    sample = 1;
end

% Pre-assign arrays
equip_array = zeros(20, Activity.wells(j));
equip_sum = zeros(1, Activity.wells(j));
equip_count = zeros(1, Activity.wells(j));

%% Emissions calculations
      
            % - - - - - - - WELL LOOP - - - - - - - - - - - - - - - - - -
            
            jj = 1;
            Counter2 = 1;

           % Well productivity calculation - Calculate sample set production divided by sample set wellcount
           WellProd = (Activity.prod_kg(j)/Activity.wells(j));
            
            while jj <= Activity.wells(j)
                
            % - - - - - - - EQUIPMENT LOOP - - - - - - - - - - - - - - - -
                
                % Wellheads to pneumatic controllers
                for k = 1:11
                    % Draw random numbers
                    RandomIndex = ceil(rand*1000);
                    RandomActivity = rand;
                    
                    % The GOR cutoff is set to 100,000 consistent with the
                    % EPA. 
                    
                    % Gas wells
                    if Activity.GOR(j) > 100000
                        
                        % For equipment that have a ratio greater than or
                        % equal to 1 per wellhead, these will always exist
                        % on the wellpad
                        if AF.Gas(k) >= 1
                            AF.Draw = AF.Gas(k);
                            
                        % For all other equipment take a random draw to
                        % determine whether or not the equipment exists on
                        % the wellpad.
                        elseif k == 1 || RandomActivity < AF.Gas(k)
                            AF.Draw = 1;
                        else
                            AF.Draw = 0;
                        end
                        
                        % Calculate equipment-level emissions for a single
                        % wellpad by multiplying the emission factor by the
                        % activity factor
                        
                        % kg CH4/well/day
                        equip_array(k, jj) = AF.Draw * EquipGas(k, RandomIndex); % kg CH4/day
                        
                    % Oil wells
                    else
                        
                        % Activity factor for pneumatics
                        if AF.Oil(k) >= 1
                            AF.Draw = AF.Oil(k);
                            
                        % For all other equipment take a random draw to
                        % determine whether or not the equipment exists on
                        % the wellpad.
                        elseif k == 1 || RandomActivity < AF.Oil(k)
                            AF.Draw = 1;
                        else
                            AF.Draw = 0;
                        end
                        
                        % Calculate equipment-level emissions for a single
                        % wellpad by multiplying the emission factor by the
                        % activity factor
                        
                        % kg CH4/well/day
                        equip_array(k, jj) = AF.Draw * EquipOil(k, RandomIndex);
                    end
                end
        
                % Liquids unloadings
                if Activity.GOR(j) > 100000
                    EF_LU = liquidsunloadings(Emissions, Activity, j);
                    equip_array(12,jj) = EF_LU;
                else
                    equip_array(12,jj) = 0;
                end
                
                % Completions and workovers are calculated in the emissions
                % processing script
                equip_array(13,jj) = 0;
                equip_array(14,jj) = 0;
                
                % Tank flashing
                EF_FF = flashing(Emissions, Activity, j, frac_control);
                equip_array(15,jj) = EF_FF;
                
                % Associated gas flaring
                EF_flare = flaring(Emissions, Activity, j);    
                RandomActivity = rand;
                
                if RandomActivity < Activity.frac_wells_flaring(j)
                     AF.Draw = 1;
                else
                     AF.Draw = 0;
                end
                
                equip_array(16,jj) = AF.Draw * EF_flare;
                
                % Production normalized values for offsite emissions
                for k = 1 : 4
                    equip_array(k + 16, jj) = EF_offsite(k)*(Activity.prod_kg(j)/Activity.wells(j));
                end
                             
                % Sum across equipment for this well
                equip_sum(jj) = sum(equip_array(:,jj));

                
                % Only advance to the next well if the emissions are less than the well productivity
                if equip_sum(jj) < WellProd
                    equip_count(jj) = Counter2;
                    jj = jj + 1;
                    Counter2 = 1;
                else
                    Counter2 = Counter2 + 1;
                    if Counter2 == maxit
                        equip_count(jj) = maxit;
                        fprintf('max iteration reached\n')
                        [val,idx] = max(equip_array(1:16,jj),[],1);
                        equip_array(idx,jj) = 0;
                        equip_array(idx,jj) = WellProd - sum(equip_array(idx,jj));
                        jj = jj + 1;
                        Counter2 = 1;
                    end
                end

            end


            
% OUTPUT RESULTS
    MatAdd = zeros(Activity.wells(j),21);
    MatAdd(:, 1) = j;
    MatAdd(:, 2) = 199 + j;
    MatAdd(:, 3) = sample;
    MatAdd(:, 4) = WellProd;
    MatAdd(:, 5) = (Activity.prod_scf(j)/Activity.wells(j));
    MatAdd(:, 6:21) = equip_array(1:16,:)';

    if j == 1
        Data_Out = MatAdd;
    else
        Data_Out = [Data_Out; MatAdd];
    end
end