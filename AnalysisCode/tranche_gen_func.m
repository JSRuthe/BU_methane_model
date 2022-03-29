function [tranche_OPGEE] = tranche_gen_func(Basin_Select, Basin_Index, Basin_N, activityfolder, basinmapfolder)


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
    csvFileName = 'david_lyon_2015_no_offshore.csv';
    file = fopen(csvFileName);
    M_in = csvread(csvFileName,0,0);
    fclose(file);
else
    filepath = fullfile(pwd, basinmapfolder,'Basin_Identifier_Export_Pivot_22221.mat');
    load(filepath);
    Prior_12_Gas(isnan(Prior_12_Gas)) = 0;
    Prior_12_Oil(isnan(Prior_12_Oil)) = 0;
    Basin_Name(Basin_Name == 'CENTRAL BASIN PLATFORM' | ...
               Basin_Name == 'DELAWARE' | ...
               Basin_Name == 'MIDLAND') = 'PERMIAN';
    Basin_Name(Basin_Name == 'SAN JOAQUIN' | ...
               Basin_Name == 'SACRAMENTO') = 'CALIFORNIA';
    
end


%% Analysis

if Basin_Select ~= 0

    logind = ismember(Basin_Name, Basin_Index{Basin_Select});
    M_all = [Prior_12_Oil, Prior_12_Gas, Well_Count];
    ind = logind;
    ind = int16(ind);
    M_in = M_all(ind == 1,:);
    x = 1;
end

[plot_dat, OPGEE_bin] = di_scrubbing_func(M_in, Basin_Select, Basin_Index, activityfolder);

if Basin_Select ~=0
    flare_tab = flaring_tranche(Basin_Select, Basin_Index, Basin_N, OPGEE_bin, activityfolder);
else
    flare_tab = 0;
end

[tranche_OPGEE] = OPGEE_rows_func(Basin_Select, OPGEE_bin, LU_type, flare_tab);

if Basin_Select == 0
    frac_wells_flaring = importdata('frac_wells_flaring.csv');
    tranche_OPGEE(:,6) = frac_wells_flaring;
end

end
