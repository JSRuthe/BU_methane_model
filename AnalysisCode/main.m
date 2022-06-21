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

% Specify file name of DrillingInfo data
DI_filename = 'annualDF_2020_SpatialJoin_2258.csv'; % % Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.

% Folder names
activityfolder = 'ActivityData/';
basinmapfolder = 'BasinMaps/';
drillinginfofolder = 'DrillingInfo/';
drillinginfofolder2 = 'DrillingInfo/Monthly_Production/Maps_Distributions_Paper/';
distributionsfolder = 'EquipmentDistributions/Set21_Inputs';
GHGRPfolder = 'GHGRP_Dat/';

%% Do you want to replicate results for Rutherford et al 2021?

Replicate = 1;

%% Initialize model
% n_trial: number of Monte Carlo iterations for autorun
n_trial = 25;

if Replicate == 1
    Basin_index = 1;
end

% Distributions indices
%Basin_index = [1,4,6,7,9,10];

% All basins
%Basin_index = [1,4,6,7,9,10,12,14];

Basin_Index = {                     % (0) - If you wish to run all basins (select to replicate tranches for Rutherford et al 2021
    'PERMIAN',...                   % (1)
    'GULF COAST WEST',...           % (2)
    'EAST TEXAS',...                % (3)
    'FORT WORTH',...                % (4)
    'ANADARKO',...                  % (5)
    'DENVER-JULESBURG',...          % (6)
    'UINTA',...                     % (7)
    'GREEN RIVER - OVERTHRUST',...  % (8)
    'SAN JOAQUIN',...                % (9)
    'APPALACHIAN',...               % (10)
    'ARKOMA',...                    % (11)
    'WILLISTON',...                 % (12)
    'POWDER RIVER',...              % (13)
    'SAN JUAN'};

Basin_N = [
    430,...
    220,...
    210,...
    420,...
    360,...
    540,...
    575,...
    535,...
    745,...
    160,...
    345,...
    395,...
    515,...
    580];

for i = 1:numel(Basin_index)
    
    if Replicate ~= 1
        Basin_Select = Basin_index(i);  
        fprintf('Basin = %s... \n', Basin_Index{Basin_Select})
    else
        Basin_Select = 0;
        fprintf('Replicating Rutherford et al 2021')
    end
    
    fprintf('Loading model inputs... \n')
    [Activity_tranches] = tranche_gen_func(Basin_Select, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, drillinginfofolder2, DI_filename);
    Activity_tranches = Activity_tranches';
    fprintf('Model inputs generated... \n')

    %% Main functions
    fprintf('Starting model... \n')
    autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder);
    fprintf('Results generated. Processing results... \n')
    data_proc_master_func(n_trial, Basin_Select, Basin_Index, activityfolder, drillinginfofolder)
end

%% Plotting

%EmissionsPlots_UStot()

fprintf('Initializing plotting functions... \n')
for i = 3:3
    Basin_Select = Basin_index(i);
    plotting_func(Basin_Index, Basin_N, Basin_Select, n_trial,basinmapfolder, activityfolder, drillinginfofolder,drillinginfofolder2, DI_filename)
end

fprintf('Program finished \n')

