%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created July 30, 2022
% 
% BEFORE RUNNING,
%   - Set folder root "BU_methane_model" as the working directory
%   - add "AnalysisCode" and "OPGEEProxyCH4Version" to path
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clean up workspace
clear; clc; close all;

%% Data inputs

%root_path = 'M:\OPGEE MATLAB';
activityfolder = 'ActivityData/';
distributionsfolder = 'EquipmentDistributions/Set21_Inputs';
drillinginfofolder = 'DrillingInfo/';

Basin_Select = 0;
Basin_Index = {};

% Base run inputs
% Load activity columns from Rutherford et al 2021

Activity_tranches = importdata('Activity.csv');


%% Base run

% Blank AF matrix
AF = [];
AF_overwrite = 0;

% Binary options for results processing
welloption = 0;
equipoption = 1;

n_trial = 25;

autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF);
equipdata_tot = data_proc_master_func(n_trial, welloption, equipoption, Basin_Select, Basin_Index, activityfolder, drillinginfofolder);

% set 22 compares the best with paper results
x = 1; % Pause to select best case to use
set_apply = 18;
is_base_case = 1;

%Mat_base.Gas = func_loss_frac_allcolumns(equipdata_tot, 1, set_apply);
Mat_base.Gas = convert2lossfrac(equipdata_tot, 1, set_apply,is_base_case,'Gas_OPGEE_mat_22.7.30.csv');
%Mat_base.Oil = func_loss_frac_allcolumns(equipdata_tot, 2, set_apply);
Mat_base.Oil = convert2lossfrac(equipdata_tot, 2, set_apply,is_base_case,'Oil_OPGEE_mat_22.7.30.csv');

save('Mat_base_22.7.30.mat','Mat_base');

%% Perturbed model runs

% Load equipmentn counts from Rutherford et al 2021
AF_base.Gas = [1;    0;          0.1321; 0.7102; 0.8399;     0.40570;    0.40570;...
    0.0814; 0.02987;    0.2023;     1.8743];
AF_base.Oil = [1;    0.2234;     0.1859; 0.3689; 0;          0.815404;   0.815404;...
    0;      0;          0.08612;    1.1051];

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

save('Mat_AFR_22.7.31_2.mat','sampling_AF');

n_trial = 1;
AF_overwrite = 1;

for i = 1:n_lhs
    
    AF.Gas = AF_base.Gas .* sampling_AF.gas(i,:)';
    AF.Oil = AF_base.Oil .* sampling_AF.oil(i,:)';
    
    autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF);
    equipdata_tot = data_proc_master_func(n_trial, welloption, equipoption, Basin_Select, Basin_Index, activityfolder, drillinginfofolder);

    set_apply = 1;
    is_base_case = 0;
    %Mat_temp.Gas = func_loss_frac_v5(equipdata_tot, 1, 1);
    Mat_temp.Gas = convert2lossfrac(equipdata_tot, 1, set_apply,is_base_case,'empty.csv');
    %Mat_temp.Oil = func_loss_frac_v5(equipdata_tot, 2, 1);
    Mat_temp.Oil = convert2lossfrac(equipdata_tot, 2, set_apply,is_base_case,'empty.csv');

    Mat_LHS.Gas(:,:,i) = Mat_temp.Gas;
    Mat_LHS.Oil(:,:,i) = Mat_temp.Oil;
    i
end

save('Mat_LFR_22.7.31_2.mat','Mat_LHS');




