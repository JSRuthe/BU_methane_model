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

diary diary_22914.out

% Binary options for results
    welloption = 1;
    equipoption = 0;

% Specify file name of DrillingInfo data
DI_filename = 'annualDF_2020_SpatialJoin_2258.csv'; % % Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.

% Specify file name of the input data
input_filename = 'Distributions_Paper.csv';

% Folder names
inputsfolder = 'Inputs';
activityfolder = 'ActivityData/';
basinmapfolder = 'BasinMaps/';
drillinginfofolder = 'DrillingInfo/';
drillinginfofolder2 = 'DrillingInfo/Monthly_Production/Maps_Distributions_Paper/';
distributionsfolder = 'EquipmentDistributions/Set21_Inputs';
GHGRPfolder = 'GHGRP_Dat/';

%% Do you want to replicate results for Rutherford et al 2021?

Replicate = 0;

%% Initialize model
% n_trial: number of Monte Carlo iterations for autorun
n_trial = 100;

% Blank AF matrix
AF = [];
AF_overwrite = 0;

if Replicate == 1
    Basin_index = 1;
end

% Import data inputs file
formatSpec = '%f%C';
filepath = fullfile(pwd, inputsfolder,input_filename);
raw_dat = readtable(filepath,'Format',formatSpec);
Basin_N = raw_dat.Var1;
Basin_Index = cellstr(raw_dat.Var2);

for i = 1:numel(Basin_N)
    
    if Replicate ~= 1
        fprintf('Basin = %s... \n', Basin_Index{i})
    else
        fprintf('Replicating Rutherford et al 2021')
    end
    
    fprintf('Loading GHGRP data... \n')
    GHGRP_exp = GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder);
    fprintf('Done loading GHGRP data... \n')  
    
    fprintf('Loading model inputs... \n')
    [Activity_tranches, OPGEE_bin, Enverus_tab, AF_basin] = tranche_gen_func(i, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename, GHGRP_exp, Replicate);
    Activity_tranches = Activity_tranches';
    fprintf('Model inputs generated... \n')

    %% Main functions
    fprintf('Starting model... \n')
    autorun_func(n_trial, Activity_tranches, i, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF);
    fprintf('Results generated. Processing results... \n')
    data_proc_master_func(n_trial, welloption, equipoption, i, Basin_Index, activityfolder, drillinginfofolder, Enverus_tab, AF_basin)
end
fprintf('Program finished \n')
diary off

%% Plotting

%EmissionsPlots_UStot()

fprintf('Initializing plotting functions... \n')
for i = 6:6%numel(Basin_N)
    % Basin_Select = Basin_index(i);
    plotting_func(Basin_Index, Basin_N, i, n_trial,basinmapfolder, activityfolder, drillinginfofolder,DI_filename)
end



