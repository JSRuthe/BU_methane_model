function [equipdata_tot] = data_proc_master_func(n_trial, welloption, equipoption, Basin_Select, Basin_Index, activityfolder, drillinginfofolder, Enverus_tab, AF_basin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Methane model outputs data processing
%
% Input data:
%
%  autorun outputs used as inputs for this function
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
%
% Output data:
%   Site-level data
%       col 1 = tranche #
%       col 2 = sum of emissions [kg/d]
%       col 3 = wells per site
%       col 4 = site productivity [mscf/site/day]
%       col 5 = site productivity [kg/d]
%       col 6 = fractional loss rate
%       col 7 = site productivity [bbl/d]
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


%% Begin data processing

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
    sitedata_old.drygas = [];
    sitedata_old.gaswoil = [];
    sitedata_old.assoc = [];
    sitedata_old.oil = [];
    results_tab = zeros(1,1);
    results_hist = zeros(1,1);

% Process tranche data from the David Lyon file if welloption is selected
if welloption == 1
    [tranche] = tranche_data(drillinginfofolder);
end
    
counter = 0;
s = [];

for k = 1:n_trial
    if Basin_Select == 0
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
        csvFileName = ['Equip' num2str(k) 'out.csv'];
        filepath = fullfile(pwd, 'Outputs/',csvFileName);
        dataraw = importdata(filepath);
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    else
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
        
        csvFileName = ['Equip' num2str(k) Basin_Index{Basin_Select} 'out.csv'];
        filepath = fullfile(pwd, 'Outputs/',csvFileName);
        dataraw = importdata(filepath);
        
        %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
    end
    counter = counter + 1;
    
    [EmissionsGas(:,counter), EmissionsOil(:,counter), Superemitters(counter), welldata, equipdata] = mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab, AF_basin);
    wellpersite = 0;
    if welloption == 1
        if Basin_Select ~= 0
            fprintf('Basin %s, site iter %f... \n', Basin_Index{Basin_Select}, k)
        end
        sitedata = wellpersite_func(welldata, tranche, k, AF_basin);
        %if ~any(sitedata.drygas(:)); sitedata.drygas = sitedata_old.drygas; end
        %if ~any(sitedata.gaswoil(:)); sitedata.gaswoil = sitedata_old.gaswoil; end
        %if ~any(sitedata.assoc(:)); sitedata.assoc = sitedata_old.assoc; end
        %if ~any(sitedata.oil(:)); sitedata.oil = sitedata_old.oil; end
        
        fprintf('Sitedata, %g, Total gas = %d \n',k,(sum(sitedata.drygas(:,2)) + sum(sitedata.gaswoil(:,2)) + sum(sitedata.assoc(:,2)) + sum(sitedata.oil(:,2)))*(365)/1000000000)
        
        %[sitedata, sitedatainit] = adjustlengths(sitedata,sitedatainit, k);
        
        DataMerged = [];
        if any(sitedata.drygas(:)); DataMerged = [DataMerged; sitedata.drygas]; end
        if any(sitedata.gaswoil(:)); DataMerged = [DataMerged; sitedata.gaswoil]; end
        if any(sitedata.assoc(:)); DataMerged = [DataMerged; sitedata.assoc]; end
        if any(sitedata.oil(:)); DataMerged = [DataMerged; sitedata.oil]; end
        %sitedata_All(:,:,k) = DataMerged;
        sitedata_All = DataMerged;
        
        if Basin_Select == 0
            %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
            %FileName = ['sitedata' num2str(k) '.csv'];
            %filepath = fullfile(pwd, 'Outputs/',FileName);
            %save(FileName,'sitedata_All', '-v7.3');
            csvwrite(filepath,sitedata_All);
            %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
        else
            %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
            
            FileName = ['sitedata_' Basin_Index{Basin_Select} num2str(k) '.csv'];
            filepath = fullfile(pwd, 'Outputs/',FileName);
            save(filepath,'sitedata_All', '-v7.3');
            csvwrite(filepath,sitedata_All);
            %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
        end
        
        %         if k == n_trial
        %             if Basin_Select == 0
        %                 cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
        %                 FileName = ['sitedata_out.mat'];
        %                 save(FileName,'sitedata_All', '-v7.3');
        %                 cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
        %             else
        %                 %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
        %
        %                 FileName = ['sitedata_' Basin_Index{Basin_Select} 'out.mat'];
        %                 filepath = fullfile(pwd, 'Outputs/',FileName);
        %                 save(filepath,'sitedata_All', '-v7.3');
        %                 %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
        %             end
        %         end
        
    end
    
    if equipoption == 1
        
        equipdata_tot.drygas(:,:,k) = equipdata.drygas;
        equipdata_tot.gaswoil(:,:,k) = equipdata.gaswoil;
        equipdata_tot.assoc(:,:,k) = equipdata.assoc;
        equipdata_tot.oil(:,:,k) = equipdata.oil;
    else
        equipdata_tot = [];
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
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
    FileName = ['Emission_Summary_out.xlsx'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
    xlswrite(filepath, data_tab)
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'    
else
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
    FileName = ['Emission_Summary_' Basin_Index{Basin_Select} 'out.xlsx'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
    xlswrite(filepath, data_tab)
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
end

if Basin_Select == 0
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
    FileName = ['Emissionsdata_out.mat'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
    save(filepath,'EmissionsGas','EmissionsOil')
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'    
else
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'
    FileName = ['Emissiondata_' Basin_Index{Basin_Select} 'out.mat'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
    save(filepath,'EmissionsGas','EmissionsOil')
    %cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2'
end

% save('Emissionsdata_set21_1-100.mat','EmissionsGas','EmissionsOil','Superemitters');


end
    
