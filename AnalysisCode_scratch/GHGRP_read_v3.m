function [GHGRP_exp] = GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function:
%   (i) Reads the following sheets:
%           Note that these sheets were already pre-filtered and the key
%           columns were selected as follows:
%
%           (a) RYX_FACILITY_OVERVIEW
%               - Filtered for onshore natural gas and oil production segment
%               - Columsn remaining
%                   (i) Faility
%                   (ii) Basin ID
%                   (iii) producing wells
%                   (iv) CH4 mole fraction
%           (b) RYX_EF_W_EQUIP_LEAKS_ONSHORE
%               - Filtered for onshore natural gas and oil production segment
%               - columns remaining
%                   (i) Faility
%                   (ii) Equipmenct type
%                   (iii) Equipment count
%                   (iv) Basin ID
%               - Replace #VALUE!, #REF, #NA with ""
%               - Replace 160A with 160
%           (c) RYX_EF_W_ATM_STG_TANKS_CALC1
%               - Filtered for onshore natural gas and oil production segment
%                   (i) Facility
%                   (ii) QVRU
%                   (iii) QVENT
%                   (iv) QFLARE
%                   (v) Tank count
%                   (vi) Basin ID
%               - Replace #VALUE!, #REF, #NA with ""
%               - Replace 160A with 160%           
%           (d) RYX_EF_W_ATM_STG_TANKS_CALC3
%               - Filtered for onshore natural gas and oil production segment
%                   (i) Facility
%                   (ii) Qvru
%                   (iii) Qvent
%                   (iv) Qflare
%                   (v) Tank count
%                   (vi) Basin ID
%               - Replace #VALUE!, #REF, #NA with ""
%               - Replace 160A with 160
%           (e) RYX_NGPNEUMATIC_DEV_UNITS
%               - Filtered for onshore natural gas and oil production segment
%                   (i) Facility
%                   (ii) Equipment count
%                   (iii) Basin ID
%               - Replace #VALUE!, #REF, #NA with ""
%               - Replace 160A with 160
%           (f) RYX_NGPNEUMATIC_PMP_UNITS
%               - Filtered for onshore natural gas and oil production segment
%                   (i) Facility
%                   (ii) Equipment count
%                   (iii) Basin ID
%               - Replace #VALUE!, #REF, #NA with ""
%               - Replace 160A with 160
%
%  (ii) Load "API_Facility_correspondence" table
%           - The API-facility correspondence table is generated in a separate script
%               -- load_GHGRP_wells_NApaper.py
%               -- load_GHGRP_wells_Disrtibutions.py
%           - This script matches Enverus API values to GHGRP API values in the
%               table "EF_W_ONSHORE_WELLS"
%           - The matching in this exercise is not perfect
%           - GHGRP Facilities are connected to discrete Enverus wells using the
%               API_facility correspondence table. Each well in the API-facility
%               correspondence table is a unique API #
%
%  (iii) Filter GHGRP data by basin
%           FAcility basin correspondence was created from
%           "Equipment_Counts_v9_RY2020_Distributions.xlsx"
%           Facility_ID and Basin copied from tab "RY_2020+FACILITY_OVERVIEW"
%           Sorted for Onshore petroleum and natural gas production
%           Removed duplicates
%
%   (iv) Process data
%           Output format is on a "facility-basis" where each row
%           corresponds to a single unique facility
%   
%   (v) Convert data from a facility-basis to a well-basis
%           - Based on the facility corresponding to each well (from the 
%           "API_Facility_correspondence" table) activity values are
%           assigned to each well
%           - Each row corresponds to a unique API value reporting to the
%           GHGRP
%           - The following matrix is constructed:
%           - M_new:
%               Col 1 = FACILITY ID
%               Col 2 = Oil (bbl/day)
%               Col 3 = gas (Mscf/day)
%               Col 4 = # wells (onshore wells)
%               Col 5 = # wells (equip_leaks)
%               Col 6 = # wells (facility counts)
%               Col 7 = HEader per well x
%               Col 8 = Heater per well x
%               Col 9 = Separator per well x
%               Col 10 = Meter per well
%               Col 11 = Tanks per well (leaks)
%               Col 12 = Tanks per well (hatch)
%               Col 13 = Recip compressor per well
%               Col 14 = Dehydrators
%               Col 15 = inj pump per well
%               Col 16 = PC per well
%               Col 17 = [blank]
%               Col 18 = oil throughput
%               Col 19 = oil controlled
%               Col 20 = CH4 mole fraction
%
%   (vi) Bin activity factors into gas produictivity tranches with the
%   appropriate weightings
%           - GHGRP_exp:
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
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters for processing
cutoff = 100;% Mscf/bbl


