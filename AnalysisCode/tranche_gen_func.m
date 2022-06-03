function [tranche_OPGEE] = tranche_gen_func(Basin_Select, Basin_Index, Basin_N, activityfolder, basinmapfolder,drillinginfofolder2, DI_filename)


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
    formatSpec = '%f%f%f%f%f%f%f%f%f%C';
    filepath = fullfile(pwd, drillinginfofolder2,DI_filename);
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

[tranche_OPGEE] = OPGEE_rows_func(Basin_Select, OPGEE_bin, LU_type, flare_tab);

if Basin_Select == 0
    frac_wells_flaring = importdata('frac_wells_flaring.csv');
    tranche_OPGEE(:,6) = frac_wells_flaring;
end

end
