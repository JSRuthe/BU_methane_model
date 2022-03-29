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

activityfolder = 'ActivityData/';
basinmapfolder = 'BasinMaps/';
drillinginfofolder = 'DrillingInfo/';
distributionsfolder = 'EquipmentDistributions/Set21_Inputs';

% n_trial: number of Monte Carlo iterations for autorun

% for i = 1:13
%i = 9;
    n_trial = 1;

    Basin_Select = 1;

    Basin_Index = {                     % (0) - If you wish to run all basins (select to replicate tranches for Rutherford et al 2021
        'PERMIAN',...                   % (1) 
        'GULF COAST WEST',...           % (2) 
        'EAST TEXAS',...                % (3) 
        'FORT WORTH',...                % (4)
        'ANADARKO',...                  % (5)    
        'DENVER-JULESBURG',...          % (6) 
        'UINTA',...                     % (7)
        'GREEN RIVER - OVERTHRUST',...  % (8)
        'CALIFORNIA',...                % (9)
        'APPALACHIAN',...               % (10)
        'ARKOMA',...                    % (11)
        'WILLISTON',...                 % (12)
        'POWDER RIVER'};                % (13)

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
        515];


    [Activity_tranches] = tranche_gen_func(Basin_Select, Basin_Index, Basin_N, activityfolder, basinmapfolder);
    Activity_tranches = Activity_tranches';


    %% Main functions

    autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder);

    data_proc_master_func(n_trial, Basin_Select, Basin_Index, activityfolder, drillinginfofolder)
% end
% 
%% Plotting

%EmissionsPlots_UStot()
x = 1;

for i = 1:13
    Basin_Select = i;
    plotting_func(Basin_Index, Basin_Select)
end



