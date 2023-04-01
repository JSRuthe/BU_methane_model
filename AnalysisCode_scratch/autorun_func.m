function [] = autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPGEE fugitives component-level model
%
% This script estimates methane emissions for production sites only
%
% Equipment and process coverage includes:
%   (i)   Wellpad equipment leaks (wellheads, separators, dehydrators, 
%         meters, heaters, headers, chemical injection pumps, pneumatic 
%         controllers)
%   (ii)  Wellpad equipment vents (tanks)
%   (iii) Completions and workovers
%   (iv)  Liquids unloadings
%   (v)   Tank flashing
%   (vi)  Methane due to incomplete combustion and unlit flares
% 
%
% Inputs:
%	n_trial:        number of Monte Carlo iterations for autorun
%	Basin_Select:   Main iterative index (i) from "main" function
%	Basin_Index:    Cell array of basin names
%   Equipment-level distributions contained in the
%                   "distributionsfolder"
%                   - This model uses the same equipment-level emission factor 
%                   distributions generated for Rutherford et al. (2021). 100
%                   realizations of the equipment-level emission factor distributions 
%                   are contained in the "EquipmentDistributions" folder.
%	Activity_tranches
%               Col 1 = Tranche #
%               Col 2 = Well-level oil production [bbl/well/day]
%               Col 3 = Well count (1 based on recent edit)
%               Col 4 = C1 [molar fraction * 100]
%               Col 5 = well-level GOR [scf/bbl]
%               Col 6 = LU type [integer from 0-2]
%               Col 7 = fraction of wells flaring
%               Col 8 =  Headers per well
%               Col 9 = Heaters per well
%               Col 10 = Separators per well
%               Col 11 = Meters per well
%               Col 12 = Tanks per well
%               Col 13 = Tanks per well
%               Col 14 = Reciprocating compressors per well
%               Col 15 = Dehydrators per well
%               Col 16 = CIPs per well
%               Col 17 = PCs per well
%               Col 18 = Oil throughput controlled [fraction]
%
%	Outputs:
%       Data_Out:
%           col 1 = tranche iteration (1-74)
%           col 2 = well productivity (bbl/day]
%           col 3 = sample (wells/sample size)
%           col 4 = well productivity [kg/well/d]
%           col 5 = well productivity [scf/well/d]
%           col 6 = Wells
%           col 7 = Header
%           col 8 = Heater
%           col 9 = separators
%           col 10 = Meter
%           col 11 = Tanks - leaks
%           col 12 = Tanks - vents
%           col 13 = Recip Compressor
%           col 14 = Dehydrators
%           col 15 = CIP
%           col 16 = PC
%           col 17 = LU
%           col 18 = completions
%           col 19 = workovers
%           col 20 = Tank Venting
%           col 21 = Flare methane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Paramerize models

% Input parameters

% n.fields = number of fields to process in the "Activity" input file
n.fields = size(Activity_tranches,2);
% n.sample: Upper limit on the number of wells that the code will process 
% (if the total number of wells is greater than the sample size, an 
% extrapolation is performed in the emissions processing script
% 
% Edit 22.11.25 - We are not binning tranches, so by setting n.sample = to
% a high number we are effectively disabling the sampling algorithm
n.sample = 1000000; 
% The maximum number of iterations that are to proceed if mass balance is
% not achieved
maxit = 50;

% Equipment parameters
n.rows = 20;
n.wellpad = 16;
n.offsite = 4;

% Import input datasets
filepath = fullfile(pwd, activityfolder,'LiquidsUnloadings.csv');
Emissions.LU = importdata(filepath);
filepath = fullfile(pwd, activityfolder,'HARC.csv');
Emissions.HARC = importdata(filepath);
filepath = fullfile(pwd, activityfolder,'gvakharia.csv');
Emissions.gvakharia = importdata(filepath);

Activity.tranche = Activity_tranches(1,:)';
Activity.prod_bbl = Activity_tranches(2,:)'; %bbl/day
Activity.wells = Activity_tranches(3,:)'; %number of wells
Activity.frac_C1 = Activity_tranches(4,:)'; % molar percent (0 - 100)
Activity.GOR = Activity_tranches(5,:)'; % scf/bbl
Activity.LU = Activity_tranches(6,:)'; % integer from 0-2
Activity.frac_wells_flaring = Activity_tranches(7,:); % fraction

Activity.prod_scf = Activity.prod_bbl .* Activity.GOR; % scf/day
Activity.prod_kg = Activity.prod_scf .* ((16.041 * 1.20233 .* (Activity.frac_C1 / 100)) / 1000); % kg CH4/day

Activity.AF = Activity_tranches(8:18,:);

%% Calculations

for i = 1:n_trial
  
    % Read input data files
    
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Set21_Inputs'
    
    csvFileName = ['EquipGas' num2str(i) '.csv'];
    filepath = fullfile(pwd, distributionsfolder,csvFileName);
    dataraw = importdata(filepath);
    EquipGas = dataraw;
    
    csvFileName = ['EquipOil' num2str(i) '.csv'];
    filepath = fullfile(pwd, distributionsfolder,csvFileName);
    dataraw = importdata(filepath);
    EquipOil = dataraw;  
    
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    
    % Calculations are performed within fugitives macro
    
    for j = 1:n.fields
    	if  j == 1
                Data_Out = zeros(1,1);
        end
        [Data_Out] = fugitives_sub(n, j, maxit, Activity, Emissions, EquipGas, EquipOil, Data_Out, Basin_Select, AF_overwrite, AF);

    end
    
    % Save output
    if Basin_Select == 0
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
        FileName = ['Equip' num2str(i)  'out.csv']; 
        filepath = fullfile(pwd, 'Outputs/',FileName);
       csvwrite(filepath,Data_Out);
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    else
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'

        FileName = ['Equip' num2str(i) Basin_Index{Basin_Select} 'out.csv']; 
        filepath = fullfile(pwd, 'Outputs/',FileName);
       csvwrite(filepath,Data_Out);

        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    end

end

end






