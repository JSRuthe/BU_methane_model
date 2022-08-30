function [tranche_OPGEE, OPGEE_bin] = tranche_gen_func(Basin_Select, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename, GHGRP_exp)


%% Import data

% LU Types for year 2015 based on 2020 GHGI
filepath = fullfile(pwd, activityfolder,'LU_type.csv');
LU_type = importdata(filepath);

% Gas composition
% C1_frac = importdata('C1_frac.csv');

if Basin_Select == 0
    LU_type = [0.1036 0.0714 0.825];
    % C1 frac adjusted in function
%     C1_frac = 0;    
else
    LU_type = LU_type(Basin_Select, :);
%     C1_frac = C1_frac(Basin_Select,:);
end


if Basin_Select == 0
    filepath = fullfile(pwd, drillinginfofolder,'david_lyon_2015_no_offshore.csv');
    %csvFileName = 'david_lyon_2015_no_offshore.csv';
    file = fopen(filepath);
    M_in = csvread(filepath,0,0);
    fclose(file);
else
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
    
end


%% Analysis

if Basin_Select ~= 0
    Well_Count = ones(numel(Basin_Name),1);
    logind = ismember(Basin_Name, Basin_N(Basin_Select));
    M_all = [Oil_Production, Gas_Production, Well_Count];
    ind = logind;
    ind = int16(ind);
    M_in = M_all(ind == 1,:);
end

[plot_dat, OPGEE_bin] = di_scrubbing_func(M_in, Basin_Select, Basin_Index, activityfolder);

if Basin_Select ~=0
    flare_tab = flaring_tranche(Basin_Select, Basin_Index, Basin_N, OPGEE_bin, activityfolder);
else
    flare_tab = 0;
end

col_nums = [5:14,17];
for i = 1:11
    all_prod(i) = sum((GHGRP_exp([1:10],col_nums(i)).*OPGEE_bin.all([1:10],1)))/sum(OPGEE_bin.all([1:10],1));
    low_prod(i) = sum((GHGRP_exp([1:3],col_nums(i)).*OPGEE_bin.all([1:3],1)))/sum(OPGEE_bin.all([1:3],1));
    high_prod(i) = sum((GHGRP_exp([4:10],col_nums(i)).*OPGEE_bin.all([4:10],1)))/sum(OPGEE_bin.all([4:10],1));
end

AF_basin = [all_prod; low_prod; high_prod];

FileName = ['AF_' Basin_Index{Basin_Select} '.xlsx'];
filepath = fullfile(pwd, 'Outputs/',FileName);
xlswrite(filepath,AF_basin)

OPGEE_bin.gasdry(:,5:15) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.gasassoc(:,5:15) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.oilwgas(:,5:15) = [repmat(low_prod,3,1); repmat(high_prod,7,1)];
OPGEE_bin.oil(:,5:15) = [repmat(low_prod,3,1); repmat(high_prod,1,1)];

[tranche_OPGEE] = OPGEE_rows_func(Basin_Select, OPGEE_bin, LU_type, flare_tab);

if Basin_Select == 0
    filepath = fullfile(pwd, activityfolder,'frac_wells_flaring.csv');
    frac_wells_flaring = importdata(filepath);
    tranche_OPGEE(:,6) = frac_wells_flaring;
end

end
