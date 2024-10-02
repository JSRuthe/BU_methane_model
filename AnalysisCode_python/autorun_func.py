import os
import numpy as np
import pandas as pd
from fugitives_v2 import *
import warnings
warnings.filterwarnings('ignore')

def autorun_func(n_trial, Activity_tranches, Basin_Select, Basin_Index, activityfolder, distributionsfolder, AF_overwrite, AF):
    n = {
        'fields': Activity_tranches.shape[1],
        'sample': 500,  # Upper limit on the number of wells the code will process
        'rows': 20,
        'wellpad': 16,
        'offsite': 4
    }

    # The maximum number of iterations that are to proceed if mass balance is not achieved
    maxit = 500

    # Import input datasets
    emissions = {}
    emissions['LU'] = pd.read_csv(os.path.join(os.getcwd(), activityfolder, 'LiquidsUnloadings.csv'), header=None).values
    emissions['HARC'] = pd.read_csv(os.path.join(os.getcwd(), activityfolder, 'HARC.csv'), header=None).values
    emissions['gvakharia'] = pd.read_csv(os.path.join(os.getcwd(), activityfolder, 'gvakharia.csv'), header=None).values[0]

    Activity = {
        'prod_bbl': Activity_tranches[0, :],  # bbl/day
        'wells': Activity_tranches[1, :],  # number of wells
        'frac_C1': Activity_tranches[2, :],  # molar percent (0 - 100)
        'GOR': Activity_tranches[3, :],  # scf/bbl
        'LU': Activity_tranches[4, :],  # integer from 0-2
        'frac_wells_flaring': Activity_tranches[5, :],  # fraction of wells flaring
    }

    Activity['prod_scf'] = Activity['prod_bbl'] * Activity['GOR']  # scf/day
    Activity['prod_kg'] = Activity['prod_scf'] * ((16.041 * 1.20233 * (Activity['frac_C1'] / 100)) / 1000)  # kg CH4/day
    Activity['AF'] = Activity_tranches[6:17, :]

    for i in range(n_trial):
        equip_gas_file = f'EquipGas{i + 1}.csv'
        equip_oil_file = f'EquipOil{i + 1}.csv'

        equip_gas = pd.read_csv(os.path.join(os.getcwd(), distributionsfolder, equip_gas_file), header=None)
        equip_oil = pd.read_csv(os.path.join(os.getcwd(), distributionsfolder, equip_oil_file), header=None)
        equip_gas = equip_gas.values
        equip_oil = equip_oil.values

        # Initialize Data_Out (equivalent to MATLAB's initialization of `Data_Out`)
        Data_Out = np.zeros((1, 1))
        # Perform calculations using the `fugitives_v2` macro for each field (matching MATLAB logic)
        for j in range(n['fields']):

            if j == 0:
                Data_Out = np.zeros((1, 1))  # Reset Data_Out for the first field

            # `n['rows']` now replaces the first argument, aligning with MATLAB's `fugitives_v2(n, ...)` usage
            Data_Out = fugitives_v2(n, j, maxit, Activity, emissions, equip_gas, equip_oil, Data_Out, Basin_Select, activityfolder, AF_overwrite, AF)

        # Save output based on `Basin_Select`
        if Basin_Select == -1:
            output_filename = f'Equip{i + 1}out.csv'
        else:
            output_filename = f'Equip{i + 1}{Basin_Index[Basin_Select]}out.csv'

        output_filepath = os.path.join(os.getcwd(), 'Outputs', output_filename)
        np.savetxt(output_filepath, Data_Out, delimiter=',')
