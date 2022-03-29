function [flare_tab] = flaring_tranche(Basin_Select, Basin_Index, Basin_N, OPGEE_bin)

%% How many flare stacks are there?

flare_data = importdata('GAS_TO_FLARE.csv');


% n_stacks.Gas = 282;
% n_stacks.Oil = 10460;
% n_stacks.Total = n_stacks.Gas + n_stacks.Oil;

extrap_factor = (388/265); 

%Ratio of VIIRS estimate for 2020 over EPA estimate for 2020
% See World Bank Global Gas Flaring Tracker Report

% Separate into oil categories and gas categories
%***

logind = ismember(flare_data.data(:,1), Basin_N(Basin_Select));
ind = logind;
ind = int16(ind);
GAS_SENT.All = flare_data.data(ind == 1,2);
CH4_Frac.All = flare_data.data(ind == 1,3);
Oilgas = flare_data.textdata(ind == 1,:);

% CH4_TO_FLARE.All = GAS_SENT.All .* CH4_Frac.All;

GAS_SENT.Gas = GAS_SENT.All(find(ismember(Oilgas,'Gas')));
% CH4_TO_FLARE.Gas = GAS_SENT.Gas;
% CH4_TO_FLARE.Gas = CH4_TO_FLARE.Gas(isfinite(CH4_TO_FLARE.Gas));
% CH4_TO_FLARE.Gas = CH4_TO_FLARE.Gas * 0.683;
% 
% CH4_TO_FLARE.Gas = CH4_TO_FLARE.Gas * 19.29 * 0.001 * (1/365); % units of kg CH4/d

GAS_SENT.Oil = GAS_SENT.All(find(ismember(Oilgas,'Oil')));
% CH4_TO_FLARE.Oil = GAS_SENT.Oil;
% CH4_TO_FLARE.Oil = CH4_TO_FLARE.Oil(isfinite(CH4_TO_FLARE.Oil));
% CH4_TO_FLARE.Oil = CH4_TO_FLARE.Oil * 0.832;
% CH4_TO_FLARE.Oil = CH4_TO_FLARE.Oil * 19.29 * 0.001 * (1/365); % units of kg CH4/d
% 
% CH4_TO_FLARE.Total = [CH4_TO_FLARE.Gas; CH4_TO_FLARE.Oil];

GAS_SENT.Gas = GAS_SENT.Gas * (1/365) * (1/1000); % units of Mscf/d
GAS_SENT.Oil = GAS_SENT.Oil * (1/365) * (1/1000); % units of Mscf/d

GAS_SENT.Total = [GAS_SENT.Gas; GAS_SENT.Oil];


%% Tranche organization
% Extrapolate gas sent to flare

% Gas wells

[n,m] = size(GAS_SENT.Gas);
n_stacks.Gas = n * extrap_factor;
n_stacks.Gas = round(n_stacks.Gas);
excess = n_stacks.Gas - n;
newvec = randsample(GAS_SENT.Gas,excess,true);

GAS_SENT_TO_FLARE_EXT = vertcat(GAS_SENT.Gas, newvec);

%(i) Determine bin indices and bin means
edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,1000000000];
[counts_gas, edges_gas, ind_gas] = histcounts(GAS_SENT_TO_FLARE_EXT, edges_set);

%(ii) Determine bin means
bin_ave_gas = accumarray(ind_gas, GAS_SENT_TO_FLARE_EXT,[],@mean);
bin_sum_gas = accumarray(ind_gas, GAS_SENT_TO_FLARE_EXT,[],@sum);

bins_exp.Gas = zeros((length(edges_set)-1),3);

