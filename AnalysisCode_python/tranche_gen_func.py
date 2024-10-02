import numpy as np
import pandas as pd
import os
from di_scrubbing_func import di_scrubbing_func
from flaring_tranche import flaring_tranche
from OPGEE_rows_func import OPGEE_rows_func

def tranche_gen_func(i, Basin_Index, Basin_N, activityfolder, basinmapfolder, drillinginfofolder, DI_filename,
                     GHGRP_exp, Replicate):
    # Import LU Types for year 2015 based on 2020 GHGI
    filepath = os.path.join(os.getcwd(), activityfolder, 'LU_type.csv')
    LU_type = pd.read_csv(filepath, header=None).values

    if Replicate == 1:
        LU_type = np.array([0.1036, 0.0714, 0.825])
    else:
        LU_type = LU_type[i, :]

    if Replicate == 1:
        filepath = os.path.join(os.getcwd(), drillinginfofolder, 'david_lyon_2015_no_offshore.csv')
        M_in = pd.read_csv(filepath, header=None).values
    else:
        # Importing data for the distributions paper
        filepath = os.path.join(os.getcwd(), drillinginfofolder, DI_filename)
        DI_data = pd.read_csv(filepath)

        # Handling province code and extracting relevant data
        DI_data['Prov_Cod_1'] = DI_data['Prov_Cod_1'].replace('160A', '160')
        Basin_Name = pd.to_numeric(DI_data['Prov_Cod_1'], errors='coerce')

        # Note that although the headers in the file are “monthly oil” and “monthly gas”, these are summed across all months for 2020 so the units are “bbl/year” and “mscf/year”.

        Gas_Production = DI_data['Monthly_Ga'].fillna(0).values
        Oil_Production = DI_data['Monthly_Oi'].fillna(0).values

        Well_Count = np.ones(len(Basin_Name))
        logind = np.isin(Basin_Name, Basin_N[i])
        M_all = np.column_stack((Oil_Production, Gas_Production, Well_Count))
        M_in = M_all[logind]

    # Analysis

    plot_dat, Enverus_tab, OPGEE_bin = di_scrubbing_func(M_in, i, Basin_Index, activityfolder)

    if Replicate != 1:
        flare_tab = flaring_tranche(i, Basin_Index, Basin_N, OPGEE_bin, activityfolder)
    else:
        flare_tab = 0

    col_nums = list(range(4, 14)) + [16, 17]
    all_prod = []
    low_prod = []
    high_prod = []
    for j in range(12):
        all_prod.append(
            np.sum(GHGRP_exp[0:10, col_nums[j]] * OPGEE_bin['all'][0:10, 0]) / np.sum(OPGEE_bin['all'][0:10, 0]))
        low_prod.append(
            np.sum(GHGRP_exp[0:3, col_nums[j]] * OPGEE_bin['all'][0:3, 0]) / np.sum(OPGEE_bin['all'][0:3, 0]))
        high_prod.append(
            np.sum(GHGRP_exp[3:10, col_nums[j]] * OPGEE_bin['all'][3:10, 0]) / np.sum(OPGEE_bin['all'][3:10, 0]))

    AF_basin = np.array([all_prod, low_prod, high_prod])

    FileName = f'AF_{Basin_Index[i]}.xlsx'
    filepath = os.path.join(os.getcwd(), 'Outputs', FileName)
    pd.DataFrame(AF_basin).to_excel(filepath, index=False)

    low_prod_repeated = np.tile(low_prod, (3, 1))  # Repeat low_prod 3 times along rows
    high_prod_repeated = np.tile(high_prod, (7, 1))  # Repeat high_prod 7 times along rows

    OPGEE_bin['gasdry'] = np.hstack([OPGEE_bin['gasdry'], np.zeros((OPGEE_bin['gasdry'].shape[0], 16 - OPGEE_bin['gasdry'].shape[1]))])
    OPGEE_bin['gasassoc'] = np.hstack([OPGEE_bin['gasassoc'], np.zeros((OPGEE_bin['gasassoc'].shape[0], 16 - OPGEE_bin['gasassoc'].shape[1]))])
    OPGEE_bin['oilwgas'] = np.hstack([OPGEE_bin['oilwgas'], np.zeros((OPGEE_bin['oilwgas'].shape[0], 16 - OPGEE_bin['oilwgas'].shape[1]))])
    OPGEE_bin['oil'] = np.hstack([OPGEE_bin['oil'], np.zeros((OPGEE_bin['oil'].shape[0], 16 - OPGEE_bin['oil'].shape[1]))])

    OPGEE_bin['gasdry'][:, 4:16] = np.vstack([low_prod_repeated, high_prod_repeated])
    OPGEE_bin['gasassoc'][:, 4:16] = np.vstack([low_prod_repeated, high_prod_repeated])
    OPGEE_bin['oilwgas'][:, 4:16] = np.vstack([low_prod_repeated, high_prod_repeated])
    OPGEE_bin['oil'][:, 4:16] = np.vstack([low_prod_repeated, np.array(high_prod).reshape(1, -1)])

    tranche_OPGEE = OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab)

    # If replicating, load flaring data from file
    if i == -1:
        filepath = os.path.join(os.getcwd(), activityfolder, 'frac_wells_flaring.csv')
        frac_wells_flaring = pd.read_csv(filepath).values
        tranche_OPGEE[:, 5] = frac_wells_flaring
        df = pd.DataFrame(tranche_OPGEE)


    return tranche_OPGEE, OPGEE_bin, Enverus_tab, AF_basin