%% Import API-facility correspondence table
% (1) FACILITY ID
% (2) Annual oil [bbl/year]
% (3) Annual gas [mscf/year]

% filepath = fullfile(pwd, GHGRPfolder,'API_Facility_correspondence_2020.csv');
% facility_correspondence = csvread(filepath,1,1);

formatSpec = '%f%f%f%f%C%f%f';
filepath = fullfile(pwd, GHGRPfolder,'API_Facility_correspondence_2020.csv');
facility_correspondence = readtable(filepath,'Format',formatSpec);
% facility_correspondence.Prov_Cod_1(facility_correspondence.Prov_Cod_1 == '160A') = '160';
% 
% catdata = facility_correspondence.Prov_Cod_1;
% strings = string(catdata);
% Basin_Name = double(strings);

Gas_Production = facility_correspondence.AnnualGas_mscf_year_;
Oil_Production = facility_correspondence.AnnualOil_bbl_year_;
Gas_Production(isnan(Gas_Production)) = 0;
Oil_Production(isnan(Oil_Production)) = 0;
Facility_No = facility_correspondence.FACILITY_ID;

% M_all
% - # rows = All API numbers for all basins in EF_W_ONSHORE that could be
%   matched with the Enverus dataset
M_all = [Facility_No, Oil_Production, Gas_Production];

% add a vector with well counts by facility in EF_W_ONSHORE
[unique_Facilities, ia,ic] = unique(M_all(:,1));
Facility_Counts = accumarray(ic,1);
Facility_Counts = [unique_Facilities, Facility_Counts];

[Lia, Locb] = ismember(M_all(:,1), Facility_Counts(:,1));
M_all(:,4) = Facility_Counts(Locb,2);    

%% Filter table by basin

formatSpec = '%f%C';
filepath = fullfile(pwd, GHGRPfolder,'Facility_Basin_correspondence_2020.csv');
facility_basin = readtable(filepath,'Format',formatSpec);
%facility_basin.Basin_ID(facility_correspondence.Basin_ID == '160A') = '160';

catdata = facility_basin.Basin_ID;
strings = string(catdata);
Basin_Name = double(strings);

basin_ind = ismember(Basin_Name, Basin_N(i));
ind = basin_ind;
ind = int16(ind);
facility_basin = facility_basin(ind == 1,:);

% Lia = logical true or false
% Loc_facilities = the lowest index in B for each value in A that is a member of B
[Lia, Loc_facilities] = ismember(M_all(:,1),facility_basin.FACILITY_ID);

% M_in
% - # rows = All API numbers for all basins in EF_W_ONSHORE that could be
%   matched with the Enverus dataset
% - Filtered for basin of interest
M_in = M_all(Lia, :);

%% Import CSV data

filepath = fullfile(pwd, GHGRPfolder,'Facilities_2020.csv');
Facilities_dat = importdata(filepath);
Facilities_dat(isnan(Facilities_dat))=0;

filepath = fullfile(pwd, GHGRPfolder,'Equip_2020.csv');
Equip_dat = importdata(filepath);
Equip_dat.data(isnan(Equip_dat.data))=0;

filepath = fullfile(pwd, GHGRPfolder,'Tanks12_2020.csv');
Tanks12_dat = importdata(filepath);
Tanks12_dat(isnan(Tanks12_dat))=0;

filepath = fullfile(pwd, GHGRPfolder,'Tanks3_2020.csv');
Tanks3_dat = importdata(filepath);
Tanks3_dat(isnan(Tanks3_dat))=0;

filepath = fullfile(pwd, GHGRPfolder,'PC_2020.csv');
PC_dat = importdata(filepath);
PC_dat(isnan(PC_dat))=0;

