function [plot_dat, OPGEE_bin] = di_scrubbing_func(M_raw, Basin_Select, Basin_Index, activityfolder)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function was adjusted based on the code "di_scrubbing_alldata.m"
%   C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\manuscripts\2_BU_paper\3_Analysis\4_OPGEE_Modelling\a_Scenario_Generation\5b_DI Processing\REVISED GITHUB
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters for processing

    cutoff = 100;% Mscf/bbl

% Data is organized as follows, for BOTH basin level data and the 2015 US-level data from David lyon:

% Col 1 = oil (bbl/year)
% Col 2 = gas (Mscf/year)
% Col 3 = well count (in TX, a row is a lease with multiple wells, source =
% David Lyons)

%% Array Transformation

% First transform the array so that each row corresponds to a well

[size_mat,~] = size(M_raw);
M_raw(:,3) = round(M_raw(:,3));
total_wells = sum(M_raw(:,3));
M_new = zeros(total_wells,4);


row = 1;
for i = 1:size_mat
    wells = M_raw(i,3);
    if wells == 1
        M_new(row,1) = M_raw(i,1)/365.25;
        M_new(row,2) = M_raw(i,2)/365.25;
        row = row + 1;
    else
        for j = 1:wells
            prod.oil = M_raw(i,1)/wells/365.25; % Convert to bbl/day
            prod.gas = M_raw(i,2)/wells/365.25; % Convert to Mscf/day
            M_new(row,1) = prod.oil;
            M_new(row,2) = prod.gas;
            row = row + 1;
        end
    end

end

plot_dat = M_new(:,2);
[M_no_offshore,count,totalprod,averageprod] = data_class(M_new(:,1:2), cutoff, activityfolder);

%     %   PRINT OUTPUTS FROM THIS SECTION
%     
%         % Header
%         fprintf(1,'        # wells     Total oil (MMbbls)     Total gas (Bscf/yr)     Average oil (bbl/day well)     Average gas (Mscf/day well)\n');
%         % Data
%         fprintf(1,'G only  %0.0f        0                 %0.0f             0                           %4.2f\n' ,count.drygas,totalprod.drygas(1,2),averageprod.drygas(1,2));
%         fprintf(1,'G w oil %0.0f        %0.0f             %0.0f             %4.2f                       %4.2f\n' ,count.gaswoil,totalprod.gaswoil(1,1),totalprod.gaswoil(1,2),averageprod.gaswoil(1,1),averageprod.gaswoil(1,2));
%         fprintf(1,'O only  %0.0f        %0.0f             0                 %4.2f                       0\n'     ,count.oil,totalprod.oil(1,1),averageprod.oil(1,1));
%         fprintf(1,'O w gas %0.0f        %0.0f             %0.0f             %4.2f                       %4.2f\n' ,count.oilwgas,totalprod.oilwgas(1,1),totalprod.oilwgas(1,2),averageprod.oilwgas(1,1),averageprod.oilwgas(1,2));
%         fprintf(1,'G total %0.0f        %0.0f             %0.0f             %4.2f                       %4.2f\n' ,count.gasall,totalprod.gasall(1,1),totalprod.gasall(1,2),averageprod.gasall(1,1),averageprod.gasall(1,2));   
%         fprintf(1,'O only+ %0.0f        %0.0f             %0.0f             %4.2f                       %4.2f\n' ,count.oil,totalprod.oil(1,1),totalprod.oil(1,2),averageprod.oil(1,1),averageprod.oil(1,2));
%         fprintf(1,'O total %0.0f        %0.0f             %0.0f             %4.2f                       %4.2f\n' ,count.oilall,totalprod.oilall(1,1),totalprod.oilall(1,2),averageprod.oilall(1,1),averageprod.oilall(1,2));

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

%cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\Outputs'   
if Basin_Select == 0
    FileName = 'DI_summary_US.xlsx';
else
    FileName = ['DI_summary_' Basin_Index{Basin_Select} 'out.xlsx'];
    filepath = fullfile(pwd, 'Outputs/',FileName);
