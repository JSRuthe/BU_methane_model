import numpy as np
import pandas as pd
from scipy.io import loadmat
import os
import time

def mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab, AF_basin):
    # np.random.seed(k)
    data = dataraw
    rows, columns = data.shape

    # Assuming gas_rows and oil_rows are 0-indexed
    gas_rows = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 19, 20]  # Adjusted for Python (MATLAB - 1)
    oil_rows = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 19, 20]  # Adjusted for Python (MATLAB - 1)

    # Replace completions and workovers with non-flaring C&W from GHGRP_Master
    Gas = {'workovers': 2.3 / 1000, 'completions': 34.0 / 1000, 'Combustion': 0.0983}  # Tg/year
    Oil = {'workovers': 0 / 1000, 'completions': 68.5 / 1000}  # Tg/year

    # EXTEND MATRIX for gas data
    firstrow = False
    matpartextend_full = None
    for i in range(60):
        matpart = data[data[:, 0] == i]
        m, n = matpart.shape

        if m > 0:
            len_ext = int(np.ceil(matpart[0, 2] * m))
            matpartextend = np.tile(matpart, (int(np.ceil(len_ext / m)), 1))
            matpartextend = matpartextend[:len_ext, :]

        if m > 0 and not firstrow:
            matpartextend_full = matpartextend
            firstrow = True
        elif m > 0 and firstrow:
            if matpartextend_full.shape[1] == matpartextend.shape[1]:
                matpartextend_full = np.vstack([matpartextend_full, matpartextend])
            else:
                print(
                    f"Shape mismatch: matpartextend_full.shape={matpartextend_full.shape}, matpartextend.shape={matpartextend.shape}")
                raise ValueError("Cannot concatenate matrices due to shape mismatch.")

    # Emissions matrix for gas
    data = matpartextend_full

    dataplot_gas = np.hstack([data, np.sum(data[:, 5:21], axis=1, keepdims=True)])
    dataplot_gas = np.hstack([dataplot_gas, (dataplot_gas[:, 21] / dataplot_gas[:, 3]).reshape(-1, 1)])

    # Split data into drygas and gaswoil
    dataplot_drygas = dataplot_gas[dataplot_gas[:, 0] < 30]
    dataplot_gaswoil = dataplot_gas[(dataplot_gas[:, 0] > 29) & (dataplot_gas[:, 0] < 60)]


    # Process emissions for gas
    counter = 0
    # Initialize counters and arrays
    ContributionPerc5 = np.zeros(34)
    ContributionPerc5Norm = np.zeros(34)  # Add this line
    SumEmissions = np.zeros(34)
    Minimum = np.zeros(34)  # If not already defined elsewhere, you should define this as well
    Maximum = np.zeros(34)  # If not already defined elsewhere, you should define this as well
    Average = np.zeros(34)  # If not already defined elsewhere, you should define this as well
    MedC = np.zeros(34)  # If not already defined elsewhere, you should define this as well
    for i in range(17):  # MATLAB 1:17 -> Python 0:16
        if i < 14:
            index = i + 5
        elif i == 14:
            index = 98  # No need to subtract here
        else:
            index = i + 4

        if index in gas_rows:
            counter += 1
            equip_emissions = data[:, gas_rows[counter - 1]]
            equip_emissions = equip_emissions[equip_emissions != 0]
            if equip_emissions.size > 0:
                SortC = np.sort(equip_emissions)[::-1]  # Sort descending
                SumC = np.nansum(equip_emissions)
                NormSortC = SortC / SumC
                CumCNorm = np.cumsum(NormSortC)
                CumC = np.cumsum(SortC)
                Perc5Location = int(np.ceil(len(equip_emissions) * 0.05))

                # Parameters
                ContributionPerc5[i] = CumC[Perc5Location - 1]
                ContributionPerc5Norm[i] = CumCNorm[Perc5Location - 1]
                Minimum[i] = np.min(equip_emissions)
                Maximum[i] = np.max(equip_emissions)
                Average[i] = np.mean(equip_emissions)
                MedC[i] = np.median(equip_emissions)
                SumEmissions[i] = np.sum(equip_emissions)

    # EXTEND MATRIX for oil data
    data = dataraw
    firstrow = False
    matpartextend_full = None

    for i in range(60, 74):
        matpart = data[data[:, 0] == i]
        m, n = matpart.shape

        if m > 0:
            len_ext = int(np.ceil(matpart[0, 2] * m))
            matpartextend = np.tile(matpart, (int(np.ceil(len_ext / m)), 1))
            matpartextend = matpartextend[:len_ext, :]

        if m > 0 and not firstrow:
            matpartextend_full = matpartextend
            firstrow = True
        elif m > 0 and firstrow:
            if matpartextend_full.shape[1] == matpartextend.shape[1]:
                matpartextend_full = np.vstack([matpartextend_full, matpartextend])
            else:
                print(
                    f"Dimension mismatch: matpartextend_full.shape={matpartextend_full.shape}, matpartextend.shape={matpartextend.shape}")
                raise ValueError("Cannot concatenate matrices due to shape mismatch.")

    # Emissions matrix for oil
    data = matpartextend_full
    dataplot_assoc = data[(data[:, 0] < 70) & (data[:, 0] > 59), :]
    dataplot_assoc = np.hstack([dataplot_assoc, np.sum(dataplot_assoc[:, 5:21], axis=1, keepdims=True)])
    dataplot_assoc = np.hstack([dataplot_assoc, (dataplot_assoc[:, 21] / dataplot_assoc[:, 3]).reshape(-1, 1)])
    dataplot_oil = data[data[:, 0] > 69, :]
    dataplot_oil = np.hstack([dataplot_oil, np.sum(dataplot_oil[:, 5:21], axis=1, keepdims=True)])
    dataplot_oil = np.hstack([dataplot_oil, (dataplot_oil[:, 21] / dataplot_oil[:, 3]).reshape(-1, 1)])


    # Process emissions for oil
    counter = 0
    for i in range(17):
        if i < 14:
            index = i + 5
        elif i == 14:
            index = 98
        else:
            index = i + 4

        if index in oil_rows:
            counter += 1
            equip_emissions = data[:, oil_rows[counter - 1]]
            equip_emissions = equip_emissions[equip_emissions != 0]
            if equip_emissions.size > 0:
                SortC = np.sort(equip_emissions)[::-1]
                SumC = np.nansum(equip_emissions)
                NormSortC = SortC / SumC
                CumCNorm = np.cumsum(NormSortC)
                CumC = np.cumsum(SortC)
                Perc5Location = int(np.ceil(len(equip_emissions) * 0.05))

                # Parameters
                ContributionPerc5[i + 17] = CumC[Perc5Location - 1]
                ContributionPerc5Norm[i + 17] = CumCNorm[Perc5Location - 1]
                Minimum[i + 17] = np.min(equip_emissions)
                Maximum[i + 17] = np.max(equip_emissions)
                Average[i + 17] = np.mean(equip_emissions)
                MedC[i + 17] = np.median(equip_emissions)
                SumEmissions[i + 17] = np.sum(equip_emissions)

    # Convert data from kg/day to Tg/year
    Study_Gas = SumEmissions[:17] * 365 / 10 ** 9
    Superemitters = np.sum(ContributionPerc5) * 365 / 10 ** 9
    Study_Oil = SumEmissions[17:] * 365 / 10 ** 9

    # Replace completions and workovers with gas and oil values
    Study_Gas[12] = Gas['completions']
    Study_Gas[13] = Gas['workovers']
    Study_Gas[14] = Gas['Combustion']
    Study_Oil[12] = Oil['completions']
    Study_Oil[13] = Oil['workovers']

    filepath = os.path.join(os.getcwd(), activityfolder, 'EF_Comp_v2.mat')

    # Load the .mat file (assuming EF is stored in the file)
    mat_data = loadmat(filepath)
    EF = mat_data['EF'].flatten()  # Assuming EF is stored in the .mat file as a column vector

    if Basin_Select != -1:
        # Calculate the number of compressors
        n_compressors = AF_basin[0, 6] * (
                len(dataplot_drygas) + len(dataplot_gaswoil) +
                len(dataplot_assoc) + len(dataplot_oil)
        )

        if n_compressors < 35298:  # Number of compressors in US (Rutherford et al 2021)
            newlength = len(EF) * (n_compressors / 35298)
            newlength = round(newlength)
            newlength = int(newlength)

            # Shuffle EF using random values

            # If we want to be able to compare to Matlab
            # len_EF = len(EF)
            # random_values = np.zeros(len_EF, dtype=int)
            # for i in range(len_EF):
            #     random_values[i] = int(np.random.rand() * len_EF)
            # EF = EF[random_values]
            # EF = EF[:newlength]

            # Otherwise
            EF = EF[np.random.choice(len(EF), size=newlength, replace=True)]

    # Calculate gas_length
    gas_length = len(dataplot_drygas) + len(dataplot_gaswoil)

    if gas_length > len(EF):
        # If gas_length is greater, extend EF with zeros
        addlength = len(dataplot_drygas) + len(dataplot_gaswoil)
        EF = np.concatenate([EF, np.zeros(addlength - len(EF))])
    else:
        # Shuffle EF using random values

        # If we want to be able to compare to Matlab
        # len_EF = len(EF)
        # random_values = np.zeros(len_EF, dtype=int)
        # for i in range(len_EF):
        #     random_values[i] = int(np.random.rand() * len_EF)
        # EF = EF[random_values]
        # EF = EF[:gas_length]

        # Otherwise
        EF = EF[np.random.choice(len(EF), size=gas_length, replace=True)]


    # Final shuffle of EF

    # If we want to be able to compare to Matlab
    # len_EF = len(EF)
    # random_values = np.zeros(len_EF, dtype=int)
    # for i in range(len_EF):
    #     random_values[i] = int(np.random.rand() * len_EF)
    # EF = EF[random_values]

    # Otherwise
    EF = EF[np.random.permutation(len(EF))]

    # Handle the welldata and equipdata with conditions for k == 0
    if k == 0:
        if welloption == 1:
            # Initialize welldata for k == 0
            welldata['drygas'] = dataplot_drygas[:, [0, 21]]
            welldata['gaswoil'] = dataplot_gaswoil[:, [0, 21]]

            # Update welldata with EF values
            welldata['drygas'][:, 1] += EF[:len(dataplot_drygas)]
            welldata['gaswoil'][:, 1] += EF[len(dataplot_drygas):]

            # Calculate Gas.Combustion using EF
            Gas_Combustion = np.sum(EF) * 365 / 10 ** 9  # Tg/year
            Study_Gas[14] = Gas_Combustion

            # Initialize associated and oil data in welldata
            welldata['assoc'] = dataplot_assoc[:, [0, 21]]
            welldata['oil'] = dataplot_oil[:, [0, 21]]

    else:
        if welloption == 1:

            # Append data for k != 0
            welldata['drygas'] = np.concatenate(
                (welldata['drygas'], dataplot_drygas[:, [0, 21]].reshape(-1, 2, 1)), axis=2)
            welldata['gaswoil'] = np.concatenate(
                (welldata['gaswoil'], dataplot_gaswoil[:, [0, 21]].reshape(-1, 2, 1)), axis=2)

            # Update welldata with EF values for current iteration k
            welldata['drygas'][:, 1, k] += EF[:len(dataplot_drygas)]
            welldata['gaswoil'][:, 1, k] += EF[len(dataplot_drygas):]



            # Calculate Gas.Combustion using EF
            Gas_Combustion = np.sum(EF) * 365 / 10 ** 9  # Tg/year
            Study_Gas[14] = Gas_Combustion

            # Append associated and oil data in welldata for current iteration k
            welldata['assoc'] = np.concatenate(
                (welldata['assoc'], dataplot_assoc[:, [0, 21]].reshape(-1, 2, 1)), axis=2)
            welldata['oil'] = np.concatenate(
                (welldata['oil'], dataplot_oil[:, [0, 21]].reshape(-1, 2, 1)), axis=2)

    # Create Study_All matrix
    Study_All = np.vstack((Study_Gas, Study_Oil)).T
    EmissionsGas = Study_All[:, 0]
    EmissionsOil = Study_All[:, 1]

    # Calculate total emissions
    total_gas_emissions = np.sum(EmissionsGas[0:12]) + np.sum(EmissionsGas[14:17])
    total_oil_emissions = np.sum(EmissionsOil[0:12]) + np.sum(EmissionsOil[14:17])
    print(f"Emissions for k = {k}")
    print(f"Total Gas Emissions: {total_gas_emissions}")
    print(f"Total Oil Emissions: {total_oil_emissions}")

    # Calculate total oil and gas production for print
    printtotal_mmbbl = (np.sum(dataplot_drygas[:, 1]) + np.sum(dataplot_gaswoil[:, 1]) +
                        np.sum(dataplot_assoc[:, 1]) + np.sum(dataplot_oil[:, 1])) * 365 / 1000000
    printtotal_Bscf = (np.sum(dataplot_drygas[:, 4]) + np.sum(dataplot_gaswoil[:, 4]) +
                       np.sum(dataplot_assoc[:, 4]) + np.sum(dataplot_oil[:, 4])) * 365 / 10 ** 9


    # Handle equipoption and equipdata
    if equipoption == 1:
        equipdata['drygas'] = np.column_stack([dataplot_drygas[:, 5:21], dataplot_drygas[:, [0, 3, 4]]])
        equipdata['gaswoil'] = np.column_stack([dataplot_gaswoil[:, 5:21], dataplot_gaswoil[:, [0, 3, 4]]])
        equipdata['assoc'] = np.column_stack([dataplot_assoc[:, 5:21], dataplot_assoc[:, [0, 3, 4]]])
        equipdata['oil'] = np.column_stack([dataplot_oil[:, 5:21], dataplot_oil[:, [0, 3, 4]]])


    return EmissionsGas, EmissionsOil, Superemitters, welldata, equipdata