filepath = fullfile(pwd, GHGRPfolder,'Pump_2020.csv');
Pump_dat = importdata(filepath);
Pump_dat(isnan(Pump_dat))=0;

% %% Process facility data
% 
% [Facility_ID_prod, ia, ic] = unique(Facility_dat(:,1));
% Facility_pivot_all = Facility_ID_prod;
% Facility_pivot_all(:,2) = accumarray(ic, Facility_dat(:,2), [], @sum); % mscf/year
% Facility_pivot_all(:,3) = accumarray(ic, Facility_dat(:,3), [], @sum); % bbl/year
% Facility_pivot_all(:,4) = accumarray(ic, Facility_dat(:,4), [], @sum); % # wells
% 
% M_raw = Facility_pivot_all;

%% Process equipment data

% In (Equip_id)
% (1) Compressors
% (2) Dehydrators
% (3) Header
% (4) Heater-treater
% (5) In-line heaters
% (6) Meters/piping
% (7) Separators
% (8) Wellheads

% Out:
% Col 1 = HEader per well
% Col 2 = Heater per well
% Col 3 = Separator per well
% Col 4 = Meter per well
% Col 7 = Recip compressor per well
% Col 8 = Dehydrators

% Gather cell array "Equip_id" of unique equipment names"
[Equip_id, ia, ic] = unique(Equip_dat.textdata(:,1));
Equip_dat.textdata = string(Equip_dat.textdata);

% ia: index vector. Number of rows = number of unique facilities. 
%       Facility_ID_prod_2 = Equip_data.data(ia)
% ic: index vector. Number of rows = number of rows in Equip_dat.data
%       Equip_dat.data = Facility_ID_prod_2(ic)
[Facility_ID_prod_2, ia, ic] = unique(Equip_dat.data(:,1));

logind(:,1) = (Equip_dat.textdata(:,1) == Equip_id{3});
logind(:,2) = (Equip_dat.textdata(:,1) == Equip_id(4) | Equip_dat.textdata(:,1) == Equip_id(5));
logind(:,3) = (Equip_dat.textdata(:,1) == Equip_id(7));
logind(:,4) = (Equip_dat.textdata(:,1) == Equip_id(6));
logind(:,7) = (Equip_dat.textdata(:,1) == Equip_id(1));
logind(:,8) = (Equip_dat.textdata(:,1) == Equip_id(2));
logind(:,9) = (Equip_dat.textdata(:,1) == Equip_id(8));

% Headers
Equip_data_header = Equip_dat.data;
Equip_data_header(:,2) = Equip_data_header(:,2).*logind(:,1);
col_1 = accumarray(ic,Equip_data_header(:,2),[],@sum);
% Heaters
Equip_data_heater = Equip_dat.data;
Equip_data_heater(:,2) = Equip_data_heater(:,2).*logind(:,2);
col_2 = accumarray(ic,Equip_data_heater(:,2),[],@sum);
% Separator
Equip_data_sep = Equip_dat.data;
Equip_data_sep(:,2) = Equip_data_sep(:,2).*logind(:,3);
col_3 = accumarray(ic,Equip_data_sep(:,2),[],@sum);
% MEter
Equip_data_meter = Equip_dat.data;
Equip_data_meter(:,2) = Equip_data_meter(:,2).*logind(:,4);
col_4 = accumarray(ic,Equip_data_meter(:,2),[],@sum);
% Reciprocating compressor
Equip_data_recip = Equip_dat.data;
Equip_data_recip(:,2) = Equip_data_recip(:,2).*logind(:,7);
col_7 = accumarray(ic,Equip_data_recip(:,2),[],@sum);
% Dehydrator
Equip_data_dehy = Equip_dat.data;
Equip_data_dehy(:,2) = Equip_data_dehy(:,2).*logind(:,8);
col_8 = accumarray(ic,Equip_data_dehy(:,2),[],@sum);
% Wellheads
Equip_data_wells = Equip_dat.data;
Equip_data_wells(:,2) = Equip_data_wells(:,2).*logind(:,9);
col_9 = accumarray(ic,Equip_data_wells(:,2),[],@sum);

Equip_data_all = [Facility_ID_prod_2 col_1 col_2 col_3 col_4 col_7 col_8 col_9];


