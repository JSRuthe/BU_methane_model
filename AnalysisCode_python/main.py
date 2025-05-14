from GHGRP_read_v3 import *
from tranche_gen_func import *
from autorun_func import *
import warnings
warnings.filterwarnings('ignore')
from data_proc_master_func import *
from plotting_func import *
from generate_inputs import *
import argparse

##############################################################################################################
# Version: Philippine Burdeau - Updated on January 29th, 2025}
# Author: Jeff Rutherford
# Description: This script runs the BU methane model.
##############################################################################################################


def run_model(year, input_filename, n_trial, productionsource):
    # Binary options
    welloption = 1
    equipoption = 0
    Replicate = 0
    AF = {}
    AF_overwrite = 0

    # Folder paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    inputsfolder = os.path.join(base_dir, 'Inputs')
    activityfolder = os.path.join(base_dir, 'ActivityData')
    basinmapfolder = os.path.join(base_dir, 'BasinMaps')
    productionfolder = os.path.join(base_dir, 'ProductionData')
    distributionsfolder = os.path.join(base_dir, 'EquipmentDistributions', 'Set21_Inputs')
    GHGRPfolder = os.path.join(base_dir, 'GHGRP_Dat')

    # Load input file
    input_filepath = os.path.join(inputsfolder, input_filename)
    raw_dat = pd.read_csv(input_filepath, header=None)
    Basin_N = raw_dat.iloc[:, 0].values
    Basin_Index = raw_dat.iloc[:, 1].values

    DI_filename = f'annualDF_{year}_SpatialJoin_2258.csv'

    print('Generating GHGRP data...')
    generate_ghgrp_dat(year, Basin_N, inputsfolder, GHGRPfolder, activityfolder)

    print('Generating ProductionData data...')
    generate_production_data(year, inputsfolder, productionfolder, productionsource)

    print('Generated ProductionData data, generating wells to facility data...')
    return_wells_to_facility(year, inputsfolder, productionfolder, GHGRPfolder)

    for i in range(len(Basin_N)):
        print(f"Basin = {Basin_Index[i]}...")

        print("Loading GHGRP data...")
        GHGRP_exp, wellcounts = GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder, year)

        print("Loading model inputs...")
        Activity_tranches, OPGEE_bin, Enverus_tab, AF_basin = tranche_gen_func(
            i, Basin_Index, Basin_N, activityfolder, basinmapfolder, productionfolder, DI_filename, GHGRP_exp, Replicate
        )
        Activity_tranches = Activity_tranches.T

        print("Starting model...")
        autorun_func(n_trial, Activity_tranches, i, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF)

        print("Processing results...")
        data_proc_master_func(n_trial, welloption, equipoption, i, Basin_Index, activityfolder,
                              productionfolder, Enverus_tab, AF_basin)

    print("Initializing plotting functions...")
    for i in range(len(Basin_N)):
        plotting_func(Basin_Index, Basin_N, i, n_trial, basinmapfolder, activityfolder,
                      productionfolder, DI_filename, year)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run BU methane model.")
    parser.add_argument('--year', type=int, required=True, help='Target year for analysis')
    parser.add_argument('--input_filename', type=str, required=True, help='CSV file with basin info')
    parser.add_argument('--n_trial', type=int, required=True, help='Number of Monte Carlo trials')
    parser.add_argument('--productionsource', type=str, choices=['CalGEM', 'DrillingInfo'], required=True, help='Source of production data')

    args = parser.parse_args()
    run_model(args.year, args.input_filename, args.n_trial, args.productionsource)
