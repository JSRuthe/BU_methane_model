import numpy as np
import pandas as pd
import os
from data_class import data_class
import warnings
warnings.filterwarnings('ignore')

def di_scrubbing_func(M_raw, Basin_Select, Basin_Index, activityfolder):

    cutoff = 100  # Mscf/bbl
    M_raw[:, 2] = np.round(M_raw[:, 2])
    total_wells = int(np.sum(M_raw[:, 2]))

    # Initialize M_new
    M_new = np.zeros((total_wells, 4))

    # Transform the array so that each row corresponds to a well
    row = 0
    for i in range(M_raw.shape[0]):
        wells = int(M_raw[i, 2])
        if wells == 1:
            M_new[row, 0] = M_raw[i, 0] / 365.25
            M_new[row, 1] = M_raw[i, 1] / 365.25
            row += 1
        else:
            for _ in range(wells):
                prod_oil = M_raw[i, 0] / wells / 365.25  # Convert to bbl/day
                prod_gas = M_raw[i, 1] / wells / 365.25  # Convert to Mscf/day
                M_new[row, 0] = prod_oil
                M_new[row, 1] = prod_gas
                row += 1

    # Replace NaN values with 0
    M_new[np.isnan(M_new)] = 0
    plot_dat = M_new[:, 1]

    # Data classification
    M_no_offshore, count, totalprod, averageprod = data_class(M_new[:, :2], cutoff, activityfolder)

    # Create data table for gas and oil wells
    data_tab = [
        ["", "# wells", "Total oil (MMbbls)", "Total gas (Bscf/yr)"],
        ["Gas wells", count['gasall'], totalprod['gasall'][0], totalprod['gasall'][1]],
        ["Oil wells", count['oilall'], totalprod['oilall'][0], totalprod['oilall'][1]]
    ]

    # Save the data table to an Excel file
    if Basin_Select == 0:
        file_name = 'DI_summary_US.xlsx'
    else:
        file_name = f'DI_summary_{Basin_Index[Basin_Select]}out.xlsx'

    output_dir = 'Outputs'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    filepath = os.path.join(output_dir, file_name)
    data_table = pd.DataFrame(data_tab)
    data_table.to_excel(filepath, header=False, index=False)

    # BINNING - DRY GAS WELLS
    edges_gas_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 500000000]
    counts_gas, edges_gas = np.histogram(M_no_offshore['drygas'][:, 1], bins=edges_gas_set)

    bin_ave_gas = np.zeros(len(counts_gas))
    bin_sum_gas = np.zeros(len(counts_gas))
    bin_sum_oilwg = np.zeros(len(counts_gas))

    for i in range(1, len(edges_gas_set)):
        bin_mask = (M_no_offshore['drygas'][:, 1] > edges_gas_set[i - 1]) & (
                    M_no_offshore['drygas'][:, 1] <= edges_gas_set[i])
        bin_ave_gas[i - 1] = np.mean(M_no_offshore['drygas'][bin_mask, 1])
        bin_sum_gas[i - 1] = np.sum(M_no_offshore['drygas'][bin_mask, 1])
        bin_sum_oilwg[i - 1] = np.sum(M_no_offshore['drygas'][bin_mask, 0])

    OPGEE_bin = {
        'gasdry': np.column_stack([counts_gas, bin_ave_gas, bin_sum_gas, bin_sum_oilwg])
    }

    # BINNING - ASSOC GAS WELLS
    counts_gas_assoc, edges_gas_assoc = np.histogram(M_no_offshore['gaswoil'][:, 1], bins=edges_gas_set)

    bin_ave_gas_assoc = np.zeros(len(counts_gas_assoc))
    bin_sum_gas_assoc = np.zeros(len(counts_gas_assoc))
    bin_sum_oilwg_assoc = np.zeros(len(counts_gas_assoc))

    for i in range(1, len(edges_gas_set)):
        bin_mask_assoc = (M_no_offshore['gaswoil'][:, 1] > edges_gas_set[i - 1]) & (
                    M_no_offshore['gaswoil'][:, 1] <= edges_gas_set[i])
        bin_ave_gas_assoc[i - 1] = np.mean(M_no_offshore['gaswoil'][bin_mask_assoc, 1])
        bin_sum_gas_assoc[i - 1] = np.sum(M_no_offshore['gaswoil'][bin_mask_assoc, 1])
        bin_sum_oilwg_assoc[i - 1] = np.sum(M_no_offshore['gaswoil'][bin_mask_assoc, 0])

    OPGEE_bin['gasassoc'] = np.column_stack(
        [counts_gas_assoc, bin_ave_gas_assoc, bin_sum_gas_assoc, bin_sum_oilwg_assoc])

    # BINNING - OIL WELLS
    edges_oil_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 1500000]
    counts_oil, edges_oil = np.histogram(M_no_offshore['oilwgas'][:, 1], bins=edges_oil_set)

    bin_ave_gas_oil = np.zeros(len(counts_oil))
    bin_sum_gas_oil = np.zeros(len(counts_oil))
    bin_sum_oilwg_oil = np.zeros(len(counts_oil))

    for i in range(1, len(edges_oil_set)):
        bin_mask_oil = (M_no_offshore['oilwgas'][:, 1] > edges_oil_set[i - 1]) & (
                    M_no_offshore['oilwgas'][:, 1] <= edges_oil_set[i])
        bin_ave_gas_oil[i - 1] = np.mean(M_no_offshore['oilwgas'][bin_mask_oil, 1])
        bin_sum_gas_oil[i - 1] = np.sum(M_no_offshore['oilwgas'][bin_mask_oil, 1])
        bin_sum_oilwg_oil[i - 1] = np.sum(M_no_offshore['oilwgas'][bin_mask_oil, 0])

    OPGEE_bin['oilwgas'] = np.column_stack([counts_oil, bin_ave_gas_oil, bin_sum_gas_oil, bin_sum_oilwg_oil])

    # BINNING - WET WELLS (The Missing Oil Bin Assignment)
    edges_oil_set_wet = [0, 0.5, 1, 10, 1500000]
    counts_oil_wet, edges_oil_wet = np.histogram(M_no_offshore['oil'][:, 1], bins=edges_oil_set_wet)

    bin_ave_gas_wet = np.zeros(len(counts_oil_wet))
    bin_sum_gas_wet = np.zeros(len(counts_oil_wet))
    bin_sum_oilwg_wet = np.zeros(len(counts_oil_wet))

    for i in range(1, len(edges_oil_set_wet)):
        bin_mask_wet = (M_no_offshore['oil'][:, 1] > edges_oil_set_wet[i - 1]) & (
                    M_no_offshore['oil'][:, 1] <= edges_oil_set_wet[i])
        bin_ave_gas_wet[i - 1] = np.mean(M_no_offshore['oil'][bin_mask_wet, 1])
        bin_sum_gas_wet[i - 1] = np.sum(M_no_offshore['oil'][bin_mask_wet, 1])
        bin_sum_oilwg_wet[i - 1] = np.sum(M_no_offshore['oil'][bin_mask_wet, 0])

    OPGEE_bin['oil'] = np.column_stack([counts_oil_wet, bin_ave_gas_wet, bin_sum_gas_wet, bin_sum_oilwg_wet])

    # BINNING - ALL WELLS
    M_all = np.vstack([M_no_offshore['oilall'], M_no_offshore['gasall']])
    edges_set = [0, 1, 5, 10, 20, 50, 100, 500, 1000, 10000, 1500000]
    counts, edges = np.histogram(M_all[:, 1], bins=edges_set)

    bin_ave_gas_all = np.zeros(len(counts))
    bin_sum_gas_all = np.zeros(len(counts))
    bin_sum_oilwg_all = np.zeros(len(counts))

    for i in range(1, len(edges_set)):
        bin_mask_all = (M_all[:, 1] > edges_set[i - 1]) & (M_all[:, 1] <= edges_set[i])
        bin_ave_gas_all[i - 1] = np.mean(M_all[bin_mask_all, 1])
        bin_sum_gas_all[i - 1] = np.sum(M_all[bin_mask_all, 1])
        bin_sum_oilwg_all[i - 1] = np.sum(M_all[bin_mask_all, 0])

    OPGEE_bin['all'] = np.column_stack([counts, bin_ave_gas_all, bin_sum_gas_all, bin_sum_oilwg_all])


    output_dir = 'Outputs'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    if Basin_Select == -1:
        file_name = 'plot_dat_US.xlsx'
    else:
        file_name = f'plot_dat_{Basin_Index[Basin_Select]}out.xlsx'

    return plot_dat, data_tab, OPGEE_bin
