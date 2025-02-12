import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')
import os
def GHGRP_read_v3(i, Basin_Index, Basin_N, GHGRPfolder, year):
    # Load facility correspondence data
    facility_correspondence = pd.read_csv(os.path.join(GHGRPfolder, f'API_Facility_correspondence_{year}.csv'))
    facility_correspondence.fillna(0, inplace=True)

    # Extract gas and oil production data
    Gas_Production = facility_correspondence['Annual Gas [mscf/year]'].fillna(0)
    Oil_Production = facility_correspondence['Annual Oil [bbl/year]'].fillna(0)
    Facility_No = facility_correspondence['FACILITY_ID']

    # Combine data into M_all dataframe
    M_all = pd.DataFrame({
        'Facility_No': Facility_No,
        'Oil_Production': Oil_Production,
        'Gas_Production': Gas_Production
    })

    # Load facility and basin correspondence
    facility_basin = pd.read_csv(os.path.join(GHGRPfolder, f'Facility_Basin_correspondence_{year}.csv'))
    facility_basin['Basin_ID'] = facility_basin['Basin_ID'].replace('160A', '160')

    # Filter based on selected basin
    basin_ind = facility_basin['Basin_ID'] == Basin_N[i]
    filtered_facility_basin = facility_basin[basin_ind]
    M_in = M_all[M_all['Facility_No'].isin(filtered_facility_basin['FACILITY_ID'])]

    # Load other datasets
    Facilities_dat = pd.read_csv(os.path.join(GHGRPfolder, f'Facilities_{year}.csv'), header=None).fillna(0)
    Equip_dat = pd.read_csv(os.path.join(GHGRPfolder, f'Equip_{year}.csv'), header=None).fillna(0)
    Tanks12_dat = pd.read_csv(os.path.join(GHGRPfolder, f'Tanks12_{year}.csv'), header=None).fillna(0)
    Tanks3_dat = pd.read_csv(os.path.join(GHGRPfolder, f'Tanks3_{year}.csv'), header=None).fillna(0)
    PC_dat = pd.read_csv(os.path.join(GHGRPfolder, f'PC_{year}.csv'), header=None).fillna(0)
    Pump_dat = pd.read_csv(os.path.join(GHGRPfolder, f'Pump_{year}.csv'), header=None).fillna(0)

    # Process equipment data
    Equip_dat.columns = ['Equip_Type', 'Facility_No', 'Equip_Count', 'Basin_ID']
    Equip_dat['Equip_Type'] = Equip_dat['Equip_Type'].astype(str)
    Equip_types = Equip_dat['Equip_Type'].unique()
    logind = {}
    logind[1] = Equip_dat['Equip_Type'] == 'Header'  # Header: Equip_id{3} in MATLAB
    logind[2] = (Equip_dat['Equip_Type'] == 'In-line heaters') | (
                Equip_dat['Equip_Type'] == 'Heater-treater')  # Heater: Equip_id{4} | Equip_id{5}
    logind[3] = Equip_dat['Equip_Type'] == 'Separators'  # Separator: Equip_id{7}
    logind[4] = Equip_dat['Equip_Type'] == 'Meters/piping'  # Meter: Equip_id{6}
    logind[7] = Equip_dat['Equip_Type'] == 'Compressors'  # Reciprocating Compressor: Equip_id{1}
    logind[8] = Equip_dat['Equip_Type'] == 'Dehydrators'  # Dehydrator: Equip_id{2}
    logind[9] = Equip_dat['Equip_Type'] == 'Wellhead'  # Wellhead: Equip_id{8}

    col_1 = Equip_dat.loc[logind[1], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_2 = Equip_dat.loc[logind[2], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_3 = Equip_dat.loc[logind[3], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_4 = Equip_dat.loc[logind[4], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_7 = Equip_dat.loc[logind[7], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_8 = Equip_dat.loc[logind[8], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']
    col_9 = Equip_dat.loc[logind[9], ['Facility_No', 'Equip_Count']].groupby('Facility_No').sum()['Equip_Count']

    Equip_data_all = pd.DataFrame({
        'Facility_No': col_1.index,
        'Header_Count': col_1.values,
        'Heater_Count': col_2.reindex(col_1.index, fill_value=0).values,  # Ensure all columns have same index
        'Separator_Count': col_3.reindex(col_1.index, fill_value=0).values,
        'Meter_Count': col_4.reindex(col_1.index, fill_value=0).values,
        'Recip_Compressor_Count': col_7.reindex(col_1.index, fill_value=0).values,
        'Dehydrator_Count': col_8.reindex(col_1.index, fill_value=0).values,
        'Wellhead_Count': col_9.reindex(col_1.index, fill_value=0).values
    }).reset_index(drop=True)

    # Process facilties data
    Facilities_dat.columns = ['Facility_No', 'Basin_ID', 'Wells', 'CH4']
    Facility_ID_prod_facilities, ic = np.unique(Facilities_dat['Facility_No'], return_inverse=True)

    Facilities_dat_consol = Facilities_dat.groupby('Facility_No').agg({
        'Wells': 'sum',  # Sum the well counts
        'CH4': 'mean'  # Calculate the simple mean for CH4
    }).reset_index()
    Facilities_dat_consol.rename(columns={'Wells': 'Wells_sum', 'CH4': 'CH4_mean'}, inplace=True)

    # Process Tanks12 data
    Tanks12_dat.columns = ['Facility_No', 'QVRU_12', 'QVent_12', 'QFlare_12', 'Tank_Count_12', 'Basin_ID']
    Facility_ID_prod_tanks12, ic = np.unique(Tanks12_dat['Facility_No'], return_inverse=True)

    tanks12_dat_consol = pd.DataFrame({
        'Facility_No': np.unique(Tanks12_dat['Facility_No']),
        'QVRU_12_sum': np.bincount(ic, Tanks12_dat['QVRU_12']),
        'QVent_12_sum': np.bincount(ic, Tanks12_dat['QVent_12']),
        'QFlare_12_sum': np.bincount(ic, Tanks12_dat['QFlare_12']),
        'Tank_Count_12_sum': np.bincount(ic, Tanks12_dat['Tank_Count_12'])
    })

    # Process Tanks3 data
    Tanks3_dat = Tanks3_dat.iloc[:, :6]  # Select the first 6 columns
    Tanks3_dat.columns = ['Facility_No', 'QVRU_3', 'QVent_3', 'QFlare_3', 'Tank_Count_3', 'Basin_ID']

    Facility_ID_prod_tanks3, ic = np.unique(Tanks3_dat['Facility_No'], return_inverse=True)

    tanks3_dat_consol = pd.DataFrame({
        'Facility_No': np.unique(Tanks3_dat['Facility_No']),
        'QVRU_3_sum': np.bincount(ic, Tanks3_dat['QVRU_3']),
        'QVent_3_sum': np.bincount(ic, Tanks3_dat['QVent_3']),
        'QFlare_3_sum': np.bincount(ic, Tanks3_dat['QFlare_3']),
        'Tank_Count_3_sum': np.bincount(ic, Tanks3_dat['Tank_Count_3'])
    })

    # Process PC data
    PC_dat.columns = ['Facility_No', 'PC_Count', 'Basin_ID']
    Facility_ID_prod_PC, ic = np.unique(PC_dat['Facility_No'], return_inverse=True)

    PC_dat_consol = pd.DataFrame({
        'Facility_No': np.unique(PC_dat['Facility_No']),
        'PC_Count_sum': np.bincount(ic, PC_dat['PC_Count'])
    })

    # Process Pump data
    Pump_dat.columns = ['Facility_No', 'Pump_Count', 'Basin_ID']
    Facility_ID_prod_pumps, ic = np.unique(Pump_dat['Facility_No'], return_inverse=True)

    pump_dat_consol = pd.DataFrame({
        'Facility_No': np.unique(Pump_dat['Facility_No']),
        'Pump_Count_sum': np.bincount(ic, Pump_dat['Pump_Count'])
    })

    # Initialize wellcounts and M_new matrix
    wellcounts = [0, 0]
    size_mat = len(M_in)
    M_new = np.zeros((size_mat, 19))

    M_new[:, 0:3] = M_in[['Facility_No', 'Oil_Production', 'Gas_Production']].values
    M_new[:, 1:3] /= 365

    # Matching and processing

    for idx in range(size_mat):
        fac_no = M_in.iloc[idx]['Facility_No']
        # Matching with equipment data
        if fac_no in Equip_data_all['Facility_No'].values:
            loc_equip = Equip_data_all[Equip_data_all['Facility_No'] == fac_no].index[0]
            M_new[idx, 3] = Equip_data_all.loc[loc_equip, 'Wellhead_Count']  # Equipment count in column 3
            M_new[idx, 5:9] = Equip_data_all.loc[loc_equip, ['Header_Count', 'Heater_Count', 'Separator_Count', 'Meter_Count']]  # Headers, Heaters, Separators, Meters
            M_new[idx, 11:13] = Equip_data_all.loc[loc_equip, ['Recip_Compressor_Count', 'Dehydrator_Count']]  # Headers, Heaters, Separators, Meters

        # Matching with Facilities data
        if fac_no in Facilities_dat_consol['Facility_No'].values:
            loc_fac = Facilities_dat_consol[Facilities_dat_consol['Facility_No'] == fac_no].index[0]
            M_new[idx, 4] = Facilities_dat_consol.loc[loc_fac, 'Wells_sum']  # Well count in column 4
            M_new[idx, 18] = Facilities_dat_consol.loc[loc_fac, 'CH4_mean']  # Well count in column 4
            wellcounts[1] += Facilities_dat_consol.loc[loc_fac, 'Wells_sum']

        # Matching with Tanks12 data
        if fac_no in tanks12_dat_consol['Facility_No'].values:
            loc_tanks12 = tanks12_dat_consol[tanks12_dat_consol['Facility_No'] == fac_no].index[0]
            M_new[idx, 9:11] = tanks12_dat_consol.loc[loc_tanks12, ['Tank_Count_12_sum', 'Tank_Count_12_sum']]  # Tank counts
            M_new[idx, 16] = tanks12_dat_consol.loc[loc_tanks12, ['QVRU_12_sum', 'QVent_12_sum', 'QFlare_12_sum']].sum()  # QVRU + QFlare for oil throughput
            M_new[idx, 17] = tanks12_dat_consol.loc[loc_tanks12, ['QVRU_12_sum', 'QFlare_12_sum']].sum()  # QVRU + QFlare for oil throughput

        # Matching with Tanks3 data
        if fac_no in tanks3_dat_consol['Facility_No'].values:
            loc_tanks3 = tanks3_dat_consol[tanks3_dat_consol['Facility_No'] == fac_no].index[0]
            M_new[idx, 9] += tanks3_dat_consol.loc[loc_tanks3, 'Tank_Count_3_sum']  # Additional tank counts
            M_new[idx, 10] += tanks3_dat_consol.loc[loc_tanks3, 'Tank_Count_3_sum']  # Additional tank counts
            M_new[idx, 16] += tanks3_dat_consol.loc[loc_tanks3, ['QVRU_3_sum', 'QVent_3_sum', 'QFlare_3_sum']].sum()  # Additional QVRU + QFlare
            M_new[idx, 17] += tanks3_dat_consol.loc[loc_tanks3, ['QVRU_3_sum', 'QFlare_3_sum']].sum()  # Additional QVRU + QFlare

        # Matching with PC data
        if fac_no in PC_dat_consol['Facility_No'].values:
            loc_pc = PC_dat_consol[PC_dat_consol['Facility_No'] == fac_no].index[0]
            M_new[idx, 14] = PC_dat_consol.loc[loc_pc, 'PC_Count_sum']  # PC count in column 14

        # Matching with Pump data
        if fac_no in pump_dat_consol['Facility_No'].values:
            loc_pump = pump_dat_consol[pump_dat_consol['Facility_No'] == fac_no].index[0]
            M_new[idx, 13] = pump_dat_consol.loc[loc_pump, 'Pump_Count_sum']  # Pump count in column 13

    # Normalize equipment data by well counts
    M_new[:, [5, 6, 7, 8, 11, 12]] /= M_new[:, 3:4]  # Normalize columns 5-8, 12-13 by column 4 (well counts)
    M_new[:, [9, 10, 13, 14]] /= M_new[:, 4:5]  # Normalize columns 9-10, 14-15 by well counts in column 4
    M_new[:, 17] /= M_new[:, 16]  # Normalize CH4 by total oil throughput in column 17

    # Binning
    edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 500000000]
    counts, edges = np.histogram(M_new[:, 2], bins=edges_set)
    ind = np.digitize(M_new[:, 2], bins=edges_set) - 1
    ind[ind < 0] = 0

    bin_ave_gas = np.array([M_new[ind == i, 2].mean() if np.any(ind == i) else 0 for i in range(len(edges_set) - 1)])
    bin_sum_gas = np.array([M_new[ind == i, 2].sum() if np.any(ind == i) else 0 for i in range(len(edges_set) - 1)])
    bin_sum_oilwg = np.array([M_new[ind == i, 1].sum() if np.any(ind == i) else 0 for i in range(len(edges_set) - 1)])

    M_new[np.isnan(M_new[:, 16]), 16] = 0
    WeightedMeanFcn = lambda x: np.sum(M_new[x, 16] * M_new[x, 1]) / np.sum(M_new[x, 1]) if np.sum(
        M_new[x, 1]) > 0 else 0
    bin_sum_oilthru = np.array([WeightedMeanFcn(np.where(ind == i)[0]) for i in range(len(edges_set) - 1)])

    M_new[np.isnan(M_new[:, 17]), 17] = 0
    WeightedMeanFcn_control = lambda x: np.sum(M_new[x, 17] * M_new[x, 1]) / np.sum(M_new[x, 1]) if np.sum(
        M_new[x, 1]) > 0 else 0
    bin_sum_oilcontrol = np.array([WeightedMeanFcn_control(np.where(ind == i)[0]) for i in range(len(edges_set) - 1)])
    bin_ave_AF = np.zeros((np.count_nonzero(counts), 11))  # Correct: 11 columns


    for i in range(10):  # Loop over 10 columns
        col_idx = i + 5
        M_new[np.isinf(M_new[:, col_idx]), col_idx] = 0
        M_new[np.isnan(M_new[:, col_idx]), col_idx] = 0
        bin_ave_AF_column = np.zeros(len(edges_set) - 1)
        for j in range(len(edges_set) - 1):
            bin_indices = np.where(ind == j)[0]
            if len(bin_indices) > 0:
                weights = M_new[bin_indices, 3]
                data = M_new[bin_indices, col_idx]
                if np.sum(weights) > 0:
                    weighted_mean = np.sum(data * weights) / np.sum(weights)
                else:
                    weighted_mean = 0
            else:
                weighted_mean = 0
            bin_ave_AF_column[j] = weighted_mean
        bin_ave_AF[:, i] = bin_ave_AF_column[:len(bin_ave_AF)]

    WeightedMeanFcn_CH4 = lambda x: np.sum(M_new[x, 18] * M_new[x, 2]) / np.sum(M_new[x, 2]) if np.sum(
        M_new[x, 2]) > 0 else 0
    bin_ave_CH4 = np.array([WeightedMeanFcn_CH4(np.where(ind == i)[0]) for i in range(len(edges_set) - 1)])

    # Prepare final bins_exp matrix
    bins_exp = np.zeros((len(edges_set) - 1, 18))
    bins_exp[:len(counts), 0] = counts
    bins_exp[:len(bin_ave_gas), 1] = bin_ave_gas
    bins_exp[:len(bin_sum_gas), 2] = bin_sum_gas
    bins_exp[:len(bin_sum_oilwg), 3] = bin_sum_oilwg
    bins_exp[:len(bin_ave_AF), 4:15] = bin_ave_AF
    bins_exp[:len(bin_sum_oilthru), 15] = bin_sum_oilthru
    bins_exp[:len(bin_sum_oilcontrol), 16] = bin_sum_oilcontrol
    bins_exp[:len(bin_ave_CH4), 17] = bin_ave_CH4

    return bins_exp, wellcounts
