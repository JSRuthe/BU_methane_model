function [equipdata_tot] = data_proc_master_func(n_trial, root_path, Basin_Select, Basin_Index)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPGEE OUTPUTS DATA PROCESSING
% Jeff Rutherford
% last updated November 1, 2020
%
% The purpose of this code is to generate processed data from OPGEE outputs
% See Supplementary Information Section 3.1.3 for a description of OPGEE
% output formatting
% 
% First, this script produces outputs which are transferred to Total 
% Emissions plotting scripts. 
%   - Emissions totals
%       - save('Emissionsdata_SetX.mat','EmissionsGas','EmissionsOil','Superemitters');
%   - Clustered site-level outputs (see below):
%       - save('sitedata_SetX.mat','sitedata_All');
%
% Second, this script also produces outputts which are transferred to
% Equipment level emissions factor plots
%   - Equipment level emission factor vectors
%       - save('equipdata_SetX.mat','equipdata_tot', '-v7.3'); 
%
% recall that OPGEE sampled only a subset of national wells to
% reduce processing time. This script references a function to extrapolate
% wells:
%    - "mat_extend.m" - "Sampled" well totals from OPGEE outputs are
%   extrapolated to actual national well counts. This extrapolation is
%   done, tranche by tranche, by duplicating the existing sampled matrix
%
% Several additional functions are available depending on several binary
% user inputs:
%   (i) welloption = 1
%       This option uses the function "wellpersite_v5.m" 
%       - "wellpersite_v5.m" - USing well counts per site from the Alvarez
%       2018 paper, bin specific well counts are randomly assigned and
%       OPGEE resultts rows are "clustered"
%
%   (ii) equipoption = 1
%       Equipment level vectors are saved
%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% Input data:
%
%  OPGEE outputs
%       col 1 = tranche iteration (1-74)
%       col 2 = OPGEE row (200 - 273)
%       col 3 = sample (wells/sample size)
%       col 4 = well productivity [kg/well/d]
%       col 5 = well productivity [scf/well/d]
%       col 6 - 21 = equipment array
%       col 22 = sum of equipment array
%
% Output data:
%   Site-level data
%       col 1 = tranche #
%       col 2 = sum of emissions [kg/d]
%       col 3 = wells per site
%       col 4 = site productivity [mscf/site/day]
%       col 5 = site productivity [kg/d]
%       col 6 = fractional loss rate
%
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
%       row 15 - Combustion
%       row 16 - Tank Venting
%       row 17 - Flare methane
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inputs

% Binary options
    welloption = 0;
    equipoption = 1;

%% Begin data processing
    
% Define colors to use in plots
    StanfordRed = [140/255,21/255,21/255]; %Stanford red
    StanfordOrange = [233/255,131/255,0/255];% Stanford orange
    StanfordYellow = [234/255,171/255,0/255];% Stanford yello
    StanfordLGreen = [0/255,155/255,118/255];% Stanford light green
    StanfordDGreen = [23/255,94/255,84/255];% Stanford dark green
    StanfordBlue = [0/255,152/255,219/255];% Stanford blue
    StanfordPurple = [83/255,40/255,79/255];% Stanford purple
    Sandstone = [210/255,194/255,149/255];
    LightGrey = [0.66, 0.66, 0.66];

% Preallocate matrices
    welldata.drygas = zeros(1,1);
    welldata.gaswoil = zeros(1,1);
    welldata.assoc = zeros(1,1);
    welldata.oil = zeros(1,1);
    % welldata_all = zeros(1,1,1);
    equipdata.drygas = zeros(1,1);
    equipdata.gaswoil = zeros(1,1);
    equipdata.assoc = zeros(1,1);
    equipdata.oil = zeros(1,1);
    gasvectot = zeros(1,1);
    oilvectot = zeros(1,1);
    sitedatainit.drygas = [];
    sitedatainit.gaswoil = [];
    sitedatainit.assoc = [];
    sitedatainit.oil = [];
    sitedata.drygas = [];
    sitedata.gaswoil = [];
    sitedata.assoc = [];
    sitedata.oil = [];
    results_tab = zeros(1,1);
    results_hist = zeros(1,1);

% Process tranche data from the David Lyon file if welloption is selected
if welloption == 1
    [tranche] = tranche_data;
