import numpy as np

def OPGEE_rows_func(Replicate, OPGEE_bin, LU_type, flare_tab):
    tranche_OPGEE = []

    # For dry gas bins
    tranche_data = OPGEE_bin['gasdry']

    for i in range(len(tranche_data)):
        for j in range(3):
            wells = round(tranche_data[i, 0] * LU_type[j])
            prod_mscf = tranche_data[i, 2] * LU_type[j]
            prod_bbl = tranche_data[i, 3] * LU_type[j]
            flare_frac = flare_tab['gasdry'][i, 3] * LU_type[j] if Replicate != 1 else 0

            if prod_bbl < 0.4:
                prod_bbl = 0.4

            prod_GOR = (prod_mscf * 1000) / prod_bbl
            vec = [prod_bbl, wells, tranche_data[i, 15] * 100, prod_GOR, j + 1, flare_frac] + list(
                tranche_data[i, 4:15])  # Adjust indexing to capture the same columns as in MATLAB
            tranche_OPGEE.append(vec)

    # For gas wells with oil
    tranche_data = OPGEE_bin['gasassoc']

    for i in range(len(tranche_data)):
        for j in range(3):
            wells = round(tranche_data[i, 0] * LU_type[j])
            prod_mscf = tranche_data[i, 2] * LU_type[j]
            prod_bbl = tranche_data[i, 3] * LU_type[j]
            flare_frac = flare_tab['gasassoc'][i, 3] * LU_type[j] if Replicate != 1 else 0

            if prod_bbl < 0.4:
                prod_bbl = 0.4

            prod_GOR = (prod_mscf * 1000) / prod_bbl
            vec = [prod_bbl, wells, tranche_data[i, 15] * 100, prod_GOR, j + 1, flare_frac] + list(
                tranche_data[i, 4:15])  # Adjust indexing to capture the same columns as in MATLAB
            tranche_OPGEE.append(vec)

    # For oil wells with gas
    tranche_data = OPGEE_bin['oilwgas']

    for i in range(len(tranche_data)):
        wells = round(tranche_data[i, 0])
        prod_mscf = tranche_data[i, 2]
        prod_bbl = tranche_data[i, 3]
        flare_frac = flare_tab['oilwgas'][i, 3] if Replicate != 1 else 0

        if prod_bbl < 0.4:
            prod_bbl = 0.4

        prod_GOR = (prod_mscf * 1000) / prod_bbl
        vec = [prod_bbl, wells, tranche_data[i, 15] * 100, prod_GOR, 3, flare_frac] + list(tranche_data[i, 4:15])  # Adjust indexing
        tranche_OPGEE.append(vec)

    # For oil wells
    tranche_data = OPGEE_bin['oil']

    for i in range(len(tranche_data)):
        wells = round(tranche_data[i, 0])
        prod_mscf = tranche_data[i, 2]
        prod_bbl = tranche_data[i, 3]
        flare_frac = flare_tab['oil'][i, 3] if Replicate != 1 else 0

        if prod_bbl < 0.4:
            prod_bbl = 0.4

        prod_GOR = (prod_mscf * 1000) / prod_bbl
        vec = [prod_bbl, wells, tranche_data[i, 15] * 100, prod_GOR, 3, flare_frac] + list(tranche_data[i, 4:15])  # Adjust indexing
        tranche_OPGEE.append(vec)

    return np.array(tranche_OPGEE)
