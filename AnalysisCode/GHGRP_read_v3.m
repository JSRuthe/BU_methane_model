function [OPGEE_bin, wellcounts] = GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder)


 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  
 %
 % All equipment counts in this export are per well reported by GHGRP.
 % All outputs are binned into gas production tranches
 % All bin averages are a weighted average (according to well counts, either 
 %the well count reported
 % on the equiipment leak sheet or in the facilities sheet
 % 
 % Bins export:
 % (1)  GHGRP Well count
 % (2)  GHGRP Mean Gas
 % (3)  GHGRP Total Gas
 % (4)  GHGRP Total Oil
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
 % (15) 
 % (16) Total oil throughput
 % (17) Oil controls 
 % (18) Average methane content 
 % 
 %% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


% Parameters for processing

cutoff = 100;% Mscf/bbl

%% Import CSV data

% Facility data: 
%  - Filtered for onshore natural gas and oil production segment
% - Columsn remaining
%     (i) Faility
%    (ii) Basin ID
%   (iii) producing wells
%    (iv) CH4 mole fraction
%
% Equipment data:
%  - Filtered for onshore natural gas and oil production segment
%  - columns remaining
% 	  (i) Faility
% 	 (ii) Equipmenct type
% 	(iii) Equipment count
% 	(iv) Basin ID
%  - Replace #VALUE!, #REF, #NA with ""
%  - Replace 160A with 160
% 
% Tanks12
%  - Filtered for onshore natural gas and oil production segment
% 	(i) Facility
% 	(ii) Qvent
% 	(iii) Qflare
% 	(iv) QVRU
% 	(v) Tank count
% 	(vi) Basin ID
%  - Replace #VALUE!, #REF, #NA with ""
%  - Replace 160A with 160
% 
% Tanks3
%  - Filtered for onshore natural gas and oil production segment
% 	(i) Facility
% 	(ii) Qvru
% 	(iii) Qvent
% 	(iv) Qflare
% 	(v) Tank count
% 	(vi) Basin ID
%  - Replace #VALUE!, #REF, #NA with ""
%  - Replace 160A with 160
% 
% PC
%  - Filtered for onshore natural gas and oil production segment
% 	  (i) Facility
% 	 (ii) Equipment count
% 	(iii) Basin ID
%  - Replace #VALUE!, #REF, #NA with ""
%  - Replace 160A with 160
% 
% Pump
%  - Filtered for onshore natural gas and oil production segment
% 	  (i) Facility
% 	 (ii) Equipment count
% 	(iii) Basin ID
%  - Replace #VALUE!, #REF, #NA with ""
%  - Replace 160A with 160

% Facility correspondence table
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
% Well_Count = ones(numel(Basin_Name),1);
% basin_ind = ismember(Basin_Name, Basin_N(i));
M_all = [Facility_No, Oil_Production, Gas_Production];
% ind = basin_ind;
% ind = int16(ind);
% M_in = M_all(ind == 1,:);
    
%%

% FAcility basin correspondence was created from
% "Equipment_Counts_v9_RY2020_Distributions.xlsx"
% Facility_ID and Basin copied from tab "RY_2020+FACILITY_OVERVIEW"
% Sorted for Onshore petroleum and natural gas production
% Removed duplicates

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


[Lia, Loc_facilities] = ismember(M_all(:,1),facility_basin.FACILITY_ID);
M_in = M_all(Lia, :);

%%


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

[Equip_id, ia, ic] = unique(Equip_dat.textdata(:,1));
Equip_dat.textdata = string(Equip_dat.textdata);
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


%% FACILITY DATA
[Facility_ID_prod_facilities, ia, ic] = unique(Facilities_dat(:,1));

Facilities_dat_consol(:,2) = accumarray(ic,Facilities_dat(:,3),[],@sum);
Facilities_dat_consol(:,3) = accumarray(ic,Facilities_dat(:,4),[],@mean);

Facilities_dat_consol(:,1) = Facility_ID_prod_facilities;

%% TANKS12
[Facility_ID_prod_tanks, ia, ic] = unique(Tanks12_dat(:,1));

for i = 1:4
    tanks12_dat_consol(:,1+i) = accumarray(ic,Tanks12_dat(:,1+i),[],@sum);
end

tanks12_dat_consol(:,1) = Facility_ID_prod_tanks;

%% TANKS3
[Facility_ID_prod_tanks3, ia, ic] = unique(Tanks3_dat(:,1));

for i = 1:4
    tanks3_dat_consol(:,1+i) = accumarray(ic,Tanks3_dat(:,1+i),[],@sum);
end

tanks3_dat_consol(:,1) = Facility_ID_prod_tanks3;

%% PCs
[Facility_ID_prod_PC, ia, ic] = unique(PC_dat(:,1));

PC_dat_consol(:,2) = accumarray(ic,PC_dat(:,2),[],@sum);
PC_dat_consol(:,1) = Facility_ID_prod_PC;


%% PUMPS
[Facility_ID_prod_pumps, ia, ic] = unique(Pump_dat(:,1));

pump_dat_consol(:,2) = accumarray(ic,Pump_dat(:,2),[],@sum);
pump_dat_consol(:,1) = Facility_ID_prod_pumps;


%% Matching with facility correspondence

if i == 1
   fprintf('Total GHGRP wells in EQUIP_LEAKS = %d... \n', sum(Equip_data_all(:,8))) 
end

if i == 1
   fprintf('Total GHGRP wells in FACILITY_OVERVIEW = %d... \n', sum(Facilities_dat_consol(:,2))) 
end

[Lia, Loc_equip] = ismember(Equip_data_all(:,1),M_in(:,1));
wellcounts(1) = sum(Equip_data_all(Lia,8));

[Lia, Loc_facilities] = ismember(Facilities_dat_consol(:,1),M_in(:,1));
wellcounts(2) = sum(Facilities_dat_consol(Lia,2));

[Lia, Loc_equip] = ismember(M_in(:,1),Equip_data_all(:,1));
[Lia, Loc_tanks12] = ismember(M_in(:,1),tanks12_dat_consol(:,1));
[Lia, Loc_tanks3] = ismember(M_in(:,1),tanks3_dat_consol(:,1));
[Lia, Loc_facilities] = ismember(M_in(:,1),Facilities_dat_consol(:,1));
[Lia, Loc_PC] = ismember(M_in(:,1),PC_dat_consol(:,1));
[Lia, Loc_pumps] = ismember(M_in(:,1),pump_dat_consol(:,1));

% [Lia, Loc_tanks12] = ismember(M_in(:,1),tanks12_dat_consol(:,1));
% [Lia, Loc_tanks12] = ismember(tanks12_dat_consol(:,1),M_in(:,1));

% % M_NEW
% % Col 1 = FACILITY ID
% % Col 2 = Oil (bbl/day)
% % Col 3 = gas (Mscf/day)
% % Col 4 = # wells (equip_leaks)
% % Col 5 = # wells (facility counts)
% % Col 6 = HEader per well x
% % Col 7 = Heater per well x
% % Col 8 = Separator per well x
% % Col 9 = Meter per well
% % Col 10 = Tanks per well (leaks)
% % Col 11 = Tanks per well (hatch)
% % Col 12 = Recip compressor per well
% % Col 13 = Dehydrators
% % Col 14 = inj pump per well
% % Col 15 = PC per well
% % Col 16 = flares per well
% % Col 17 = oil throughput
% % Col 18 = oil controlled
% % Col 19 = CH4 mole fraction
[size_mat,~] = size(M_in);
M_new = zeros(size_mat,18);
M_new(:,1:3) = M_in;
M_new(:,2:3) =  M_new(:,2:3)/365; 
%Locb = int64(Locb);

for i = 1:length(Loc_equip)
    if Loc_equip(i)>0
        M_new(i,4) = Equip_data_all(Loc_equip(i),8);
        M_new(i,6:9) = Equip_data_all(Loc_equip(i),2:5);
        M_new(i,12:13) = Equip_data_all(Loc_equip(i),6:7);        
    end
    if Loc_facilities(i)>0
        M_new(i,5) = Facilities_dat_consol(Loc_facilities(i),2);    
        M_new(i,19) = Facilities_dat_consol(Loc_facilities(i),3);
    end
    if Loc_tanks12(i)>0
        M_new(i,10) = tanks12_dat_consol(Loc_tanks12(i),5);
        M_new(i,11) = tanks12_dat_consol(Loc_tanks12(i),5);
        M_new(i,17) = sum(tanks12_dat_consol(Loc_tanks12(i),2:4));
        M_new(i,18) = sum(tanks12_dat_consol(Loc_tanks12(i),[2 4]));
    end  
    if Loc_tanks3(i)>0
        M_new(i,10) = M_new(i,10) + tanks3_dat_consol(Loc_tanks3(i),5);
        M_new(i,11) = M_new(i,11) + tanks3_dat_consol(Loc_tanks3(i),5);
        M_new(i,17) = M_new(i,17) + sum(tanks3_dat_consol(Loc_tanks3(i),2:4));
        M_new(i,18) = M_new(i,18) + sum(tanks3_dat_consol(Loc_tanks3(i),[2 4]));
    end   
    if Loc_PC(i)>0
        M_new(i,15) = PC_dat_consol(Loc_PC(i),2);
    end    
    if Loc_pumps(i)>0
        M_new(i,14) = pump_dat_consol(Loc_pumps(i),2);
    end    
end

M_new(:,[6,7,8,9,12,13]) = M_new(:,[6,7,8,9,12,13])./M_new(:,4);
M_new(:,[10,11,14,15]) = M_new(:,[10,11,14,15])./M_new(:,5);
M_new(:,18) = M_new(:,18)./M_new(:,17);


%% BINNING
        
%(i) Determine bin indices and bin means
    edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
    [counts, edges, ind] = histcounts(M_new(:,3), edges_set);
    
%(ii) Determine bin means
    bin_ave_gas = accumarray(ind, M_new(:,3),[],@mean);
    bin_sum_gas = accumarray(ind, M_new(:,3),[],@sum);
    bin_sum_oilwg = accumarray(ind, M_new(:,2),[],@sum);
    M_new(isnan(M_new(:,17)),17)=0;
    WeightedMeanFcn = @(x) sum(M_new(x,17).*M_new(x,2))/sum(M_new(x,2));
    bin_sum_oilthru = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    M_new(isnan(M_new(:,18)),18)=0;
    WeightedMeanFcn = @(x) sum(M_new(x,18).*M_new(x,2))/sum(M_new(x,2));
    bin_sum_oilcontrol = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    %bin_ave_AF = zeros(sum(counts>0),11);
    bin_ave_AF = zeros(find((counts>0),1,'last'),11);
    
    for i = 1:10
        M_new(isinf(M_new(:,i+5)),i+5)=0;
        M_new(isnan(M_new(:,i+5)),i+5)=0;
        WeightedMeanFcn = @(x) sum(M_new(x,i+5).*M_new(x,4))/sum(M_new(x,4));
        bin_ave_AF(:,i) = accumarray(ind, 1:numel(ind),[],WeightedMeanFcn);
    end
    
    % Ave CH4 mole frac
    WeightedMeanFcn = @(x) sum(M_new(x,19).*M_new(x,3))/sum(M_new(x,3));
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
    
    OPGEE_bin = bins_exp;
  
    % Bins export:
    % 
    

end

