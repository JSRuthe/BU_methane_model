function [tranche_OPGEE, OPGEE_bin, Enverus_tab, AF_basin] = tranche_gen_func(i, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename, GHGRP_exp, Replicate)


 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  
 %
 % Tranches
 % 
 % Tranche export:
 % (1)  Total oil production
 % (2)  Well count
 % (3)  C1 fraction
 % (4)  GOR [scf/bbl]
 % (5)  LU type
 % (6)  fraction of wells flaring
 % (7)  Headers
 % (8)  Heaters
 % (9)  Separators
 % (10)  Meters
 % (11)  Tanks
 % (12) Tanks
 % (13) Reciprocating compressors
 % (14) Dehydrators
 % (15) CIPs
 % (16) PCs
 % (17) Oil controls 
 % 
 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  


%% Import data

% LU Types for year 2015 based on 2020 GHGI
filepath = fullfile(pwd, activityfolder,'LU_type.csv');
LU_type = importdata(filepath);

% Gas composition
% C1_frac = importdata('C1_frac.csv');

if Replicate == 1
    LU_type = [0.1036 0.0714 0.825];
    % C1 frac adjusted in function
%     C1_frac = 0;    
else
    LU_type = LU_type(i, :);
%     C1_frac = C1_frac(Basin_Select,:);
end


if Replicate == 1
    filepath = fullfile(pwd, drillinginfofolder,'david_lyon_2015_no_offshore.csv');
    %csvFileName = 'david_lyon_2015_no_offshore.csv';
    file = fopen(filepath);
    M_in = csvread(filepath,0,0);
    fclose(file);
else
    % Distributions paper
    formatSpec = '%f%f%f%f%f%f%f%f%f%C';
    filepath = fullfile(pwd, drillinginfofolder,DI_filename);
    DI_data = readtable(filepath,'Format',formatSpec);
    DI_data.Prov_Cod_1(DI_data.Prov_Cod_1 == '160A') = '160';
    
    catdata = DI_data.Prov_Cod_1;
    strings = string(catdata);
    Basin_Name = double(strings);
    
    % Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.
    Gas_Production = DI_data.Monthly_Ga;
    Oil_Production = DI_data.Monthly_Oi;
    Gas_Production(isnan(Gas_Production)) = 0;
    Oil_Production(isnan(Oil_Production)) = 0;

    % North America paper
    
%     formatSpec = '%f%f%f%f%f%f%f%f%f%C';
%     filepath = fullfile(pwd, drillinginfofolder,DI_filename);
%     DI_data = readtable(filepath,'Format',formatSpec);
%     DI_data.Prov_Cod_1(DI_data.Prov_Cod_1 == '160A') = '160';
%         
%     catdata = DI_data.Prov_Cod_1;
%     strings = string(catdata);
%     Basin_Name = double(strings);
%     
%     % Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.
%     Gas_Production = DI_data.Annual_Gas;
%     Oil_Production = DI_data.Annual_Oil;
%     Gas_Production(isnan(Gas_Production)) = 0;
%     Oil_Production(isnan(Oil_Production)) = 0;
    
end


%% Analysis

if Replicate  ~= 1
    Well_Count = ones(numel(Basin_Name),1);
    logind = ismember(Basin_Name, Basin_N(i));
    M_all = [Oil_Production, Gas_Production, Well_Count];
    ind = logind;
    ind = int16(ind);
    M_in = M_all(ind == 1,:);
end
    

[plot_dat,Enverus_tab, OPGEE_bin] = di_scrubbing_func(M_in, i, Basin_Index, activityfolder);

if Replicate  ~= 1
    flare_tab = flaring_tranche(i, Basin_Index, Basin_N, OPGEE_bin, activityfolder);
else
    flare_tab = 0;
end

col_nums = [5:14,17,18];
for j = 1:12
    all_prod(j) = sum((GHGRP_exp([1:10],col_nums(j)).*OPGEE_bin.all([1:10],1)))/sum(OPGEE_bin.all([1:10],1));
    low_prod(j) = sum((GHGRP_exp([1:3],col_nums(j)).*OPGEE_bin.all([1:3],1)))/sum(OPGEE_bin.all([1:3],1));
    high_prod(j) = sum((GHGRP_exp([4:10],col_nums(j)).*OPGEE_bin.all([4:10],1)))/sum(OPGEE_bin.all([4:10],1));
end

AF_basin = [all_prod; low_prod; high_prod];

FileName = ['AF_' Basin_Index{i} '.xlsx'];
filepath = fullfile(pwd, 'Outputs/',FileName);
xlswrite(filepath,AF_basin)

OPGEE_bin.gasdry(:,5:16) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.gasassoc(:,5:16) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.oilwgas(:,5:16) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.oil(:,5:16) = [repmat(low_prod,3,1); repmat(high_prod,1,1)];

 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  
 %
 % Methane model inputs are compiled from (i) Enverus and (ii) GHGRP
 % 
 % Bins export:
 % (1)  Well count
 % (2)  Mean Gas
 % (3)  Total Gas
 % (4)  Total Oil
 % (5)  Headers
 % (6)  Heaters
 % (7)  Separators
 % (8)  Meters
 % (9)  Tanks
 % (10) Tanks
 % (11) Reciprocating compressors
 % (12) Dehydrators
 % (13) CIPs
 % (14) PCs
 % (15) Oil controls 
 % (16) Average methane content 
 % 
 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  

% FileName = ['AF_' Basin_Index{i} '.xlsx'];
% filepath = fullfile(pwd, 'Outputs/',FileName);
% xlswrite(filepath,[[OPGEE_bin.gasdry flare_tab.gasdry(:,4)];...
%                    [OPGEE_bin.gasassoc flare_tab.gasassoc(:,4)];...
%                    [OPGEE_bin.oilwgas flare_tab.oilwgas(:,4)];...
%                    [OPGEE_bin.oil flare_tab.oil(:,4)]])

[tranche_OPGEE] = OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab);

if i == 0
    filepath = fullfile(pwd, activityfolder,'frac_wells_flaring.csv');
    frac_wells_flaring = importdata(filepath);
    tranche_OPGEE(:,6) = frac_wells_flaring;
end

end
