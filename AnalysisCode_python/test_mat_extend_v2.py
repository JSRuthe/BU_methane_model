import numpy as np
import scipy.io
import os

# Fake data generation
def generate_fake_data():
    dataraw = np.array(
        [[1, 0.5, 2.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
         [2, 0.6, 3.0, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]])

    welldata = {
        'drygas': np.zeros((0, 2, 1)),
        'gaswoil': np.zeros((0, 2, 1)),
        'assoc': np.zeros((0, 2, 1)),
        'oil': np.zeros((0, 2, 1))
    }

    equipdata = {}

    Enverus_tab = np.array([[1, 2, 3, 4, 5],
                            [6, 7, 8, 9, 10],
                            [11, 12, 13, 14, 15],
                            [16, 17, 18, 19, 20],
                            [21, 22, 23, 24, 25],
                            [26, 27, 28, 29, 30],
                            [31, 32, 33, 34, 35],
                            [36, 37, 38, 39, 40],
                            [41, 42, 43, 44, 45],
                            [46, 47, 48, 49, 50]])

    AF_basin = np.array([[1, 2, 3, 4, 5, 6, 7]])

    k = 0
    welloption = 1
    equipoption = 1
    activityfolder = ""
    Basin_Select = 0

    # Display values
    print('dataraw:', dataraw)
    print('welldata:', welldata)
    print('equipdata:', equipdata)
    print('Enverus_tab:', Enverus_tab)
    print('AF_basin:', AF_basin)

    return dataraw, welldata, equipdata, Enverus_tab, AF_basin

# Python version of the function mat_extend_v2
def mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab, AF_basin):
    data = dataraw
    rows, columns = data.shape
    print('rows', rows)
    print('columns', columns)

    gas_rows = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20]
    oil_rows = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20]

    Gas_workovers = 2.3 / 1000
    Gas_completions = 34.0 / 1000
    Oil_workovers = 0 / 1000
    Oil_completions = 68.5 / 1000
    Gas_Combustion = 0.0983

    firstrow = False
    matpartextend_full = None

    for i in range(60):
        matpart = data[data[:, 0] == i, :]
        m, n = matpart.shape

        if m > 0:
            len_ext = int(np.ceil(matpart[0, 2] * m))
            matpartextend = np.tile(matpart, (int(np.ceil(len_ext / m)), 1))
            matpartextend = matpartextend[:len_ext, :]

        if m > 0 and not firstrow:
            matpartextend_full = matpartextend
            firstrow = True
        elif m > 0 and firstrow:
            matpartextend_full = np.vstack([matpartextend_full, matpartextend])

    data = matpartextend_full
    dataplot_gas = np.column_stack((data, np.sum(data[:, 5:21], axis=1)))
    dataplot_gas = np.column_stack((dataplot_gas, dataplot_gas[:, -1] / dataplot_gas[:, 3]))

    dataplot_drygas = dataplot_gas[dataplot_gas[:, 0] < 31, :]
    dataplot_gaswoil = dataplot_gas[(dataplot_gas[:, 0] > 30) & (dataplot_gas[:, 0] < 61), :]

    ContributionPerc5 = np.zeros(34)
    SumEmissions = np.zeros(34)

    counter = 0
    for i in range(17):
        if i < 14:
            index = i + 5
        elif i == 14:
            index = 98
        else:
            index = i + 4

        if index in gas_rows:
            counter += 1
            equip_emissions = data[:, gas_rows[counter - 1]]
            equip_emissions = equip_emissions[equip_emissions != 0]
            if len(equip_emissions) > 0:
                SortC = np.sort(equip_emissions)[::-1]
                SumC = np.nansum(equip_emissions)
                CumC = np.cumsum(SortC)
                Perc5Location = int(np.ceil(len(equip_emissions) * 0.05))
                ContributionPerc5[i] = CumC[Perc5Location]
                SumEmissions[i] = np.sum(equip_emissions)

    Study_Gas = SumEmissions[:17] * 365 / 10**9
    Study_Oil = SumEmissions[17:] * 365 / 10**9

    Study_Gas[12] = Gas_completions
    Study_Gas[13] = Gas_workovers
    Study_Gas[14] = Gas_Combustion

    Study_Oil[12] = Oil_completions
    Study_Oil[13] = Oil_workovers

    EF = np.range(100)  # Fake EF data

    gas_length = len(dataplot_drygas) + len(dataplot_gaswoil)
    if gas_length > len(EF):
        addlength = gas_length - len(EF)
        EF = np.hstack([EF, np.zeros(addlength)])
    else:
        EF = np.random.choice(EF, gas_length, replace=False)

    if k == 0:
        if welloption == 1:
            welldata['drygas'] = dataplot_drygas[:, [0, 21]].reshape(-1, 2, 1)
            welldata['gaswoil'] = dataplot_gaswoil[:, [0, 21]].reshape(-1, 2, 1)
            welldata['drygas'][:, 1, 0] += EF[:len(dataplot_drygas)]
            welldata['gaswoil'][:, 1, 0] += EF[len(dataplot_drygas):]
            print('EF:', EF)
            print('welldata["drygas"] after EF addition:', welldata['drygas'])
            print('welldata["gaswoil"] after EF addition:', welldata['gaswoil'])


    else:
        if welloption == 1:
            welldata['drygas'] = np.concatenate((welldata['drygas'], dataplot_drygas[:, [0, 21]].reshape(-1, 2, 1)), axis=2)
            welldata['gaswoil'] = np.concatenate((welldata['gaswoil'], dataplot_gaswoil[:, [0, 21]].reshape(-1, 2, 1)), axis=2)
            welldata['drygas'][:, 1, k] += EF[:len(dataplot_drygas)]
            welldata['gaswoil'][:, 1, k] += EF[len(dataplot_drygas):]

    Study_All = np.column_stack([Study_Gas, Study_Oil])

    EmissionsGas = Study_All[:, 0]
    EmissionsOil = Study_All[:, 1]

    Superemitters = np.sum(ContributionPerc5) * 365 / 10**9
    print('Shape of dataplot_drygas:', dataplot_drygas.shape)
    print('Shape of welldata["drygas"]:', welldata['drygas'].shape)
    return EmissionsGas, EmissionsOil, Superemitters, welldata, equipdata


# Testing the function with fake data
dataraw, welldata, equipdata, Enverus_tab, AF_basin = generate_fake_data()
k = 0
welloption = 1
equipoption = 1
activityfolder = ""
Basin_Select = 0

EmissionsGas, EmissionsOil, Superemitters, welldata, equipdata = mat_extend_v2(dataraw, welldata, equipdata, k, welloption, equipoption, activityfolder, Basin_Select, Enverus_tab, AF_basin)

print("EmissionsGas:", EmissionsGas)
print("EmissionsOil:", EmissionsOil)
print("Superemitters:", Superemitters)
print("welldatadrygas", welldata['drygas'])