bins_exp.Gas(1:length(counts_gas'),1) = counts_gas';
bins_exp.Gas(1:length(bin_ave_gas'),2) = bin_ave_gas;
bins_exp.Gas(1:length(bin_sum_gas'),3) = bin_sum_gas;

flare_tab.gasdry(:,1) = OPGEE_bin.gasdry(:,1)./(OPGEE_bin.gasdry(:,1) + OPGEE_bin.gasassoc(:,1));
flare_tab.gasdry(:,2) = OPGEE_bin.gasdry(:,1);
flare_tab.gasdry(:,3) = bins_exp.Gas(:,1) .* flare_tab.gasdry(:,1);
flare_tab.gasdry(:,4) = flare_tab.gasdry(:,3) ./ flare_tab.gasdry(:,2);
flare_tab.gasdry(flare_tab.gasdry(:,4) > 1,4) = 1;
flare_tab.gasdry(isnan(flare_tab.gasdry(:,4)),4) = 0;

flare_tab.gasassoc(:,1) = OPGEE_bin.gasassoc(:,1)./(OPGEE_bin.gasdry(:,1) + OPGEE_bin.gasassoc(:,1));
flare_tab.gasassoc(:,2) = OPGEE_bin.gasassoc(:,1);
flare_tab.gasassoc(:,3) = bins_exp.Gas(:,1) .* flare_tab.gasassoc(:,1);
flare_tab.gasassoc(:,4) = flare_tab.gasassoc(:,3) ./ flare_tab.gasassoc(:,2);
flare_tab.gasassoc(isnan(flare_tab.gasassoc(:,4)),4) = 0;

% OIl wells

[n,m] = size(GAS_SENT.Oil);
n_stacks.Oil = n * extrap_factor;
n_stacks.Oil = round(n_stacks.Oil);

GAS_SENT_TO_FLARE_EXT = vertcat(GAS_SENT.Oil, newvec);

%(i) Determine bin indices and bin means
edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,1000000000];
[counts_gas, edges_gas, ind_gas] = histcounts(GAS_SENT_TO_FLARE_EXT, edges_set);

%(ii) Determine bin means
bin_ave_gas = zeros((length(edges_set)-1),1);
bin_sum_gas = zeros((length(edges_set)-1),1);
bin_ave_gas = accumarray(ind_gas, GAS_SENT_TO_FLARE_EXT,[],@mean);
bin_sum_gas = accumarray(ind_gas, GAS_SENT_TO_FLARE_EXT,[],@sum);

bins_exp.Oil = zeros((length(edges_set)-1),3);

bins_exp.Oil(1:length(counts_gas'),1) = counts_gas';
bins_exp.Oil(1:length(bin_ave_gas'),2) = bin_ave_gas;
bins_exp.Oil(1:length(bin_sum_gas'),3) = bin_sum_gas;

flare_tab.oilwgas(1,1) = OPGEE_bin.oilwgas(1,1)./(OPGEE_bin.oilwgas(1,1) + OPGEE_bin.oil(1,1) + OPGEE_bin.oil(2,1));
flare_tab.oilwgas(2,1) = OPGEE_bin.oilwgas(2,1)./(OPGEE_bin.oilwgas(2,1) + OPGEE_bin.oilwgas(3,1) + OPGEE_bin.oil(3,1));
flare_tab.oilwgas(3,1) = OPGEE_bin.oilwgas(3,1)./(OPGEE_bin.oilwgas(2,1) + OPGEE_bin.oilwgas(3,1) + OPGEE_bin.oil(3,1));
flare_tab.oilwgas(4,1) = OPGEE_bin.oilwgas(4,1)./(OPGEE_bin.oilwgas(4,1) + OPGEE_bin.oil(4,1));
flare_tab.oilwgas(5:10,1) = 1;
flare_tab.oilwgas(:,2) = OPGEE_bin.oilwgas(:,1);
flare_tab.oilwgas(:,3) = bins_exp.Oil(:,1) .* flare_tab.oilwgas(:,1);
flare_tab.oilwgas(:,4) = flare_tab.oilwgas(:,3) ./ flare_tab.oilwgas(:,2);
flare_tab.oilwgas(isnan(flare_tab.oilwgas(:,4)),4) = 0;

flare_tab.oil(1,1) = OPGEE_bin.oil(1,1)./(OPGEE_bin.oilwgas(1,1) + OPGEE_bin.oil(1,1) + OPGEE_bin.oil(2,1));
flare_tab.oil(2,1) = OPGEE_bin.oil(2,1)./(OPGEE_bin.oilwgas(1,1) + OPGEE_bin.oil(1,1) + OPGEE_bin.oil(2,1));
flare_tab.oil(3,1) = OPGEE_bin.oil(3,1)./(OPGEE_bin.oilwgas(2,1) + OPGEE_bin.oilwgas(3,1) + OPGEE_bin.oil(3,1));
flare_tab.oil(4,1) = OPGEE_bin.oil(4,1)./(OPGEE_bin.oilwgas(4,1) + OPGEE_bin.oil(4,1));
flare_tab.oil(:,2) = OPGEE_bin.oil(:,1);
flare_tab.oil(:,3) = bins_exp.Oil(1:4,1) .* flare_tab.oil(1:4,1);
flare_tab.oil(:,4) = flare_tab.oil(:,3) ./ flare_tab.oil(:,2);
flare_tab.oil(isnan(flare_tab.oil(:,4)),4) = 0;

end