end
xlswrite(filepath, data_tab)
%cd 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 2\'
 
%% BINNING - DRY GAS WELLS
        
%(i) Determine bin indices and bin means
    edges_gas_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
    [counts_gas, edges_gas, ind_gas] = histcounts(M_no_offshore.drygas(:,2), edges_gas_set);
    
%(ii) Determine bin means
    bin_ave_gas = accumarray(ind_gas, M_no_offshore.drygas(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_gas, M_no_offshore.drygas(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_gas, M_no_offshore.drygas(:,1),[],@sum);

    bins_exp = zeros((length(edges_gas_set)-1),4);
    
    bins_exp(1:length(counts_gas'),1) = counts_gas';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    OPGEE_bin.gasdry = bins_exp;
%(iii) Print outputs to a text file
    
%       csvwrite(char(strcat(Basin_Index(1),'_gasdry_bins.csv')),bins_exp)  


%% BINNING - ASSOC GAS WELLS
      
%(i) Determine bin indices and bin means
    edges_gas_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,500000000];
    [counts_gas, edges_gas, ind_gas] = histcounts(M_no_offshore.gaswoil(:,2), edges_gas_set);
    
%(ii) Determine bin means
    bin_ave_gas = accumarray(ind_gas, M_no_offshore.gaswoil(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_gas, M_no_offshore.gaswoil(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_gas, M_no_offshore.gaswoil(:,1),[],@sum);

    bins_exp = zeros((length(edges_gas_set)-1),4);
    
    bins_exp(1:length(counts_gas'),1) = counts_gas';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    
%(iii) Print outputs to a text file
    
%       csvwrite(char(strcat(Basin_Index(1),'_gasassoc_bins.csv')),bins_exp)  
      OPGEE_bin.gasassoc = bins_exp;      
%% BINNING - OIL WELLS
        
%(ii) Determine bin indices and bin means

    edges_oil_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000,1500000];
    [counts_oil, edges_oil, ind_oil] = histcounts(M_no_offshore.oilwgas(:,2), edges_oil_set);
    
% %(iii) Determine bin means

    bin_ave_gas = accumarray(ind_oil, M_no_offshore.oilwgas(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_oil, M_no_offshore.oilwgas(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_oil, M_no_offshore.oilwgas(:,1),[],@sum);

    bins_exp = zeros((length(edges_oil_set)-1),4);
    
    bins_exp(1:length(counts_oil'),1) = counts_oil';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    
%(iii) Print outputs to a text file
    
%       csvwrite(char(strcat(Basin_Index(1),'_oil_bins.csv')),bins_exp)
      OPGEE_bin.oilwgas = bins_exp; 
%% BINNING - WET WELLS

%(ii) Determine bin indices and bin means

    edges_oil_set = [0, 0.5, 1, 10,1500000];
    [counts_oil, edges_oil, ind_oil] = histcounts(M_no_offshore.oil(:,2), edges_oil_set);
    
% %(iii) Determine bin means

    bin_ave_gas = accumarray(ind_oil, M_no_offshore.oil(:,2),[],@mean);
    bin_sum_gas = accumarray(ind_oil, M_no_offshore.oil(:,2),[],@sum);
    bin_sum_oilwg = accumarray(ind_oil, M_no_offshore.oil(:,1),[],@sum);

    bins_exp = zeros((length(edges_oil_set)-1),4);
    
    bins_exp(1:length(counts_oil'),1) = counts_oil';
    bins_exp(1:length(bin_ave_gas'),2) = bin_ave_gas';
    bins_exp(1:length(bin_sum_gas'),3) = bin_sum_gas';
    bins_exp(1:length(bin_sum_oilwg'),4) = bin_sum_oilwg';
    
%(iii) Print outputs to a text file
    
%       csvwrite(char(strcat(Basin_Index(1),'_oilwet_bins.csv')),bins_exp)
      OPGEE_bin.oil = bins_exp; 
end

     