% FACILITY DATA
[Facility_ID_prod_facilities, ia, ic] = unique(Facilities_dat(:,1));

Facilities_dat_consol(:,2) = accumarray(ic,Facilities_dat(:,3),[],@sum);
Facilities_dat_consol(:,3) = accumarray(ic,Facilities_dat(:,4),[],@mean);

Facilities_dat_consol(:,1) = Facility_ID_prod_facilities;

% TANKS12
[Facility_ID_prod_tanks, ia, ic] = unique(Tanks12_dat(:,1));

for i = 1:4
    tanks12_dat_consol(:,1+i) = accumarray(ic,Tanks12_dat(:,1+i),[],@sum);
end

tanks12_dat_consol(:,1) = Facility_ID_prod_tanks;

% TANKS3
[Facility_ID_prod_tanks3, ia, ic] = unique(Tanks3_dat(:,1));

for i = 1:4
    tanks3_dat_consol(:,1+i) = accumarray(ic,Tanks3_dat(:,1+i),[],@sum);
end

tanks3_dat_consol(:,1) = Facility_ID_prod_tanks3;

% PCs
[Facility_ID_prod_PC, ia, ic] = unique(PC_dat(:,1));

PC_dat_consol(:,2) = accumarray(ic,PC_dat(:,2),[],@sum);
PC_dat_consol(:,1) = Facility_ID_prod_PC;


% PUMPS
[Facility_ID_prod_pumps, ia, ic] = unique(Pump_dat(:,1));

pump_dat_consol(:,2) = accumarray(ic,Pump_dat(:,2),[],@sum);
pump_dat_consol(:,1) = Facility_ID_prod_pumps;


%% Matching with facility correspondence

[Lia, Loc_equip] = ismember(Equip_data_all(:,1),M_in(:,1));
wellcounts(1) = sum(Equip_data_all(Lia,8));

fprintf('Total GHGRP wells in EQUIP_LEAKS = %d... \n', sum(Equip_data_all(Lia,8))) 

[Lia, Loc_facilities] = ismember(Facilities_dat_consol(:,1),M_in(:,1));
wellcounts(2) = sum(Facilities_dat_consol(Lia,2));

fprintf('Total GHGRP wells in FACILITY_OVERVIEW = %d... \n', sum(Facilities_dat_consol(Lia,2))) 
fprintf('Total GHGRP wells in ONSHORE_WELLS = %d... \n', length(M_in(:,1))) 

% Lia = logical true or false
% Loc_equip = the lowest index in Equip_data for each value in A that is a member of B
[Lia, Loc_equip] = ismember(M_in(:,1),Equip_data_all(:,1));
[Lia, Loc_tanks12] = ismember(M_in(:,1),tanks12_dat_consol(:,1));
[Lia, Loc_tanks3] = ismember(M_in(:,1),tanks3_dat_consol(:,1));
[Lia, Loc_facilities] = ismember(M_in(:,1),Facilities_dat_consol(:,1));
[Lia, Loc_PC] = ismember(M_in(:,1),PC_dat_consol(:,1));
[Lia, Loc_pumps] = ismember(M_in(:,1),pump_dat_consol(:,1));

[size_mat,~] = size(M_in);
M_new = zeros(size_mat,18);
M_new(:,1:4) = M_in;
M_new(:,2:3) =  M_new(:,2:3)/365; 
%Locb = int64(Locb);

