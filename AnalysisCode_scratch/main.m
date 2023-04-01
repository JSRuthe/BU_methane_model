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
%
%   Important Note: This model uses the same equipment-level emission
%   factor distributions generated for Rutherford et al. (2021). 100
%   realizations of the equipment-level emission factor distributions are
%   contained in the "EquipmentDistributions" folder. To regenerate
%   different distributions, see the Github repo linked with the Rutherford
%   et al. (2021) paper.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clean up workspace
clear; clc; close all;

%% Data inputs

% Binary options for results
%   (i) welloption = 1
%       This option uses the function "wellpersite_func.m" 
%       - USing well counts per site from the Alvarez
%       2018 paper, bin specific well counts are randomly assigned and
%       OPGEE resultts rows are "clustered"
%
%   (ii) equipoption = 1
%       Equipment level vectors are saved
welloption = 0;
equipoption = 0;
    
% Do you want to replicate results for Rutherford et al 2021?
Replicate = 0;

% n_trial: number of Monte Carlo iterations for autorun
n_trial = 50;

%% Initialize files

diary diary_221127.out

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

%% Initialize model

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

for i = 2:numel(Basin_N)
%for i = 1:1
    
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



