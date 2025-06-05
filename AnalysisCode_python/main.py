import os
import pandas as pd
import geopandas as gpd
import argparse
import warnings
import pickle
from GHGRP_read_v3 import *
from tranche_gen_func import *
from autorun_func import *
from data_proc_master_func import *
from plotting_func import *
from generate_inputs import *

warnings.filterwarnings('ignore')

##############################################################################################################
# Version: Philippine Burdeau - Updated on June 4th, 2025}
# Author: Jeff Rutherford
# Description: This script runs the BU methane model.
##############################################################################################################


def run_model(year, shape_id, shape_name, n_trial, production_source, AAPG_province):
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
    shapemapfolder = os.path.join(base_dir, 'BasinMaps')
    productionfolder = os.path.join(base_dir, 'ProductionData')
    distributionsfolder = os.path.join(base_dir, 'EquipmentDistributions', 'Set21_Inputs')
    GHGRPfolder = os.path.join(base_dir, 'GHGRP_Dat')

    # Determine shape info
    if AAPG_province:
        print('AAPG_province')
        if shape_id is None:
            raise ValueError("If AAPG_province is True, you must specify a shape_id.")
        basins_gdf = gpd.read_file(os.path.join(inputsfolder, 'Basins_shapefiles'))

        shape_gdf = basins_gdf[basins_gdf.BASIN_CODE == shape_id]
        if shape_gdf.empty:
            raise ValueError(f"Shape id '{shape_id}' not found.")
        Shape_ID = int(shape_id)
        Shape_Name = shape_gdf.iloc[0]['BASIN_NAME']
        print(Shape_Name)
    else:
        geo_dir = os.path.join(inputsfolder, 'Geo_File')
        geo_files = [f for f in os.listdir(geo_dir) if f.lower().endswith(('.shp', '.geojson', '.json', '.gpkg'))]
        if len(geo_files) != 1:
            raise ValueError("Please put exactly one geo file in 'Inputs/Geo_File'.")
        shape_gdf = gpd.read_file(os.path.join(geo_dir, geo_files[0]))
        Shape_ID = 1
        Shape_Name = shape_name

    DI_filename = f'annualDF_{year}_SpatialJoin_2258.csv'

    print('Generating production data...')
    generate_production_data(year, inputsfolder, productionfolder, production_source, Shape_ID, Shape_Name, shape_gdf)

    print('Generated production data, generating wells to facility data...')
    return_wells_to_facility(year, inputsfolder, productionfolder, GHGRPfolder)

    with open(os.path.join(GHGRPfolder, f'Facility_Proportions_{year}.pkl'), 'rb') as f:
        proportions = pickle.load(f)

    print('Generating GHGRP data...')
    generate_ghgrp_dat(year, Shape_ID, inputsfolder, GHGRPfolder, activityfolder, proportions)

    print(f"Shape = {Shape_Name}...")
    print("Loading GHGRP data...")
    GHGRP_exp, wellcounts = GHGRP_read_v3(0, [Shape_Name], [Shape_ID], GHGRPfolder, year)

    print("Loading model inputs...")
    Activity_tranches, OPGEE_bin, Enverus_tab, AF_shape = tranche_gen_func(
        0, [Shape_Name], [Shape_ID], activityfolder, shapemapfolder, productionfolder,
        DI_filename, GHGRP_exp, Replicate
    )
    Activity_tranches = Activity_tranches.T
    print('before autorun: ', Shape_Name)

    print("Starting model...")
    autorun_func(n_trial, Activity_tranches, 0, [Shape_Name], activityfolder,
                 distributionsfolder, AF_overwrite, AF)

    print("Processing results...")
    print(Shape_Name)
    data_proc_master_func(year, n_trial, welloption, equipoption, 0, [Shape_Name],
                          activityfolder, productionfolder, Enverus_tab, AF_shape)

    print("Initializing plotting functions...")
    plotting_func([Shape_Name], [Shape_ID], 0, n_trial, shapemapfolder,
                  activityfolder, productionfolder, DI_filename, year)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run BU methane model.")
    parser.add_argument('--year', type=int, required=True, help='Target year for analysis')
    parser.add_argument('--shape_id', type=str, default=None, help='AAPG Basin code (required if AAPG_province is True)')
    parser.add_argument('--shape_name', type=str, default=None, help='Shape name (required if AAPG_province is False)')
    parser.add_argument('--n_trial', type=int, required=True, help='Number of Monte Carlo trials')
    parser.add_argument('--production_source', type=str, choices=['CalGEM', 'DrillingInfo'], required=True, help='Source of production data')
    parser.add_argument('--AAPG_province', action='store_true', help='Use AAPG basin (True) or geo file (False)')

    args = parser.parse_args()
    run_model(args.year, args.shape_id, args.shape_name, args.n_trial, args.production_source, args.AAPG_province)