for i = 1:length(Loc_equip)
    if Loc_equip(i)>0
        M_new(i,5) = Equip_data_all(Loc_equip(i),8);
        M_new(i,7:10) = Equip_data_all(Loc_equip(i),2:5);
        M_new(i,13:14) = Equip_data_all(Loc_equip(i),6:7);        
    end
    if Loc_facilities(i)>0
        M_new(i,6) = Facilities_dat_consol(Loc_facilities(i),2);    
        M_new(i,20) = Facilities_dat_consol(Loc_facilities(i),3);
    end
    if Loc_tanks12(i)>0
        M_new(i,11) = tanks12_dat_consol(Loc_tanks12(i),5);
        M_new(i,12) = tanks12_dat_consol(Loc_tanks12(i),5);
        M_new(i,18) = sum(tanks12_dat_consol(Loc_tanks12(i),2:4));
        M_new(i,19) = sum(tanks12_dat_consol(Loc_tanks12(i),[2 4]));
    end  
    if Loc_tanks3(i)>0
        M_new(i,11) = M_new(i,11) + tanks3_dat_consol(Loc_tanks3(i),5);
        M_new(i,12) = M_new(i,12) + tanks3_dat_consol(Loc_tanks3(i),5);
        M_new(i,18) = M_new(i,18) + sum(tanks3_dat_consol(Loc_tanks3(i),2:4));
        M_new(i,19) = M_new(i,19) + sum(tanks3_dat_consol(Loc_tanks3(i),[2 4]));
    end   
    if Loc_PC(i)>0
        M_new(i,16) = PC_dat_consol(Loc_PC(i),2);
    end    
    if Loc_pumps(i)>0
        M_new(i,15) = pump_dat_consol(Loc_pumps(i),2);
    end    
end

M_new(:,[7,8,9,10,13,14]) = M_new(:,[7,8,9,10,13,14])./M_new(:,5);
M_new(:,[11,12,15,16]) = M_new(:,[11,12,15,16])./M_new(:,6);
M_new(:,19) = M_new(:,19)./M_new(:,18);


%% BINNING
        
%(i) Determine bin indices and bin means
    edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
    [counts, edges, ind] = histcounts(M_new(:,3), edges_set);
    
%(ii) Determine bin means
    bin_ave_gas = accumarray(ind, M_new(:,3),[],@mean);
    bin_sum_gas = accumarray(ind, M_new(:,3),[],@sum);
    bin_sum_oilwg = accumarray(ind, M_new(:,2),[],@sum);
    M_new(isnan(M_new(:,18)),18)=0;
    WeightedMeanFcn = @(x) sum(M_new(x,18).*M_new(x,2))/sum(M_new(x,2));
    bin_sum_oilthru = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    M_new(isnan(M_new(:,19)),19)=0;
    WeightedMeanFcn = @(x) sum(M_new(x,19).*M_new(x,2))/sum(M_new(x,2));
    bin_sum_oilcontrol = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    %bin_ave_AF = zeros(sum(counts>0),11);
    bin_ave_AF = zeros(find((counts>0),1,'last'),11);
    
    % Activity factors based on EQUIP_LEAKS table
    col_ind = [7,8,9,10,13,14];
    for i = 1:length(col_ind)
        M_new(isinf(M_new(:,col_ind(i))),col_ind(i))=0;
        M_new(isnan(M_new(:,col_ind(i))),col_ind(i))=0;
        WeightedMeanFcn = @(x) sum(M_new(x,col_ind(i)).*(M_new(x,5)./M_new(x,4)))/(sum(M_new(x,5)./M_new(x,4)));
        bin_ave_AF(:,col_ind(i)-6) = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    end

    % Activity factors based on FACILITY_OVERVIEW table
    col_ind = [11,12,15,16];
    for i = 1:length(col_ind)
        M_new(isinf(M_new(:,col_ind(i))),col_ind(i))=0;
        M_new(isnan(M_new(:,col_ind(i))),col_ind(i))=0;
        WeightedMeanFcn = @(x) sum(M_new(x,col_ind(i)).*(M_new(x,6)./M_new(x,4)))/(sum(M_new(x,6)./M_new(x,4)));
        bin_ave_AF(:,col_ind(i)-6) = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    end    
    
    % Ave CH4 mole frac
    WeightedMeanFcn = @(x) sum(M_new(x,20).*M_new(x,3))/sum(M_new(x,3));
    bin_ave_CH4 = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    
    bins_exp = zeros((length(edges_set)-1),17);
    
    bins_exp(1:length(counts'),1) = counts';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    
    bins_exp(1:find((counts>0),1,'last'),5:15) = bin_ave_AF;
    bins_exp(1:length(bin_sum_oilthru'),16) = bin_sum_oilthru';
    bins_exp(1:length(bin_sum_oilcontrol'),17) = bin_sum_oilcontrol';
    bins_exp(1:length(bin_sum_oilcontrol'),18) = bin_ave_CH4';
    
    GHGRP_exp = bins_exp;
  

end