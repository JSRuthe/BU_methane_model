function [tranche_OPGEE, OPGEE_bin, Enverus_tab, AF_basin] = tranche_gen_func(i, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename, GHGRP_exp, Replicate)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function:
%	(i)   takes raw drillinginfo data and organizes into categories 
%       according to a specified GOR cutoff and bins according to 
%       productivity
%       - Fill out columns 1-4 of OPGEE bin
%               Col 1 = well count
%               Col 2 = Average gas productivity (mscf/well/day)
%               Col 3 = Total gas production (mscf/day)
%               Col 4 = Total oil production (bbl/day)
%
%   (ii)  takes GHGRP activity factors, and corrects for the actual
%   productivity distribution
%           - If AF_i,j is the GHGRP based activity factor, we are
%           interested in a set of AF corrected for the actual productivity
%           distribution. We construct an overall weighted average, low
%           productivity average (<10 mscf/well/day) and a high productivyt
%           average
%           - The low productivity average is applied to bins 1-3, and the
%           high productivity average is applied to bins 4-10
%           - Fill out columsn 5-16 of OPGEE bin
%               Col 5 = Headers
%               Col 6 = Heaters
%               Col 7 = Separators
%               Col 8 = Meters
%               Col 9 = Tanks
%               Col 10 = Tanks
%               Col 11 = Reciprocating compressors
%               Col 12 = Dehydrators
%               Col 13 = CIPs
%               Col 14 = PCs
%               Col 15 = Oil controls 
%               Col 16 = Average methane content 
%
% Inputs:
%   Basin_Select:   Main iterative index (i) from "main" function
%   Basin_Index:    Cell array of basin names
%   GHGRP_exp:      Binned activity factor matrix
%               Col 1 = GHGRP Well count
%               Col 2 = GHGRP Mean Gas
%               Col 3 = GHGRP Total Gas
%               Col 4 = GHGRP Total Oil
%               Col 5 = Headers
%               Col 6 = Heaters
%               Col 7 = Separators
%               Col 8 = Meters
%               Col 9 = Tanks
%               Col 10 = Tanks
%               Col 11 = Reciprocating compressors
%               Col 12 = Dehydrators
%               Col 13 = CIPs
%               Col 14 = PCs
%               Col 15 = [blank]
%               Col 16 = Total oil throughput
%               Col 17 = Oil controls 
%               Col 18 = Average methane content 
% Outputs:
%	tranche_OPGEE:
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
% This function calls three subfunctions:
% di_scrubbing_func:takes raw drillinginfo data, organizes into categories 
%                   according to a specified GOR cutoff, and bins according
%                   to gas productivity
% flaring_trache:  This function calculates fraction of wells flaring for 
%                   each bin 
% OPGEE_rows_func:  This function takes input data from Enverus and GHGRP 
%               (gathered in the main "tranche_gen_func" and prepares it 
%               in a column  format suitable for the methane model
%
%
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
    EnverusDataBasin = csvread(filepath,0,0);
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


%% Process raw DrillingInfo data

if Replicate  ~= 1
    Well_Count = ones(numel(Basin_Name),1);
    logind = ismember(Basin_Name, Basin_N(i));
    EnverusDataAll = [Oil_Production, Gas_Production, Well_Count];
    ind = logind;
    ind = int16(ind);
    EnverusDataBasin = EnverusDataAll(ind == 1,:);
end

% - di_scrubbing_func takes raw drillinginfo data, organizes into categories 
% according to a specified GOR cutoff, and bins according to gas 
% productivity
% - Fill out columns 1-4 of OPGEE bin
%               Col 1 = well count
%               Col 2 = Average gas productivity (mscf/well/day)
%               Col 3 = Total gas production (mscf/day)
%               Col 4 = Total oil production (bbl/day)
[Enverus_tab, EnverusDataBasin, OPGEE_bin] = di_scrubbing_func(EnverusDataBasin, i, Basin_Index, activityfolder);

if Replicate  ~= 1
    flare_tab = flaring_tranche(i, Basin_Index, Basin_N, OPGEE_bin, activityfolder);
else
    flare_tab = 0;
end

%% Calculating weighted average activity factors, correcting GHGRP values 
%  for the actual productivity distribution
%           - Fill out columsn 5-16 of OPGEE bin
%               Col 5 = Headers
%               Col 6 = Heaters
%               Col 7 = Separators
%               Col 8 = Meters
%               Col 9 = Tanks
%               Col 10 = Tanks
%               Col 11 = Reciprocating compressors
%               Col 12 = Dehydrators
%               Col 13 = CIPs
%               Col 14 = PCs
%               Col 15 = Oil controls 
%               Col 16 = Average methane content 

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

% FileName = ['AF_' Basin_Index{i} '.xlsx'];
% filepath = fullfile(pwd, 'Outputs/',FileName);
% xlswrite(filepath,[[OPGEE_bin.gasdry flare_tab.gasdry(:,4)];...
%                    [OPGEE_bin.gasassoc flare_tab.gasassoc(:,4)];...
%                    [OPGEE_bin.oilwgas flare_tab.oilwgas(:,4)];...
%                    [OPGEE_bin.oil flare_tab.oil(:,4)]])

[tranche_OPGEE] = OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab, EnverusDataBasin);

if i == 0
    filepath = fullfile(pwd, activityfolder,'frac_wells_flaring.csv');
    frac_wells_flaring = importdata(filepath);
    tranche_OPGEE(:,6) = frac_wells_flaring;
end

end
