function [OPGEE_bin] = GHGRP_read_v2(GHGRPfolder)


% Parameters for processing

cutoff = 100;% Mscf/bbl

%% Import CSV data

% Facility data - All columns have been deleted except for:
% (1) FACILITY_ID
% (2) GAS_PROD_CAL_YEAR_FROM_WELLS
% (3) OIL_PROD_CAL_YEAR_FOR_SALES
filepath = fullfile(pwd, GHGRPfolder,'RY2020_FACILITY_OVERVIEW.CSV');
Facility_dat = importdata(filepath);
Facility_dat(isnan(Facility_dat))=0;

Equip_dat = importdata('Equip_2015.csv');
Equip_dat.data(isnan(Equip_dat.data))=0;

Tanks12_dat = importdata('Tanks12_2015.csv');
Tanks12_dat(isnan(Tanks12_dat))=0;

Tanks3_dat = importdata('Tanks3_2015.csv');
Tanks3_dat(isnan(Tanks3_dat))=0;

PC_dat = importdata('PC_2015.csv');
PC_dat(isnan(PC_dat))=0;

Pump_dat = importdata('Pump_2015.csv');
Pump_dat(isnan(Pump_dat))=0;

cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\Flash_GHGRP_Test'
 

%% Process facility data

[Facility_ID_prod, ia, ic] = unique(Facility_dat(:,1));
Facility_pivot_all = Facility_ID_prod;
Facility_pivot_all(:,2) = accumarray(ic, Facility_dat(:,2), [], @sum); % mscf/year
Facility_pivot_all(:,3) = accumarray(ic, Facility_dat(:,3), [], @sum); % bbl/year
Facility_pivot_all(:,4) = accumarray(ic, Facility_dat(:,4), [], @sum); % # wells

M_raw = Facility_pivot_all;

%% Process equipment data

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

% EQUIPMENT - Perform lookup so that Facility ID's match those from Facility dataset
[Lia, Locb] = ismember(Facility_ID_prod_2,Facility_ID_prod);
temp = zeros(535,7);
for i = 1:length(Locb)
    temp(Locb(i),:) = Equip_data_all(i,2:8);
end

M_raw(:,5:10) = temp(:,1:6);
equip_count_2 = temp(:,7);

%% Process remaining equipment

% TANKS12 - Perform lookup so that Facility ID's match those from Facility dataset
[Facility_ID_prod_tanks, ia, ic] = unique(Tanks12_dat(:,1));

for i = 1:3
    tanks12_dat_consol(:,1+i) = accumarray(ic,Tanks12_dat(:,1+i),[],@sum);
end

tanks12_dat_consol(:,1) = Facility_ID_prod_tanks;

[Lia, Locb] = ismember(Facility_ID_prod_tanks,Facility_ID_prod);
temp = zeros(535,3);
for i = 1:length(Locb)
    temp(Locb(i),:) = tanks12_dat_consol(i,2:4);
end
M_raw(:,11:13) = temp;

% TANKS3 - Perform lookup so that Facility ID's match those from Facility dataset
[Facility_ID_prod_tanks3, ia, ic] = unique(Tanks3_dat(:,1));
[Lia, Locb] = ismember(Facility_ID_prod_tanks3,Facility_ID_prod);
temp = zeros(535,3);
for i = 1:length(Locb)
    temp(Locb(i),:) = Tanks3_dat(i,2:4);
end
M_raw(:,14:16) = temp;

% PCs - Perform lookup so that Facility ID's match those from Facility dataset
[Facility_ID_prod_PC, ia, ic] = unique(PC_dat(:,1));

PC_dat_consol(:,2) = accumarray(ic,PC_dat(:,2),[],@sum);
PC_dat_consol(:,1) = Facility_ID_prod_PC;

[Lia, Locb] = ismember(Facility_ID_prod_PC,Facility_ID_prod);
temp = zeros(535,1);
for i = 1:length(Locb)
    temp(Locb(i),:) = PC_dat_consol(i,2);
end
M_raw(:,17) = temp;


% PUMPS - Perform lookup so that Facility ID's match those from Facility dataset
[Facility_ID_prod_pumps, ia, ic] = unique(Pump_dat(:,1));

pump_dat_consol(:,2) = accumarray(ic,Pump_dat(:,2),[],@sum);
pump_dat_consol(:,1) = Facility_ID_prod_pumps;

[Lia, Locb] = ismember(Facility_ID_prod_pumps,Facility_ID_prod);
temp = zeros(535,1);
for i = 1:length(Locb)
    temp(Locb(i),:) = pump_dat_consol(i,2);
end
M_raw(:,18) = temp;

M_raw(:,19) = equip_count_2;

