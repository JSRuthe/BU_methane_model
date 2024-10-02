import numpy as np
import pandas as pd
import random
from liquidsunloadings import *
from flashing import *
from flaring import *
import warnings
warnings.filterwarnings('ignore')
import time
import copy
def fugitives_v2(n, j, maxit, Activity, Emissions, EquipGas, EquipOil, Data_Out, Basin_Select, activityfolder, AF_overwrite, AF):
    """
    This function estimates methane emissions at the equipment level for gas and oil wells.
    """
    local_activity = copy.deepcopy(Activity)
    # Determine activity factors based on Basin_Select and AF_overwrite
    if Basin_Select == -1:
        # Default activity factors for Gas and Oil
        if AF_overwrite == 0:
            AF['Gas'] = np.array([1, 0, 0.1321, 0.7102, 0.8399, 0.40570, 0.40570, 0.0814, 0.02987, 0.2023, 1.8743])
            AF['Oil'] = np.array([1, 0.2234, 0.1859, 0.3689, 0, 0.815404, 0.815404, 0, 0, 0.08612, 1.1051])

        frac_control = 0.489
    else:

        AF['Gas'] = np.concatenate([[1], Activity['AF'][:10, j]])
        AF['Oil'] = np.concatenate([[1], Activity['AF'][:10, j]])
        frac_control = Activity['AF'][10, j]

    EF_offsite = np.array([0.00243, 0.0008, 0.0026, 0.0016])
    if local_activity['wells'][j] > n['sample']:
        sample = local_activity['wells'][j] / n['sample']
        local_activity['prod_bbl'][j] /= sample
        local_activity['prod_kg'][j] /= sample
        local_activity['prod_scf'][j] /= sample
        local_activity['wells'][j] = n['sample']
    else:
        sample = 1

    equip_array = np.zeros((20, int(local_activity['wells'][j])))
    equip_sum = np.zeros(int(local_activity['wells'][j]))
    equip_count = np.zeros(int(local_activity['wells'][j]))

    WellProd = local_activity['prod_kg'][j] / local_activity['wells'][j]

    jj = 0
    Counter2 = 1
    # np.random.seed(j  + 1)

    while jj < local_activity['wells'][j]:
        for k in range(11):

            RandomIndex = np.ceil(np.random.rand() * 1000).astype(int) - 1
            RandomActivity = np.random.rand()

            # Gas wells
            if local_activity['GOR'][j] > 100000:
                if AF['Gas'][k] >= 1:
                    AF_Draw = AF['Gas'][k]
                elif k == 0 or RandomActivity < AF['Gas'][k]:
                    AF_Draw = 1
                else:
                    AF_Draw = 0

                equip_array[k, jj] = AF_Draw * EquipGas[k, RandomIndex]

            # Oil wells
            else:
                if AF['Oil'][k] >= 1:
                    AF_Draw = AF['Oil'][k]
                elif k == 0 or RandomActivity < AF['Oil'][k]:
                    AF_Draw = 1
                else:
                    AF_Draw = 0

                equip_array[k, jj] = AF_Draw * EquipOil[k, RandomIndex]

        # Liquids unloadings
        if local_activity['GOR'][j] > 100000:
            EF_LU = liquidsunloadings(Emissions, local_activity, j)
            equip_array[11, jj] = EF_LU
        else:
            equip_array[11, jj] = 0

        # Completions and workovers
        equip_array[12, jj] = 0
        equip_array[13, jj] = 0

        # Tank flashing
        EF_FF = flashing(Emissions, local_activity, j, frac_control)
        equip_array[14, jj] = EF_FF

        # Associated gas flaring
        EF_flare = flaring(Emissions, local_activity, j)


        RandomActivity = np.random.rand()
        AF_Draw = 1 if RandomActivity < local_activity['frac_wells_flaring'][j] else 0
        equip_array[15, jj] = AF_Draw * EF_flare

        for k in range(4):
            equip_array[k + 16, jj] = EF_offsite[k] * (local_activity['prod_kg'][j] / local_activity['wells'][j])

        equip_sum[jj] = np.sum(equip_array[:, jj])

        if equip_sum[jj] < WellProd:
            equip_count[jj] = Counter2
            jj += 1
            Counter2 = 1
        else:
            Counter2 += 1
            if Counter2 == maxit:
                equip_count[jj] = maxit
                idx = np.argmax(equip_array[:16, jj])
                equip_array[idx, jj] = WellProd - np.sum(equip_array[:16, jj])
                jj += 1
                Counter2 = 1

    # Output results
    MatAdd = np.zeros((int(local_activity['wells'][j]), 21))
    MatAdd[:, 0] = j
    MatAdd[:, 1] = local_activity['prod_bbl'][j] / local_activity['wells'][j]
    MatAdd[:, 2] = sample
    MatAdd[:, 3] = WellProd
    MatAdd[:, 4] = local_activity['prod_scf'][j] / local_activity['wells'][j]
    MatAdd[:, 5:21] = equip_array[:16, :].T
    if j == 0:
        Data_Out = MatAdd
    else:
        Data_Out = np.vstack([Data_Out, MatAdd])


    return Data_Out

