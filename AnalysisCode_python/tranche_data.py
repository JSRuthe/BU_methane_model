import numpy as np
import pandas as pd
import os
def tranche_data(drillinginfofolder):
    cutoff = 100  # Mscf/bbl
    # Load the data from the CSV file
    csvFileName = 'david_lyon_2015_no_offshore.csv'
    filepath = f"{drillinginfofolder}/{csvFileName}"
    M_raw = pd.read_csv(filepath, header=None).values

    # Remove specific rows based on well counts
    remove_well_counts = [10453, 4625, 4536, 1157, 1088, 1046]
    M_raw = M_raw[~np.isin(M_raw[:, 2], remove_well_counts)]

    # Convert from annual to daily basis for oil (col 1) and gas (col 2)
    M_raw[:, 0] = M_raw[:, 0] / 365.25  # Oil production
    M_raw[:, 1] = M_raw[:, 1] / 365.25  # Gas production

    # Set values less than or equal to zero to a very small value (99e-8)
    M_raw[M_raw <= 0] = 99e-8

    size_mat = M_raw.shape[0]

    GOR = M_raw[:, 1] / M_raw[:, 0]  # Gas production / Oil production
    Per_Well_Prod = M_raw[:, 1] / M_raw[:, 2]  # Gas production / Well count

    # Add GOR and Per_Well_Prod as new columns to the dataset
    M_raw = np.column_stack((M_raw, GOR, Per_Well_Prod))

    logind = np.zeros((size_mat, 7))

    # Classify no production wells
    logind[:, 6] = (M_raw[:, 1] == 99e-8) & (M_raw[:, 0] == 99e-8)

    # Classify "gas only" wells
    logind[:, 0] = (M_raw[:, 3] > cutoff) & (M_raw[:, 0] == 99e-8) & (logind[:, 6] != 1)

    # Classify "oil only" wells
    logind[:, 1] = (M_raw[:, 3] < cutoff) & (M_raw[:, 1] == 99e-8) & (logind[:, 6] != 1)

    # Classify "gas with oil" wells
    logind[:, 2] = (M_raw[:, 3] > cutoff) & (M_raw[:, 0] != 99e-8) & (logind[:, 6] != 1)

    # Classify "oil with gas" wells
    logind[:, 3] = (M_raw[:, 3] < cutoff) & (M_raw[:, 1] != 99e-8) & (logind[:, 6] != 1)

    tranche = {}

    ### Dry gas from gas wells ###
    ind_drygas = logind[:, 0].astype(int)
    M_drygas = M_raw[ind_drygas == 1, :]

    tranche['i1'] = M_drygas[M_drygas[:, 4] < 1, :]
    tranche['i2'] = M_drygas[(M_drygas[:, 4] > 1) & (M_drygas[:, 4] < 5), :]
    tranche['i3'] = M_drygas[(M_drygas[:, 4] > 5) & (M_drygas[:, 4] < 10), :]
    tranche['i4'] = M_drygas[(M_drygas[:, 4] > 10) & (M_drygas[:, 4] < 20), :]
    tranche['i5'] = M_drygas[(M_drygas[:, 4] > 20) & (M_drygas[:, 4] < 50), :]
    tranche['i6'] = M_drygas[(M_drygas[:, 4] > 50) & (M_drygas[:, 4] < 100), :]
    tranche['i7'] = M_drygas[(M_drygas[:, 4] > 100) & (M_drygas[:, 4] < 500), :]
    tranche['i8'] = M_drygas[(M_drygas[:, 4] > 500) & (M_drygas[:, 4] < 1000), :]
    tranche['i9'] = M_drygas[(M_drygas[:, 4] > 1000) & (M_drygas[:, 4] < 10000), :]
    tranche['i10'] = M_drygas[M_drygas[:, 4] > 10000, :]

    ### Gas with associated oil ###
    ind_gaswoil = logind[:, 2].astype(int)
    M_gaswoil = M_raw[ind_gaswoil == 1, :]

    tranche['i11'] = M_gaswoil[M_gaswoil[:, 4] < 1, :]
    tranche['i12'] = M_gaswoil[(M_gaswoil[:, 4] > 1) & (M_gaswoil[:, 4] < 5), :]
    tranche['i13'] = M_gaswoil[(M_gaswoil[:, 4] > 5) & (M_gaswoil[:, 4] < 10), :]
    tranche['i14'] = M_gaswoil[(M_gaswoil[:, 4] > 10) & (M_gaswoil[:, 4] < 20), :]
    tranche['i15'] = M_gaswoil[(M_gaswoil[:, 4] > 20) & (M_gaswoil[:, 4] < 50), :]
    tranche['i16'] = M_gaswoil[(M_gaswoil[:, 4] > 50) & (M_gaswoil[:, 4] < 100), :]
    tranche['i17'] = M_gaswoil[(M_gaswoil[:, 4] > 100) & (M_gaswoil[:, 4] < 500), :]
    tranche['i18'] = M_gaswoil[(M_gaswoil[:, 4] > 500) & (M_gaswoil[:, 4] < 1000), :]
    tranche['i19'] = M_gaswoil[(M_gaswoil[:, 4] > 1000) & (M_gaswoil[:, 4] < 10000), :]
    tranche['i20'] = M_gaswoil[M_gaswoil[:, 4] > 10000, :]

    ### Oil only ###
    ind_oil = logind[:, 1].astype(int)
    M_oil = M_raw[ind_oil == 1, :]

    tranche['i31'] = M_oil[M_oil[:, 4] < 0.5, :]
    tranche['i32'] = M_oil[(M_oil[:, 4] > 0.5) & (M_oil[:, 4] < 1), :]
    tranche['i33'] = M_oil[(M_oil[:, 4] > 1) & (M_oil[:, 4] < 10), :]
    tranche['i34'] = M_oil[M_oil[:, 4] > 10, :]

    ### Oil with gas ###
    ind_oilwgas = logind[:, 3].astype(int)
    M_oilwgas = M_raw[ind_oilwgas == 1, :]

    tranche['i21'] = M_oilwgas[M_oilwgas[:, 4] < 1, :]
    tranche['i22'] = M_oilwgas[(M_oilwgas[:, 4] > 1) & (M_oilwgas[:, 4] < 5), :]
    tranche['i23'] = M_oilwgas[(M_oilwgas[:, 4] > 5) & (M_oilwgas[:, 4] < 10), :]
    tranche['i24'] = M_oilwgas[(M_oilwgas[:, 4] > 10) & (M_oilwgas[:, 4] < 20), :]
    tranche['i25'] = M_oilwgas[(M_oilwgas[:, 4] > 20) & (M_oilwgas[:, 4] < 50), :]
    tranche['i26'] = M_oilwgas[(M_oilwgas[:, 4] > 50) & (M_oilwgas[:, 4] < 100), :]
    tranche['i27'] = M_oilwgas[(M_oilwgas[:, 4] > 100) & (M_oilwgas[:, 4] < 500), :]
    tranche['i28'] = M_oilwgas[(M_oilwgas[:, 4] > 500) & (M_oilwgas[:, 4] < 1000), :]
    tranche['i29'] = M_oilwgas[(M_oilwgas[:, 4] > 1000) & (M_oilwgas[:, 4] < 10000), :]
    tranche['i30'] = M_oilwgas[M_oilwgas[:, 4] > 10000, :]

    return tranche