% MRAW
% Col 1 = FACILITY
% Col 2 = gas (Mscf/year)
% Col 3 = Oil (bbl/year)
% Col 4 = well count
% Col 5 = HEader 
% Col 6 = Heater
% Col 7 = Separator 
% Col 8 = Meter 
% Col 9 = Recip compressor 
% Col 10 = Dehydrators
% Col 11 = Tanks 12
% Col 12 = Tanks 12 - Oil throughput
% Col 13 = Tanks 12 - Oil throughput controlled
% Col 14 = Tanks 3
% Col 15 = Tanks 3 - Oil throughput
% Col 16 = Tanks 3 - Oil throughput controlled
% Col 17 = PCs
% Col 18 = Pumps
% Col 19 = Equip data wellhead count


% Produce a well-level dataset

[size_mat,~] = size(M_raw);
M_raw(:,4) = round(M_raw(:,4));
total_wells = sum(M_raw(:,4));
M_new = zeros(size_mat,4);


% M_NEW
% Col 1 = Oil (bbl/day)
% Col 2 = gas (Mscf/day)
% Col 3 = GOR (mscf/bbl)
% Col 4 = # wells
% Col 5 = HEader per well
% Col 6 = Heater per well
% Col 7 = Separator per well
% Col 8 = Meter per well
% Col 9 = Tanks per well (leaks)
% Col 10 = Tanks per well (hatch)
% Col 11 = Recip compressor per well
% Col 12 = Dehydrators
% Col 13 = inj pump per well
% Col 14 = PC per well
% Col 15 = flares per well
% Col 16 = oil throughput
% Col 17 = oil controlled

row = 1;
for i = 1:size_mat
    wells = M_raw(i,4);
    if wells == 1
        M_new(row,1) = M_raw(i,3)/365.25;
        M_new(row,2) = M_raw(i,2)/365.25;
        M_new(row,3) = 0;
        M_new(row,4) = 1;
        M_new(row,5) = M_raw(i,5);
        M_new(row,6) = M_raw(i,6);
        M_new(row,7) = M_raw(i,7);
        M_new(row,8) = M_raw(i,8);
        M_new(row,9) = M_raw(i,11) + M_raw(i,14); 
        M_new(row,10) = M_raw(i,11) + M_raw(i,14);
        M_new(row,11) = M_raw(i,9);
        M_new(row,12) = M_raw(i,10);
        M_new(row,13) = M_raw(i,18);
        M_new(row,14) = M_raw(i,17);
        M_new(row,15) = 0;
        M_new(row,16) = M_raw(i,12) + M_raw(i,15);
        M_new(row,17) = M_raw(i,13) + M_raw(i,16);
        
        row = row + 1;
    else
        for j = 1:wells
            prod.oil = M_raw(i,3)/wells/365.25; % Convert to bbl/day
            prod.gas = M_raw(i,2)/wells/365.25; % Convert to Mscf/day
            M_new(row,1) = prod.oil;
            M_new(row,2) = prod.gas;
            M_new(row,3) = 0;
            M_new(row,4) = 1;
            M_new(row,5) = M_raw(i,5)/wells;
            M_new(row,6) = M_raw(i,6)/wells;
            M_new(row,7) = M_raw(i,7)/wells;
            M_new(row,8) = M_raw(i,8)/wells;
            M_new(row,9) = (M_raw(i,11) + M_raw(i,14))/wells;
            M_new(row,10) = (M_raw(i,11) + M_raw(i,14))/wells;
            M_new(row,11) = M_raw(i,9)/wells;
            M_new(row,12) = M_raw(i,10)/wells;
            M_new(row,13) = M_raw(i,18)/wells;
            M_new(row,14) = M_raw(i,17)/wells;
            M_new(row,15) = 0;
            M_new(row,16) = M_raw(i,12) + M_raw(i,15);
            M_new(row,17) = M_raw(i,13) + M_raw(i,16);
            row = row + 1;
        end
    end

end

plot_dat = M_new(:,2);
[M_no_offshore,count,totalprod,averageprod] = data_class(M_new, cutoff);

data_tab = cell(3,4);

data_tab(1,2) = cellstr('# wells');
data_tab(1,3) = cellstr('Total oil (MMbbls)');
data_tab(1,4) = cellstr('Total gas (Bscf/yr)');
data_tab(2,1) = cellstr('Gas wells');
data_tab(2,2) = num2cell(count.gasall);           %# wells
data_tab(2,3) = num2cell(totalprod.gasall(1,1));  %Total oil (MMbbls)
data_tab(2,4) = num2cell(totalprod.gasall(1,2));  %Total gas (Bscf/yr)
data_tab(3,1) = cellstr('Oil wells');
data_tab(3,2) = num2cell(count.oilall);           %# wells
data_tab(3,3) = num2cell(totalprod.oilall(1,1));  %Total oil (MMbbls)
data_tab(3,4) = num2cell(totalprod.oilall(1,2));  %Total gas (Bscf/yr)        

cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\GHGRP_Analysis\Outputs'   

FileName = 'DI_summary.xlsx';

% xlswrite(FileName, data_tab)
cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\3_global gas\2_Analysis\4_NEW_Combined_OPGEE\GHGRP_Analysis'
 
%% BINNING - DRY GAS WELLS
        
%(i) Determine bin indices and bin means
    edges_gas_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
    [counts_gas, edges_gas, ind_gas] = histcounts(M_no_offshore.gasall(:,2), edges_gas_set);
    
%(ii) Determine bin means
    bin_ave_gas = accumarray(ind_gas, M_no_offshore.gasall(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_gas, M_no_offshore.gasall(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_gas, M_no_offshore.gasall(:,1),[],@sum);
    WeightedMeanFcn = @(x) sum(M_no_offshore.gasall(x,16).*M_no_offshore.gasall(x,1))/sum(M_no_offshore.gasall(x,1));
    bin_sum_oilthru = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
    WeightedMeanFcn = @(x) sum(M_no_offshore.gasall(x,17).*M_no_offshore.gasall(x,1))/sum(M_no_offshore.gasall(x,1));
    bin_sum_oilcontrol = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
    bin_ave_AF = zeros((length(edges_gas_set)-1),11);
    bin_ave_AF = zeros((length(edges_gas_set)-1),11);
    
    for i = 1:11
        WeightedMeanFcn = @(x) sum(M_no_offshore.gasall(x,i+4).*M_no_offshore.gasall(x,4))/sum(M_no_offshore.gasall(x,4));
        bin_ave_AF(:,i) = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
    end
    
    bins_exp = zeros((length(edges_gas_set)-1),17);
    
    bins_exp(1:length(counts_gas'),1) = counts_gas';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    
     bins_exp(:,5:15) = bin_ave_AF;
    bins_exp(1:length(bin_sum_oilthru'),16) = bin_sum_oilthru';
    bins_exp(1:length(bin_sum_oilcontrol'),17) = bin_sum_oilcontrol';

%     bins_exp(:,15) = frac_wells_flaring(:,1);
%     bins_exp(:,16) = bins_exp(:,18)./bins_exp(:,17);
    
    OPGEE_bin.gassall = bins_exp;
%(iii) Print outputs to a text file
    
%       csvwrite('EDF_gasdry_bins.csv',bins_exp)  


% %% BINNING - ASSOC GAS WELLS
%       
% %(i) Determine bin indices and bin means
%     edges_gas_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
%     [counts_gas, edges_gas, ind_gas] = histcounts(M_no_offshore.gaswoil(:,2), edges_gas_set);
%     
% %(ii) Determine bin means
%     bin_ave_gas = accumarray(ind_gas, M_no_offshore.gaswoil(:,2),[],@mean);
%     bin_sum_gas = accumarray(ind_gas, M_no_offshore.gaswoil(:,2),[],@sum);
%     bin_sum_oilwg = accumarray(ind_gas, M_no_offshore.gaswoil(:,1),[],@sum);
%     
%     WeightedMeanFcn = @(x) sum(M_no_offshore.gaswoil(x,16).*M_no_offshore.gaswoil(x,1))/sum(M_no_offshore.gaswoil(x,1));
%     bin_sum_oilthru = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
%     WeightedMeanFcn = @(x) sum(M_no_offshore.gaswoil(x,17).*M_no_offshore.gaswoil(x,1))/sum(M_no_offshore.gaswoil(x,1));
%     bin_sum_oilcontrol = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
%     bin_ave_AF = zeros((length(edges_gas_set)-1),11);
%     
%     for i = 1:11
%         WeightedMeanFcn = @(x) sum(M_no_offshore.gaswoil(x,i+4).*M_no_offshore.gaswoil(x,4))/sum(M_no_offshore.gaswoil(x,4));
%         bin_ave_AF(1:9,i) = accumarray(ind_gas, 1:numel(ind_gas),[],WeightedMeanFcn);
%     end
%     
%     bins_exp = zeros((length(edges_gas_set)-1),17);
%     
%     bins_exp(1:length(counts_gas'),1) = counts_gas';
%     bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
%     bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
%     bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
%     bins_exp(:,5:15) = bin_ave_AF;
% 
%     bins_exp(1:length(bin_sum_oilthru'),16) = bin_sum_oilthru';
%     bins_exp(1:length(bin_sum_oilcontrol'),17) = bin_sum_oilcontrol';
%     
% %     bins_exp(:,15) = frac_wells_flaring(:,2);
% %     bins_exp(:,16) = bins_exp(:,18)./bins_exp(:,17);
%     
% %(iii) Print outputs to a text file
%     
% %        csvwrite('EDF_gasassoc_bins.csv',bins_exp)  
%       OPGEE_bin.gasassoc = bins_exp;      
%% BINNING - OIL WELLS
        
%(ii) Determine bin indices and bin means

    edges_oil_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,1500000];
    [counts_oil, edges_oil, ind_oil] = histcounts(M_no_offshore.oilall(:,2), edges_oil_set);
    
% %(iii) Determine bin means

    bin_ave_gas = accumarray(ind_oil, M_no_offshore.oilall(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_oil, M_no_offshore.oilall(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_oil, M_no_offshore.oilall(:,1),[],@sum);
    
    WeightedMeanFcn = @(x) sum(M_no_offshore.oilall(x,16).*M_no_offshore.oilall(x,1))/sum(M_no_offshore.oilall(x,1));
    bin_sum_oilthru = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
    WeightedMeanFcn = @(x) sum(M_no_offshore.oilall(x,17).*M_no_offshore.oilall(x,1))/sum(M_no_offshore.oilall(x,1));
    bin_sum_oilcontrol = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
    bin_ave_AF = zeros((length(edges_oil_set)-1),11);
    
    for i = 1:11
        WeightedMeanFcn = @(x) sum(M_no_offshore.oilall(x,i+4).*M_no_offshore.oilall(x,4))/sum(M_no_offshore.oilall(x,4));
        bin_ave_AF(1:9,i) = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
    end
    
    bins_exp = zeros((length(edges_oil_set)-1),17);
    
    bins_exp(1:length(counts_oil'),1) = counts_oil';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    bins_exp(:,5:15) = bin_ave_AF;

    bins_exp(1:length(bin_sum_oilthru'),16) = bin_sum_oilthru';
    bins_exp(1:length(bin_sum_oilcontrol'),17) = bin_sum_oilcontrol';

%     bins_exp(:,15) = frac_wells_flaring(:,3);
%     bins_exp(:,16) = bins_exp(:,18)./bins_exp(:,17);
    
%(iii) Print outputs to a text file
    
%       csvwrite('EDF_oil_bins.csv',bins_exp)
      OPGEE_bin.oilall = bins_exp; 
% %% BINNING - WET WELLS
% 
% %(ii) Determine bin indices and bin means
% 
%     edges_oil_set = [0, 0.5, 1, 10,1500000];
%     [counts_oil, edges_oil, ind_oil] = histcounts(M_no_offshore.oil(:,2), edges_oil_set);
%     
% % %(iii) Determine bin means
% 
%     bin_ave_gas = accumarray(ind_oil, M_no_offshore.oil(:,2),[],@mean);
%     bin_sum_gas = accumarray(ind_oil, M_no_offshore.oil(:,2),[],@sum);
%     bin_sum_oilwg = accumarray(ind_oil, M_no_offshore.oil(:,1),[],@sum);
%     
%     WeightedMeanFcn = @(x) sum(M_no_offshore.oil(x,16).*M_no_offshore.oil(x,1))/sum(M_no_offshore.oil(x,1));    
%     bin_sum_oilthru = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
%     WeightedMeanFcn = @(x) sum(M_no_offshore.oil(x,17).*M_no_offshore.oil(x,1))/sum(M_no_offshore.oil(x,1));
%     bin_sum_oilcontrol = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
%     bin_ave_AF = zeros((length(edges_oil_set)-1),11);
%     
%     for i = 1:11
%         WeightedMeanFcn = @(x) sum(M_no_offshore.oil(x,i+4).*M_no_offshore.oil(x,4))/sum(M_no_offshore.oil(x,4));
%         bin_ave_AF(:,i) = accumarray(ind_oil, 1:numel(ind_oil),[],WeightedMeanFcn);
%     end
%     
%     bins_exp = zeros((length(edges_oil_set)-1),17);
%     
%     bins_exp(1:length(counts_oil'),1) = counts_oil';
%     bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
%     bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
%     bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
%     bins_exp(:,5:15) = bin_ave_AF;
%     
%     bins_exp(1:length(bin_sum_oilthru'),16) = bin_sum_oilthru';
%     bins_exp(1:length(bin_sum_oilcontrol'),17) = bin_sum_oilcontrol';
% 
% %     bins_exp(:,15) = frac_wells_flaring(1:4,4);
% %     bins_exp(:,16) = bins_exp(:,18)./bins_exp(:,17);
%     
% %(iii) Print outputs to a text file
%     
% %        csvwrite('EDF_oilwet_bins.csv',bins_exp)
%       OPGEE_bin.oil = bins_exp; 

end

