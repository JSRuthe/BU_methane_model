function [] = autorun_func(n_trial, root_path, Activity_tranches, AF, Basin_Select, Basin_Index);


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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Paramerize models

% Input parameters

% n.fields = number of fields to
% process in the "Activity" input file
n.fields = size(Activity_tranches,2);
% n.sample: Upper limit on the number of wells that the code will process 
% (if the total number of wells is greater than the sample size, an 
% extrapolation is performed in the emissions processing script
n.sample = 500; 
% The maximum number of iterations that are to proceed if mass balance is
% not achieved
maxit = 500;

% Equipment parameters
n.rows = 20;
n.wellpad = 16;
n.offsite = 4;

% Import input datasets
Emissions.LU = importdata('LiquidsUnloadings.csv');
Emissions.HARC = importdata('HARC.csv');
Emissions.gvakharia = importdata('gvakharia.csv');

Activity.prod_bbl = Activity_tranches(1,:)'; %bbl/day
Activity.wells = Activity_tranches(2,:)'; %number of wells
Activity.frac_C1 = Activity_tranches(3,:)'; % molar percent (0 - 100)
Activity.GOR = Activity_tranches(4,:)'; % scf/bbl
Activity.LU = Activity_tranches(5,:)'; % integer from 0-2
Activity.frac_wells_flaring = Activity_tranches(6,:); % fraction

Activity.prod_scf = Activity.prod_bbl .* Activity.GOR; % scf/day
Activity.prod_kg = Activity.prod_scf .* ((16.041 * 1.20233 .* (Activity.frac_C1 / 100)) / 1000); % kg CH4/day

%% Calculations

for i = 1:n_trial
  
    % Read input data files
    
    cd(strcat(root_path,'\Set21_Inputs'))  
    
    csvFileName = ['EquipGas' num2str(i) '.csv'];
    dataraw = importdata(csvFileName);
    EquipGas = dataraw;
    
    csvFileName = ['EquipOil' num2str(i) '.csv'];
    dataraw = importdata(csvFileName);
    EquipOil = dataraw;  
    
    cd(root_path) 
    
    % Calculations are performed within fugitives macro
    
    for j = 1:n.fields
    	if  j == 1
                Data_Out = zeros(1,1);
        end
        [Data_Out] = fugitives_v2(n, j, maxit, Activity, AF, Emissions, EquipGas, EquipOil, Data_Out, Basin_Select);

    end
    
    % Save output
    if Basin_Select == 0
        cd(strcat(root_path,'\Outputs'))
        FileName = ['Equip' num2str(i)  'out.csv']; 
       csvwrite(FileName,Data_Out);
        cd(root_path)
    else
        cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'

        FileName = ['Equip' num2str(i) Basin_Index{Basin_Select} 'out.csv']; 
       csvwrite(FileName,Data_Out);

        cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
    end

end

end