end
    
counter = 0;
s = [];

for k = 1:n_trial
        if Basin_Select == 0
            cd(strcat(root_path,'\Outputs'))
            csvFileName = ['Equip' num2str(k) 'out.csv'];
            dataraw = importdata(csvFileName);
            cd(root_path)
        else
            cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'

            csvFileName = ['Equip' num2str(k) Basin_Index{Basin_Select} 'out.csv'];
            dataraw = importdata(csvFileName);

            cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
        end
        counter = counter + 1;

        [EmissionsGas(:,counter), EmissionsOil(:,counter), Superemitters(counter), welldata, equipdata] = mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption);

    if welloption == 1
        sitedata = wellpersite_v5(welldata, tranche);
        [sitedata, sitedatainit] = adjustlengths(sitedata,sitedatainit, k);
        
        DataMerged = [];
        if any(sitedata.drygas(:)); DataMerged = [DataMerged; sitedata.drygas]; end
        if any(sitedata.gaswoil(:)); DataMerged = [DataMerged; sitedata.gaswoil]; end
        if any(sitedata.assoc(:)); DataMerged = [DataMerged; sitedata.assoc]; end
        sitedata_All(:,:,k) = DataMerged;
        
        if k == n_trial
            if Basin_Select == 0
                cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
                FileName = ['sitedata_out.mat'];
                save(FileName,'sitedata_All', '-v7.3'); 
                cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
            else
                cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
                FileName = ['sitedata_' Basin_Index{Basin_Select} 'out.mat'];
                save(FileName,'sitedata_All', '-v7.3'); 
                cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
            end
        end
        
    end
    
    if equipoption == 1
        
        equipdata_tot.drygas(:,:,k) = equipdata.drygas;
        equipdata_tot.gaswoil(:,:,k) = equipdata.gaswoil;
        equipdata_tot.assoc(:,:,k) = equipdata.assoc;
        equipdata_tot.oil(:,:,k) = equipdata.oil;
        
%         equipdata_tot.all = [equipdata_tot.drygas; equipdata_tot.gaswoil; equipdata_tot.assoc; equipdata_tot.oil];
%         if k == n_trial
%            save('equipdata_SetPermian.mat','equipdata_tot', '-v7.3'); 
%         end
        
    end
    
end


    %   PRINT OUTPUTS FROM THIS SECTION
Equip_List = {                 
    'Wells',...               % (1) 
    'Header',...              % (2) 
    'Heater',...              % (3) 
    'Separators',...          % (4)
    'Meter',...               % (5)    
    'Tanks - leaks',...       % (6) 
    'Tanks - vents',...       % (7)
    'Recip Compressor',...    % (8)
    'Dehydrators',...         % (9)
    'CIP',...                 % (10)
    'PC',...                  % (11)
    'LU',...                  % (12)
    'Completions',...         % (13)
    'Workovers',...           % (14)
    'Combustion',...          % (15)
    'Tank Venting',...        % (16)
    'Flare methane'};         % (17)

data_tab = cell(18,3);

data_tab(1,2) = cellstr('Gas sites');
data_tab(1,3) = cellstr('Oil sites');

for i = 2:18
    data_tab(i,1) = cellstr(Equip_List{i-1});
    data_tab(i,2) = num2cell(mean(EmissionsGas(i-1,:)));
    data_tab(i,3) = num2cell(mean(EmissionsOil(i-1,:)));
end

if Basin_Select == 0
    cd(strcat(root_path,'\Outputs'))
    FileName = ['Emission_Summary_out.xlsx'];
    xlswrite(FileName, data_tab)
    cd(root_path)    
else
    cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
    FileName = ['Emission_Summary_' Basin_Index{Basin_Select} 'out.xlsx'];
    xlswrite(FileName, data_tab)
    cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
end

if Basin_Select == 0
    cd(strcat(root_path,'\Outputs'))    
    FileName = ['Emissionsdata_out.mat'];
    save(FileName,'EmissionsGas','EmissionsOil')
    cd(root_path)    
else
    cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Outputs_flash_2'
    FileName = ['Emissiondata_' Basin_Index{Basin_Select} 'out.mat'];
    save(FileName,'EmissionsGas','EmissionsOil')
    cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE'
end



end
    
