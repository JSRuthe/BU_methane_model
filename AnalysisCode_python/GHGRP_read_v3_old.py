import pandas as pd
import numpy as np


def GHGRP_read_v3_old(i, Basin_Index, Basin_N, GHGRPfolder):
    # Define the cut-off value
    cutoff = 100  # Mscf/bbl

    # Load facility correspondence data
    facility_correspondence = pd.read_csv(f'{GHGRPfolder}/API_Facility_correspondence_2020.csv')
    facility_correspondence.fillna(0, inplace=True)

    # Extract columns for gas and oil production and handle missing values
    Gas_Production = facility_correspondence['Annual Gas [mscf/year]'].fillna(0)
    Oil_Production = facility_correspondence['Annual Oil [bbl/year]'].fillna(0)
    Facility_No = facility_correspondence['FACILITY_ID']

    M_all = pd.DataFrame(
        {'Facility_No': Facility_No, 'Oil_Production': Oil_Production, 'Gas_Production': Gas_Production})

    # Load facility and basin correspondence
    facility_basin = pd.read_csv(f'{GHGRPfolder}/Facility_Basin_correspondence_2020.csv')
    facility_basin['Basin_ID'] = facility_basin['Basin_ID'].replace('160A', '160')

    # Filter based on Basin
    basin_ind = facility_basin['Basin_ID'] == Basin_N[i]
    filtered_facility_basin = facility_basin[basin_ind]
    M_in = M_all[M_all['Facility_No'].isin(filtered_facility_basin['FACILITY_ID'])]

    # Load other datasets
    Facilities_dat = pd.read_csv(f'{GHGRPfolder}/Facilities_2020.csv', header=None).fillna(0)
    Equip_dat = pd.read_csv(f'{GHGRPfolder}/Equip_2020.csv', header=None).fillna(0)
    Tanks12_dat = pd.read_csv(f'{GHGRPfolder}/Tanks12_2020.csv', header=None).fillna(0)
    Tanks3_dat = pd.read_csv(f'{GHGRPfolder}/Tanks3_2020.csv', header=None).fillna(0)
    PC_dat = pd.read_csv(f'{GHGRPfolder}/PC_2020.csv', header=None).fillna(0)
    Pump_dat = pd.read_csv(f'{GHGRPfolder}/Pump_2020.csv', header=None).fillna(0)

    # Set column names
    Equip_dat.columns = ['Equip_Type', 'Facility_No', 'Equip_Count', 'Basin_ID']
    Facilities_dat.columns = ['Facility_No', 'Basin_ID', 'Wells', 'CH4']
    Tanks12_dat.columns = ['Facility_No', 'QVRU_12', 'QVent_12', 'QFlare_12', 'Tank_Count_12', 'Basin_ID']
    Tanks3_dat.columns = ['Facility_No', 'QVRU_3', 'QVent_3', 'QFlare_3', 'Tank_Count_3', 'Basin_ID']
    PC_dat.columns = ['Facility_No', 'PC_Count', 'Basin_ID']
    Pump_dat.columns = ['Facility_No', 'Pump_Count', 'Basin_ID']

    # Merge datasets with M_in to create M_new
    M_new = M_in.copy()

    # Convert Oil and Gas production to daily
    M_new['Oil_Production'] /= 365
    M_new['Gas_Production'] /= 365

    # Merge equipment data
    Equip_data_all = Equip_dat.groupby('Facility_No').sum().reset_index()

    M_new['Facility_No'] = M_new['Facility_No'].astype(int)
    Equip_data_all['Facility_No'] = Equip_data_all['Facility_No'].astype(int)
    M_new = pd.merge(M_new, Equip_data_all[['Facility_No', 'Equip_Count']], on='Facility_No', how='left').fillna(0)

    # Merge facilities data
    Facilities_dat_consol = Facilities_dat.groupby('Facility_No').sum().reset_index()
    Facilities_dat_consol['Facility_No'] = Facilities_dat_consol['Facility_No'].astype(int)

    M_new = pd.merge(M_new, Facilities_dat_consol[['Facility_No', 'Wells', 'CH4']], on='Facility_No',
                     how='left').fillna(0)

    # Merge Tanks12 data
    Tanks12_dat_consol = Tanks12_dat.groupby('Facility_No').sum().reset_index()
    M_new = pd.merge(M_new, Tanks12_dat_consol[['Facility_No', 'Tank_Count_12', 'QVent_12', 'QFlare_12', 'QVRU_12']],
                     on='Facility_No', how='left').fillna(0)

    # Merge Tanks3 data
    Tanks3_dat_consol = Tanks3_dat.groupby('Facility_No').sum().reset_index()
    M_new = pd.merge(M_new, Tanks3_dat_consol[['Facility_No', 'Tank_Count_3', 'QVent_3', 'QFlare_3', 'QVRU_3']],
                     on='Facility_No', how='left').fillna(0)

    # Merge PC and Pump data
    PC_dat_consol = PC_dat.groupby('Facility_No').sum().reset_index()
    Pump_dat_consol = Pump_dat.groupby('Facility_No').sum().reset_index()

    M_new = pd.merge(M_new, PC_dat_consol[['Facility_No', 'PC_Count']], on='Facility_No', how='left').fillna(0)
    M_new = pd.merge(M_new, Pump_dat_consol[['Facility_No', 'Pump_Count']], on='Facility_No', how='left').fillna(0)

    # Calculate well counts
    wellcounts = [M_new['Equip_Count'].sum(), M_new['Wells'].sum()]

    # Apply necessary scaling for some fields (as per MATLAB)
    M_new['Headers_per_well'] = M_new['Equip_Count'] / M_new['Wells']
    M_new['Tank_Count_12'] = M_new['Tank_Count_12'].fillna(0)
    M_new['Tank_Count_3'] = M_new['Tank_Count_3'].fillna(0)

    # Combine Tank12 and Tank3 counts
    M_new['Tanks_per_well'] = (M_new['Tank_Count_12'] + M_new['Tank_Count_3']) / M_new['Wells']
    M_new['PC_per_well'] = M_new['PC_Count'] / M_new['Wells']
    M_new['Pump_per_well'] = M_new['Pump_Count'] / M_new['Wells']

    # Compute binned statistics
    binning_edges = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 500000000]
    M_new['bin'] = pd.cut(M_new['Gas_Production'], bins=binning_edges, labels=False)

    # Initialize an empty DataFrame for bin_data with 10 bins
    bin_data = pd.DataFrame(index=np.arange(10), columns=[
        'Gas_Production_mean', 'Gas_Production_sum', 'Oil_Production_sum', 'Wells_sum',
        'Headers_per_well_mean', 'Tanks_per_well_mean', 'PC_per_well_mean', 'Pump_per_well_mean',
        'CH4_mean', 'Oil_Throughput', 'Oil_Controls'])

    # Calculate the necessary additional columns, handling empty bins explicitly
    bin_data_calculated = M_new.groupby('bin').agg({
        'Gas_Production': ['mean', 'sum'],
        'Oil_Production': 'sum',
        'Wells': 'sum',
        'Headers_per_well': 'mean',
        'Tanks_per_well': 'mean',
        'PC_per_well': 'mean',
        'Pump_per_well': 'mean',
        'CH4': 'mean'
    }).fillna(0)

    # Adding oil throughput and controls (Col 16 and Col 17 in MATLAB)
    bin_data_calculated['Oil_Throughput'] = (M_new.groupby('bin')['Oil_Production'].sum() /
                                             M_new.groupby('bin')['Wells'].sum()).fillna(0)
    bin_data_calculated['Oil_Controls'] = (M_new.groupby('bin')['QVent_12'].sum() +
                                           M_new.groupby('bin')['QFlare_12'].sum()).fillna(0)

    # Assign calculated bins to bin_data, ensuring empty bins are filled with zeros
    bin_data.loc[bin_data_calculated.index] = bin_data_calculated.values

    # Convert the DataFrame to a NumPy array
    OPGEE_bin = bin_data.fillna(0).values

    print('OPGEE_bin shape: ', OPGEE_bin.shape)
    print(bin_data)

    return OPGEE_bin, wellcounts
