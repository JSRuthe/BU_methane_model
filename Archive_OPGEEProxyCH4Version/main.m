%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created December 2, 2021
% 
% This script combines several functions
%   (1) tranche_gen_func.m : This script loads DrillingInfo data and
%   creates input tranches for the methane model
%   (2) autorun_func : This is the main function for the methane model    
%   which accepts oil and gas production tranches as well as key production
%   descriptors
%   (3) data_proc_master_func : This is the main plotting script. This also
%   generates the requisite outputs for generating the main leaking
%   matrices for the new version of OPGEE
%   (4) ____________________ : This script generates the leakage tables for
%   OPGEE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clean up workspace
clear; clc; close all;

%% Data inputs

root_path = 'C:\Users\jruthe\Dropbox\Doctoral\Projects\Research Projects\OPGEE\0_OPGEE_Matlab\Version 3';

% n_trial: number of Monte Carlo iterations for autorun

% for i = 1:13


    Basin_Select = 0;

    Basin_Index = {                 % (0) - If you wish to run all basins (select to replicate tranches for Rutherford et al 2021
        'PERMIAN',...               % (1) 
        'WESTERN GULF',...          % (2) 
        'TX-LA-MS SALT',...         % (3) 
        'FORT WORTH',...            % (4)
        'ANADARKO',...              % (5)    
        'DENVER',...                % (6) 
        'UINTA-PICEANCE',...        % (7)
        'GREATER GREEN RIVER',...   % (8)
        'SAN JOAQUIN BASIN',...     % (9)
        'APPALACHIAN',...           % (10)
        'ARKOMA',...                % (11)
        'WILLISTON',...             % (12)
        'POWDER RIVER'};            % (13)

% In this modified version for CARB just load the Activity factors from a
% CSV file

Activity_tranches = importdata('Activity.csv');
%     [Activity_tranches] = tranche_gen_func(Basin_Select, Basin_Index);
%     Activity_tranches = Activity_tranches';


% Import main activity factors and then multiply by sampling_AF for each
% LHS run

    %WL    HD          HE      SE      ME          TAL         TAV
    AF_base.Gas = [1;    0;          0.1321; 0.7102; 0.8399;     0.40570;    0.40570;...
        
    %  CR      DE          CIP         PC
    0.0814; 0.02987;    0.2023;     1.8743];

    AF_base.Oil = [1;    0.2234;     0.1859; 0.3689; 0;          0.815404;   0.815404;...

    0;      0;          0.08612;    1.1051];


%% Base run

n_trial = 25;

AF.Gas = AF_base.Gas;
AF.Oil = AF_base.Oil;

autorun_func(n_trial, root_path, Activity_tranches, AF, Basin_Select, Basin_Index);
equipdata_tot = data_proc_master_func(n_trial, root_path, Basin_Select, Basin_Index);
% equipdata_tot = datasample(equipdata_tot,10000);

% Sampling not necessary since a 10000 data point sample eis already done
% in the "func_loss_frac_v5" script

% set 22 compares the best with paper results

set_apply = 22;

% Mat_base.Gas = func_loss_frac_allcolumns(equipdata_tot, 1, set_apply);
Mat_base.Oil = func_loss_frac_allcolumns(equipdata_tot, 2, set_apply);

save('Mat_base_22.1.11.mat','Mat_base');

%% LATIN HYPERCUBE SAMPLING

n_lhs = 10000;

sampling_AF.gas = lhsdesign(n_lhs,10);
sampling_AF.oil = sampling_AF.gas;

sampling_AF.gas = [ones(n_lhs,1) sampling_AF.gas];
sampling_AF.oil = [ones(n_lhs,1) sampling_AF.oil];

AF_Multipliers = importdata('AF_Multipliers.csv');
% Normalize accoridng to expeccted range of expected fractional difference
% between basin activity factors and US average
sampling_AF.gas = (sampling_AF.gas .* (AF_Multipliers(1,:) - AF_Multipliers(2,:))) + AF_Multipliers(2,:);
sampling_AF.oil = (sampling_AF.oil .* (AF_Multipliers(3,:) - AF_Multipliers(4,:))) + AF_Multipliers(4,:);

save('Mat_AFR_22.1.11.mat','sampling_AF');


n_trial = 1;

%% Main functions
for i = 1:n_lhs
    
    AF.Gas = AF_base.Gas .* sampling_AF.gas(i,:)';
    AF.Oil = AF_base.Oil .* sampling_AF.oil(i,:)';
    
    autorun_func(n_trial, root_path, Activity_tranches, AF, Basin_Select, Basin_Index);
    equipdata_tot = data_proc_master_func(n_trial, root_path, Basin_Select, Basin_Index);

    Mat_temp.Gas = func_loss_frac_v5(equipdata_tot, 1, 1);
    Mat_temp.Oil = func_loss_frac_v5(equipdata_tot, 2, 1);
    
    Mat_LHS.Gas(:,:,i) = Mat_temp.Gas;
    Mat_LHS.Oil(:,:,i) = Mat_temp.Oil;


end

save('Mat_LF_22.1.11.mat','Mat_LHS');

%% Plotting

% EmissionsPlots_UStot()
% 
% 
% for i = 1:13
%     Basin_Select = i;
%     plotting_func(Basin_Index, Basin_Select)
% end



