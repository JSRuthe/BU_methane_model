import os
import pandas as pd
import numpy as np
from GHGRP_read_v3 import *
from tranche_gen_func import *
from autorun_func import *
import warnings
warnings.filterwarnings('ignore')
from data_proc_master_func import *
from plotting_func import *


# Binary options for results
welloption = 1
equipoption = 0

# Specify file name of DrillingInfo data
DI_filename = 'annualDF_2020_SpatialJoin_2258.csv'

# Specify file name of the input data
input_filename = 'Distributions_Paper.csv'

# Folder names
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # This goes up one directory from the current script location

inputsfolder = os.path.join(base_dir, 'Inputs')
activityfolder = os.path.join(base_dir, 'ActivityData')
basinmapfolder = os.path.join(base_dir, 'BasinMaps')
drillinginfofolder = os.path.join(base_dir, 'DrillingInfo')
drillinginfofolder2 = os.path.join(drillinginfofolder, 'Monthly_Production', 'Maps_Distributions_Paper')
distributionsfolder = os.path.join(base_dir, 'EquipmentDistributions', 'Set21_Inputs')
GHGRPfolder = os.path.join(base_dir, 'GHGRP_Dat')

# Do you want to replicate results for Rutherford et al 2021?
Replicate = 0 # Leave = 0

# Number of Monte Carlo iterations for autorun
n_trial = 100

# Initialize blank AF matrix
AF = {}
AF_overwrite = 0

if Replicate == 1:
    Basin_index = 1

# Import data inputs file
input_filepath = os.path.join(inputsfolder, input_filename)
raw_dat = pd.read_csv(input_filepath, header=None)
Basin_N = raw_dat.iloc[:, 0].values  # First column for Basin numbers
Basin_Index = raw_dat.iloc[:, 1].values  # Second column for Basin names

for i in range(4,5):

    if Replicate != 1:
        print(f"Basin = {Basin_Index[i]}...")
    else:
        print("Replicating Rutherford et al 2021")

    print("Loading GHGRP data...")

    GHGRP_exp, wellcounts = GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder)
    print("Done loading GHGRP data...")

    print("Loading model inputs...")

    Activity_tranches, OPGEE_bin, Enverus_tab, AF_basin = tranche_gen_func(
        i, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename, GHGRP_exp, Replicate
    )
    Activity_tranches = Activity_tranches.T
    print("Model inputs generated...")

    # Main function calls
    print("Starting model...")
    autorun_func(n_trial, Activity_tranches, i, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF)
    print("Results generated. Processing results...")
    data_proc_master_func(n_trial, welloption, equipoption, i, Basin_Index, activityfolder, drillinginfofolder,
                          Enverus_tab, AF_basin)

print("Program finished")

# Plotting
print("Initializing plotting functions...")

for i in range(4,5):
    plotting_func(Basin_Index, Basin_N, i, n_trial, basinmapfolder, activityfolder, drillinginfofolder, DI_filename)