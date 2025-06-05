import os
import numpy as np
import pandas as pd
import warnings
from tranche_data import *
from mat_extend_v2 import *
warnings.filterwarnings('ignore')
from wellpersite_func import *

def data_proc_master_func(year, n_trial, welloption, equipoption, Basin_Select, Basin_Index, activityfolder,
                          productionfolder, Enverus_tab, AF_basin):


    welldata = {'drygas': np.zeros((1, 1)), 'gaswoil': np.zeros((1, 1)), 'assoc': np.zeros((1, 1)),
                'oil': np.zeros((1, 1))}
    equipdata = {'drygas': np.zeros((1, 1)), 'gaswoil': np.zeros((1, 1)), 'assoc': np.zeros((1, 1)),
                 'oil': np.zeros((1, 1))}

    equipdata_tot = {'drygas': None, 'gaswoil': None, 'assoc': None, 'oil': None}
    gasvectot = np.zeros((1, 1))
    oilvectot = np.zeros((1, 1))

    EmissionsGas = np.empty((0,0))
    EmissionsOil = np.empty((0,0))
    Superemitters = []

    counter = 0

    if welloption == 1:
        tranche = tranche_data(productionfolder)

    for k in range(n_trial):
        # Read data files
        if Basin_Select == -1:
            csv_file = f'Equip_{k + 1}_out.csv'
        else:
            csv_file = f'Equip_{k + 1}_{Basin_Index[Basin_Select]}_{year}_out.csv'
        filepath = os.path.join('Outputs', csv_file)
        print(filepath)

        dataraw = pd.read_csv(filepath, header=None).values

        counter += 1

        # Extend matrix for emissions and equipment data
        emissions_gas, emissions_oil, superemitters, welldata, equipdata = mat_extend_v2(
            dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab,
            AF_basin
        )
        if EmissionsGas.shape[0] < len(emissions_gas):
            if EmissionsGas.size == 0:
                EmissionsGas = np.zeros((len(emissions_gas), 1))
            else:
                EmissionsGas = np.vstack(
                    [EmissionsGas, np.zeros((len(emissions_gas) - EmissionsGas.shape[0], EmissionsGas.shape[1]))])

        EmissionsGas = np.hstack((EmissionsGas, np.zeros((EmissionsGas.shape[0], 1))))  # Add a new column
        EmissionsGas[:, counter] = emissions_gas

        if EmissionsOil.shape[0] < len(emissions_oil):
            if EmissionsOil.size == 0:
                EmissionsOil = np.zeros((len(emissions_oil), 1))
            else:
                EmissionsOil = np.vstack(
                    [EmissionsOil, np.zeros((len(emissions_oil) - EmissionsOil.shape[0], EmissionsOil.shape[1]))])

        EmissionsOil = np.hstack((EmissionsOil, np.zeros((EmissionsOil.shape[0], 1))))
        EmissionsOil[:, counter] = emissions_oil
        Superemitters.append(0)
        Superemitters[counter - 1] = superemitters

        if welloption == 1:
            if Basin_Select != -1:
                print(f'Basin {Basin_Index[Basin_Select]}, site iter {k + 1}...')
            sitedata = wellpersite_func(welldata, tranche, k, AF_basin)
            print(
                f'Sitedata, {k + 1}, Total gas = {(sum(sitedata["drygas"]) + sum(sitedata["gaswoil"]) + sum(sitedata["assoc"]) + sum(sitedata["oil"])) * 365 / 1e9}')

            sitedata_All = []
            if np.any(sitedata['drygas']):
                sitedata_All.append(sitedata['drygas'])

            if np.any(sitedata['gaswoil']):
                sitedata_All.append(sitedata['gaswoil'])

            if np.any(sitedata['assoc']):
                sitedata_All.append(sitedata['assoc'])

            if np.any(sitedata['oil']):
                sitedata_All.append(sitedata['oil'])

            sitedata_All = np.vstack(sitedata_All)

            if Basin_Select == -1:
                file_name = f'sitedata{k + 1}.csv'
            else:
                file_name = f'sitedata_{Basin_Index[Basin_Select]}{k + 1}.csv'

            output_filepath = os.path.join(os.getcwd(), 'Outputs', file_name)
            pd.DataFrame(sitedata_All).to_csv(output_filepath, index=False)

        if equipoption == 1:
            equipdata_tot['drygas'] = equipdata['drygas'] if equipdata_tot['drygas'] is None else np.concatenate(
                (equipdata_tot['drygas'], equipdata['drygas']), axis=2)
            equipdata_tot['gaswoil'] = equipdata['gaswoil'] if equipdata_tot['gaswoil'] is None else np.concatenate(
                (equipdata_tot['gaswoil'], equipdata['gaswoil']), axis=2)
            equipdata_tot['assoc'] = equipdata['assoc'] if equipdata_tot['assoc'] is None else np.concatenate(
                (equipdata_tot['assoc'], equipdata['assoc']), axis=2)
            equipdata_tot['oil'] = equipdata['oil'] if equipdata_tot['oil'] is None else np.concatenate(
                (equipdata_tot['oil'], equipdata['oil']), axis=2)

    # Prepare emission summary table
    Equip_List = ['Wells', 'Header', 'Heater', 'Separators', 'Meter', 'Tanks - leaks', 'Tanks - vents',
                  'Recip Compressor', 'Dehydrators', 'CIP', 'PC', 'LU', 'Completions', 'Workovers',
                  'Combustion', 'Tank Venting', 'Flare methane']
    EmissionsOil = EmissionsOil[:, 1:]
    EmissionsGas = EmissionsGas[:, 1:]


    data_tab = pd.DataFrame(index=np.arange(1, 18), columns=['Equipment', 'Gas sites', 'Oil sites'])

    data_tab.loc[0, 'Gas sites'] = 'Gas sites'
    data_tab.loc[0, 'Oil sites'] = 'Oil sites'
    for i in range(1, 18):
        data_tab.loc[i, 'Equipment'] = Equip_List[i - 1]
        data_tab.loc[i, 'Gas sites'] = np.mean(EmissionsGas[i - 1, :])
        data_tab.loc[i, 'Oil sites'] = np.mean(EmissionsOil[i - 1, :])

    if Basin_Select == -1:
        file_name = f'Emission_Summary_{year}_out.xlsx'
    else:
        file_name = f'Emission_Summary_{Basin_Index[Basin_Select]}_{year}_out.xlsx'

    output_filepath = os.path.join(os.getcwd(), 'Outputs', file_name)
    data_tab.to_excel(output_filepath, index=False)

    # Save Emissions data
    emissions_file = 'Emissionsdata_out.npz' if Basin_Select == -1 else f'Emissiondata_{Basin_Index[Basin_Select]}_{year}_out.npz'
    emissions_filepath = os.path.join('Outputs', emissions_file)
    np.savez(emissions_filepath, EmissionsGas=EmissionsGas, EmissionsOil=EmissionsOil)

    return equipdata_tot

