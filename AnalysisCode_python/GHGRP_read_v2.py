import pandas as pd
import numpy as np

def GHGRP_read_v2(GHGRPfolder):
    # Parameters for processing
    cutoff = 100  # Mscf/bbl

    # Import CSV data
    filepath = f'{GHGRPfolder}/RY2020_FACILITY_OVERVIEW.CSV'
    facility_dat = pd.read_csv(filepath)
    facility_dat.fillna(0, inplace=True)

    equip_dat = pd.read_csv('Equip_2015.csv')
    equip_dat.fillna(0, inplace=True)

    tanks12_dat = pd.read_csv('Tanks12_2015.csv')
    tanks12_dat.fillna(0, inplace=True)

    tanks3_dat = pd.read_csv('Tanks3_2015.csv')
    tanks3_dat.fillna(0, inplace=True)

    pc_dat = pd.read_csv('PC_2015.csv')
    pc_dat.fillna(0, inplace=True)

    pump_dat = pd.read_csv('Pump_2015.csv')
    pump_dat.fillna(0, inplace=True)

    # Process facility data
    facility_grouped = facility_dat.groupby('FACILITY_ID').agg({
        'GAS_PROD_CAL_YEAR_FROM_WELLS': 'sum',
        'OIL_PROD_CAL_YEAR_FOR_SALES': 'sum',
        'WELL_COUNT': 'sum'
    }).reset_index()

    M_raw = facility_grouped[['FACILITY_ID', 'GAS_PROD_CAL_YEAR_FROM_WELLS', 'OIL_PROD_CAL_YEAR_FOR_SALES', 'WELL_COUNT']].copy()

    # Process equipment data
    equip_grouped = equip_dat.groupby('FACILITY_ID').agg({
        'HEADER_PER_WELL': 'sum',
        'HEATER_PER_WELL': 'sum',
        'SEPARATOR_PER_WELL': 'sum',
        'METER_PER_WELL': 'sum',
        'RECIP_COMPRESSOR_PER_WELL': 'sum',
        'DEHYDRATORS': 'sum'
    }).reset_index()

    equip_lookup = pd.merge(facility_grouped[['FACILITY_ID']], equip_grouped, on='FACILITY_ID', how='left').fillna(0)
    M_raw = pd.merge(M_raw, equip_lookup, on='FACILITY_ID', how='left')

    # Process tanks12 data
    tanks12_grouped = tanks12_dat.groupby('FACILITY_ID').agg({
        'TANKS_PER_WELL': 'sum',
        'TANKS_OIL_THROUGHPUT': 'sum',
        'TANKS_OIL_CONTROLLED': 'sum'
    }).reset_index()

    tanks12_lookup = pd.merge(facility_grouped[['FACILITY_ID']], tanks12_grouped, on='FACILITY_ID', how='left').fillna(0)
    M_raw = pd.merge(M_raw, tanks12_lookup, on='FACILITY_ID', how='left')

    # Process tanks3 data
    tanks3_grouped = tanks3_dat.groupby('FACILITY_ID').agg({
        'TANKS_PER_WELL': 'sum',
        'TANKS_OIL_THROUGHPUT': 'sum',
        'TANKS_OIL_CONTROLLED': 'sum'
    }).reset_index()

    tanks3_lookup = pd.merge(facility_grouped[['FACILITY_ID']], tanks3_grouped, on='FACILITY_ID', how='left').fillna(0)
    M_raw = pd.merge(M_raw, tanks3_lookup, on='FACILITY_ID', how='left')

    # Process PC data
    pc_grouped = pc_dat.groupby('FACILITY_ID').agg({
        'PC_PER_WELL': 'sum'
    }).reset_index()

    pc_lookup = pd.merge(facility_grouped[['FACILITY_ID']], pc_grouped, on='FACILITY_ID', how='left').fillna(0)
    M_raw = pd.merge(M_raw, pc_lookup, on='FACILITY_ID', how='left')

    # Process pump data
    pump_grouped = pump_dat.groupby('FACILITY_ID').agg({
        'PUMP_PER_WELL': 'sum'
    }).reset_index()

    pump_lookup = pd.merge(facility_grouped[['FACILITY_ID']], pump_grouped, on='FACILITY_ID', how='left').fillna(0)
    M_raw = pd.merge(M_raw, pump_lookup, on='FACILITY_ID', how='left')

    # Now expand the facility-level data to a well-level dataset
    total_wells = M_raw['WELL_COUNT'].sum()
    M_new = pd.DataFrame(columns=M_raw.columns)

    for _, row in M_raw.iterrows():
        for _ in range(int(row['WELL_COUNT'])):
            M_new = M_new.append({
                'FACILITY_ID': row['FACILITY_ID'],
                'OIL_PROD_CAL_YEAR_FOR_SALES': row['OIL_PROD_CAL_YEAR_FOR_SALES'] / row['WELL_COUNT'] / 365.25,
                'GAS_PROD_CAL_YEAR_FROM_WELLS': row['GAS_PROD_CAL_YEAR_FROM_WELLS'] / row['WELL_COUNT'] / 365.25,
                'HEADER_PER_WELL': row['HEADER_PER_WELL'] / row['WELL_COUNT'],
                'HEATER_PER_WELL': row['HEATER_PER_WELL'] / row['WELL_COUNT'],
                'SEPARATOR_PER_WELL': row['SEPARATOR_PER_WELL'] / row['WELL_COUNT'],
                'METER_PER_WELL': row['METER_PER_WELL'] / row['WELL_COUNT'],
                'TANKS_PER_WELL': row['TANKS_PER_WELL'] / row['WELL_COUNT'],
                'RECIP_COMPRESSOR_PER_WELL': row['RECIP_COMPRESSOR_PER_WELL'] / row['WELL_COUNT'],
                'DEHYDRATORS': row['DEHYDRATORS'] / row['WELL_COUNT'],
                'PC_PER_WELL': row['PC_PER_WELL'] / row['WELL_COUNT'],
                'PUMP_PER_WELL': row['PUMP_PER_WELL'] / row['WELL_COUNT']
            }, ignore_index=True)

    # Perform binning based on gas production rates
    edges = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 500000000]
    M_new['GAS_PROD_BIN'] = pd.cut(M_new['GAS_PROD_CAL_YEAR_FROM_WELLS'], bins=edges)

    # Aggregate the binned data
    bin_aggregated = M_new.groupby('GAS_PROD_BIN').agg({
        'GAS_PROD_CAL_YEAR_FROM_WELLS': ['mean', 'sum'],
        'OIL_PROD_CAL_YEAR_FOR_SALES': 'sum'
    }).reset_index()

    # Output the results in a dictionary
    OPGEE_bin = {
        'gassall': bin_aggregated
    }

    return OPGEE_bin
