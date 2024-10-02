import numpy as np
import pandas as pd
import os
import warnings
warnings.filterwarnings('ignore')

def flaring_tranche(Basin_Select, Basin_Index, Basin_N, OPGEE_bin, activityfolder):
    """
    This function calculates flare stack emissions for gas and oil wells
    and organizes the data into tranches.
    """

    # Load flare data
    filepath = os.path.join(os.getcwd(), activityfolder, 'GAS_TO_FLARE.csv')
    flare_data = pd.read_csv(filepath, header=None)
    flare_data.columns = ['Type', 'Basin', 'Gas_Sent', 'CH4_Fraction']

    # Extrapolation factor based on VIIRS estimates and EPA estimates
    extrap_factor = 388 / 265

    logind = flare_data['Basin'].isin([Basin_N[Basin_Select]])
    flare_filtered = flare_data[logind]

    GAS_SENT_All = flare_filtered['Gas_Sent'].values
    CH4_Frac_All = flare_filtered['CH4_Fraction'].values
    Oilgas = flare_filtered['Type'].values

    # Separate gas and oil well data
    GAS_SENT_Gas = GAS_SENT_All[Oilgas == 'Gas']
    GAS_SENT_Oil = GAS_SENT_All[Oilgas == 'Oil']

    # Convert units (from Mscf/year to Mscf/day)
    GAS_SENT_Gas = GAS_SENT_Gas / 365 / 1000
    GAS_SENT_Oil = GAS_SENT_Oil / 365 / 1000

    GAS_SENT_Total = np.concatenate((GAS_SENT_Gas, GAS_SENT_Oil))

    # Extrapolate gas sent to flare for gas wells
    n_stacks_Gas = int(round(len(GAS_SENT_Gas) * extrap_factor))
    excess = n_stacks_Gas - len(GAS_SENT_Gas)

    # If comparison with matlab
    # if len(GAS_SENT_Gas) > 0:
    #     repeats = int(np.ceil(excess / len(GAS_SENT_Gas)))  # Calculate how many times to repeat GAS_SENT_Gas
    # else:
    #     repeats = 0
    # newvec = np.tile(GAS_SENT_Gas, repeats)  # Repeat GAS_SENT_Gas 'repeats' times
    # newvec = newvec[:excess]
    # GAS_SENT_TO_FLARE_EXT_Gas = np.concatenate((GAS_SENT_Gas, newvec))

    # Otherwise
    newvec = np.random.choice(GAS_SENT_Gas, excess, replace=True)
    GAS_SENT_TO_FLARE_EXT_Gas = np.concatenate((GAS_SENT_Gas, newvec))


    # Bin gas data and calculate bin statistics
    edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 1000000000]
    counts_gas, edges_gas = np.histogram(GAS_SENT_TO_FLARE_EXT_Gas, bins=edges_set)
    bin_ave_gas = np.array([np.mean(GAS_SENT_TO_FLARE_EXT_Gas[(GAS_SENT_TO_FLARE_EXT_Gas > edges_set[i]) &
                                                              (GAS_SENT_TO_FLARE_EXT_Gas <= edges_set[i + 1])])
                            for i in range(len(edges_set) - 1)])
    bin_sum_gas = np.array([np.sum(GAS_SENT_TO_FLARE_EXT_Gas[(GAS_SENT_TO_FLARE_EXT_Gas > edges_set[i]) &
                                                             (GAS_SENT_TO_FLARE_EXT_Gas <= edges_set[i + 1])])
                            for i in range(len(edges_set) - 1)])

    bins_exp_Gas = np.column_stack((counts_gas, bin_ave_gas, bin_sum_gas))
    bins_exp_Gas_df = pd.DataFrame(bins_exp_Gas)



    # Prepare flare_tab for gasdry and gasassoc
    flare_tab = {}
    flare_tab['gasdry'] = np.zeros((len(OPGEE_bin['gasdry']), 4))
    flare_tab['gasassoc'] = np.zeros((len(OPGEE_bin['gasassoc']), 4))

    flare_tab['gasdry'][:, 0] = OPGEE_bin['gasdry'][:, 0] / (OPGEE_bin['gasdry'][:, 0] + OPGEE_bin['gasassoc'][:, 0])
    flare_tab['gasdry'][:, 1] = OPGEE_bin['gasdry'][:, 0]
    flare_tab['gasdry'][:, 2] = bins_exp_Gas[:, 0] * flare_tab['gasdry'][:, 0]

    flare_tab['gasdry'][:, 3] = flare_tab['gasdry'][:, 2] / flare_tab['gasdry'][:, 1]
    flare_tab['gasdry'][:, 3][np.isnan(flare_tab['gasdry'][:, 3])] = 0
    flare_tab['gasdry'][:, 3][flare_tab['gasdry'][:, 3] > 1] = 1

    flare_tab['gasassoc'][:, 0] = OPGEE_bin['gasassoc'][:, 0] / (
            OPGEE_bin['gasdry'][:, 0] + OPGEE_bin['gasassoc'][:, 0])
    flare_tab['gasassoc'][:, 1] = OPGEE_bin['gasassoc'][:, 0]
    flare_tab['gasassoc'][:, 2] = bins_exp_Gas[:, 0] * flare_tab['gasassoc'][:, 0]
    flare_tab['gasassoc'][:, 3] = flare_tab['gasassoc'][:, 2] / flare_tab['gasassoc'][:, 1]
    flare_tab['gasassoc'][:, 3][np.isnan(flare_tab['gasassoc'][:, 3])] = 0


    # Extrapolate gas sent to flare for oil wells
    n_stacks_Oil = int(round(len(GAS_SENT_Oil) * extrap_factor))
    excess_oil = n_stacks_Oil - len(GAS_SENT_Oil)

    GAS_SENT_TO_FLARE_EXT_Oil = np.concatenate((GAS_SENT_Oil, newvec.flatten()))
    #GAS_SENT_TO_FLARE_EXT_Oil = np.vstack((GAS_SENT_Oil, newvec))

    # Bin oil data and calculate bin statistics
    counts_oil, edges_oil = np.histogram(GAS_SENT_TO_FLARE_EXT_Oil, bins=edges_set)
    bin_ave_oil = np.array([np.mean(GAS_SENT_TO_FLARE_EXT_Oil[(GAS_SENT_TO_FLARE_EXT_Oil > edges_set[i]) &
                                                              (GAS_SENT_TO_FLARE_EXT_Oil <= edges_set[i + 1])])
                            for i in range(len(edges_set) - 1)])
    bin_sum_oil = np.array([np.sum(GAS_SENT_TO_FLARE_EXT_Oil[(GAS_SENT_TO_FLARE_EXT_Oil > edges_set[i]) &
                                                             (GAS_SENT_TO_FLARE_EXT_Oil <= edges_set[i + 1])])
                            for i in range(len(edges_set) - 1)])

    bins_exp_Oil = np.column_stack((counts_oil, bin_ave_oil, bin_sum_oil))


    # Prepare flare_tab for oilwgas and oil
    flare_tab['oilwgas'] = np.zeros((len(OPGEE_bin['oilwgas']), 4))
    flare_tab['oil'] = np.zeros((len(OPGEE_bin['oil']), 4))

    # Process oilwgas data
    flare_tab['oilwgas'][0, 0] = OPGEE_bin['oilwgas'][0, 0] / (
            OPGEE_bin['oilwgas'][0, 0] + OPGEE_bin['oil'][0, 0] + OPGEE_bin['oil'][1, 0])
    flare_tab['oilwgas'][1, 0] = OPGEE_bin['oilwgas'][1, 0] / (
            OPGEE_bin['oilwgas'][1, 0] + OPGEE_bin['oilwgas'][2, 0] + OPGEE_bin['oil'][2, 0])
    flare_tab['oilwgas'][2, 0] = OPGEE_bin['oilwgas'][2, 0] / (
            OPGEE_bin['oilwgas'][1, 0] + OPGEE_bin['oilwgas'][2, 0] + OPGEE_bin['oil'][2, 0])
    flare_tab['oilwgas'][3, 0] = OPGEE_bin['oilwgas'][3, 0] / (OPGEE_bin['oilwgas'][3, 0] + OPGEE_bin['oil'][3, 0])

    flare_tab['oilwgas'][4:10, 0] = 1

    # Process columns 1-4 for oilwgas
    flare_tab['oilwgas'][:, 1] = OPGEE_bin['oilwgas'][:, 0]
    flare_tab['oilwgas'][:, 2] = bins_exp_Oil[:, 0] * flare_tab['oilwgas'][:, 0]
    flare_tab['oilwgas'][:, 3] = flare_tab['oilwgas'][:, 2] / flare_tab['oilwgas'][:, 1]
    flare_tab['oilwgas'][:, 3][np.isnan(flare_tab['oilwgas'][:, 3])] = 0

    # Process oil data
    flare_tab['oil'][0, 0] = OPGEE_bin['oil'][0, 0] / (
            OPGEE_bin['oilwgas'][0, 0] + OPGEE_bin['oil'][0, 0] + OPGEE_bin['oil'][1, 0])
    flare_tab['oil'][1, 0] = OPGEE_bin['oil'][1, 0] / (
            OPGEE_bin['oilwgas'][0, 0] + OPGEE_bin['oil'][0, 0] + OPGEE_bin['oil'][1, 0])
    flare_tab['oil'][2, 0] = OPGEE_bin['oil'][2, 0] / (
            OPGEE_bin['oilwgas'][1, 0] + OPGEE_bin['oilwgas'][2, 0] + OPGEE_bin['oil'][2, 0])
    flare_tab['oil'][3, 0] = OPGEE_bin['oil'][3, 0] / (OPGEE_bin['oilwgas'][3, 0] + OPGEE_bin['oil'][3, 0])
    flare_tab['oil'][:, 1] = OPGEE_bin['oil'][:, 0]
    flare_tab['oil'][:, 2] = bins_exp_Oil[0:4, 0] * flare_tab['oil'][0:4, 0]
    flare_tab['oil'][:, 3] = flare_tab['oil'][:, 2] / flare_tab['oil'][:, 1]
    flare_tab['oil'][:, 3][np.isnan(flare_tab['oil'][:, 3])] = 0


    return flare_tab
