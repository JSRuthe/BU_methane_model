from di_scrubbing_func import *
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os


def plotting_func(Basin_Index, Basin_N, Basin_Select, n_trial, basinmapfolder, activityfolder, drillinginfofolder,
                  DI_filename):
    ColorMat = np.array([[140 / 255, 21 / 255, 21 / 255],  # Stanford red
                         [233 / 255, 131 / 255, 0 / 255],  # Stanford orange
                         [234 / 255, 171 / 255, 0 / 255],  # Stanford yellow
                         [0 / 255, 155 / 255, 118 / 255],  # Stanford light green
                         [23 / 255, 94 / 255, 84 / 255],  # Stanford dark green
                         [0 / 255, 152 / 255, 219 / 255],  # Stanford blue
                         [83 / 255, 40 / 255, 79 / 255],   # Stanford purple
                         [0.66, 0.66, 0.66]])              # Gray for extra categories

    # Load and process data for the specific basin
    if Basin_Select != -1:
        filepath = os.path.join(drillinginfofolder, DI_filename)
        DI_data = pd.read_csv(filepath)

        DI_data['Prov_Cod_1'] = DI_data['Prov_Cod_1'].replace('160A', '160')

        Basin_Name = DI_data['Prov_Cod_1'].astype(float)
        Gas_Production = DI_data['Monthly_Ga'].fillna(0)
        Oil_Production = DI_data['Monthly_Oi'].fillna(0)

        Well_Count = np.ones(len(Basin_Name))
        logind = Basin_Name.isin([Basin_N[Basin_Select]])
        M_all = np.column_stack([Oil_Production, Gas_Production, Well_Count])
        M_basin = M_all[logind]

    else:
        csvFileName = 'david_lyon_2015_no_offshore.csv'
        filepath = os.path.join(drillinginfofolder, csvFileName)
        M_US = np.genfromtxt(filepath, delimiter=',')

    if Basin_Select != -1:
        FileName = f'Emissiondata_{Basin_Index[Basin_Select]}out.npz'
        filepath = os.path.join('Outputs', FileName)
        data = np.load(filepath)
        EmissionsGas = data['EmissionsGas']
        EmissionsOil = data['EmissionsOil']
        Study_basin = EmissionsGas + EmissionsOil

    if Basin_Select != -1:
        plot_dat_basin, _, OPGEE_bin = di_scrubbing_func(M_basin, Basin_Select, Basin_Index, activityfolder)
    else:
        plot_dat_US, _, OPGEE_bin = di_scrubbing_func(M_US, 0, Basin_Index, activityfolder)

    fig, axs = plt.subplots(2, 2, figsize=(12, 6), gridspec_kw={'width_ratios': [3, 1], 'height_ratios': [1, 1]})
    fig.subplots_adjust(wspace=0.4, hspace=0.3)

    # Plot 1: Wellpad throughput (logarithmic)
    ax1 = axs[0, 0]
    N = 40
    start = 10 ** -1
    stop = 10 ** 5
    b = np.logspace(np.log10(start), np.log10(stop), N + 1)

    if Basin_Select != -1:
        weights = np.ones_like(plot_dat_basin) / len(plot_dat_basin)

        # Now plot the histogram with the 'weights' argument to normalize by probability
        ax1.hist(plot_dat_basin, bins=b, weights=weights, histtype='step', linewidth=2,
                 edgecolor=ColorMat[Basin_Select])
    else:
        weights = np.ones_like(plot_dat_US) / len(plot_dat_US)

        ax1.hist(plot_dat_US, bins=b, weights=weights, histtype='step', linewidth=2, edgecolor=[0.66, 0.66, 0.66])

    ax1.set_xscale('log')
    ax1.set_xlabel(r'Wellpad throughput [mscf d$^{-1}$]', fontsize=12)
    ax1.set_ylabel('Probability', fontsize=12)
    ax1.set_ylim([0, 0.15])
    ax1.grid(True)

    if Basin_Select != -1:
        annotation_text = f'{Basin_Index[Basin_Select]} \nn = {len(plot_dat_basin)} wells'
        ax1.annotate(annotation_text, xy=(0.75, 0.75), fontsize=10, xycoords='axes fraction',
                     bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white", alpha=0.8))

    # Plot 2: Cumulative emissions CH4 per site
    ax2 = axs[1, 0]
    x_all = []

    for i in range(n_trial):
        if Basin_Select != -1:
            FileName = f'sitedata_{Basin_Index[Basin_Select]}{i + 1}.csv'
            filepath = os.path.join('Outputs', FileName)
        else:
            FileName = f'sitedata{i + 1}.csv'
            filepath = os.path.join('Outputs', FileName)

        sitedata_basin = pd.read_csv(filepath).values

        # Extract the x values and divide by 24 (to convert to per hour)
        x = sitedata_basin[:, 1] / 24
        x = np.sort(x)

        # Add to x_all for processing
        if i == 0:
            x_all = np.column_stack([x, sitedata_basin[:, 3], sitedata_basin[:, 6]])
        else:
            x_all = np.vstack([x_all, np.column_stack([x, sitedata_basin[:, 3], sitedata_basin[:, 6]])])

        # Calculate cumulative sum and plot for each iteration
        y = np.cumsum(x)
        y = y / np.max(y)
        y = 1 - y

        if Basin_Select != -1:
            ax2.scatter(x, y, s=0.5, marker='s', edgecolor=ColorMat[Basin_Select], facecolor=ColorMat[Basin_Select],
                        alpha=0.01)
        else:
            ax2.scatter(x, y, s=0.5, marker='s', edgecolor=[140 / 255, 21 / 255, 21 / 255],
                        facecolor=[140 / 255, 21 / 255, 21 / 255], alpha=0.01)

    # Random sample of sites
    n_sites = sitedata_basin.shape[0]
    index = np.random.choice(np.arange(x_all.shape[0]), n_sites, replace=False)
    samp = x_all[index, :]

    # Sort and plot sampled x and cumulative y
    x = np.sort(samp[:, 0])
    y = np.cumsum(x)
    y = y / np.max(y)
    y = 1 - y

    # Final scatter plot for the sampled data
    ax2.scatter(x, y, s=2, marker='s', edgecolor='k', facecolor='k')

    # Set log scale and axis limits
    ax2.set_xscale('log')
    ax2.set_xlim([0.005, 1000])
    ax2.set_xlabel(r'CH$_4$ per site [kg h$^{-1}$, log scale]', fontsize=12)
    ax2.set_ylabel('Fraction total emissions', fontsize=12)
    ax2.grid(True)

    # Plot 3
    ax3 = plt.subplot2grid((2, 2), (0, 1), rowspan=2)

    if Basin_Select != -1:
        # Define categories for the bar chart
        categories = ['Tanks', 'Equipment Leaks', 'Pneumatic Devices', 'Liquids Unloadings', 'Flare methane']

        # Calculating the data for each category
        GatherData_basin = np.array([
            Study_basin[5, :] + Study_basin[6, :] + Study_basin[15, :],
            np.sum(Study_basin[0:5, :], axis=0) + np.sum(Study_basin[7:9, :], axis=0),
            np.sum(Study_basin[9:11, :], axis=0),
            Study_basin[11, :],
            Study_basin[16, :],
            np.sum(Study_basin[12:14, :], axis=0),
            Study_basin[14, :]
        ])

        GatherData_basin_ave = np.mean(GatherData_basin, axis=1)

        GatherData_basin_SumTot = np.sum(GatherData_basin, axis=0)
        GatherData_basin_Prc = np.percentile(GatherData_basin_SumTot, [2.5, 97.5])
        GatherData_basin_TotHi = - np.sum(GatherData_basin_ave) + GatherData_basin_Prc[1]  # Upper bound
        GatherData_basin_TotLo = np.sum(GatherData_basin_ave) - GatherData_basin_Prc[0]   # Lower bound


        bottom = 0
        x_pos = [1.5]
        for i in range(5):
            ax3.bar(x_pos, GatherData_basin_ave[i], bottom=bottom, color=ColorMat[i], label=categories[i])
            bottom += GatherData_basin_ave[i]

        y_value = np.sum(GatherData_basin_ave[:5])
        yerr = np.array([[GatherData_basin_TotLo], [GatherData_basin_TotHi]]) # Error bar values
        ax3.errorbar(x_pos, y_value, yerr=yerr,  color='black', ecolor='black', capsize=5 )

        ax3.set_ylim([0, y_value + GatherData_basin_TotHi + 0.02])
        ax3.set_xticks([])
        ax3.set_xlabel('')
        ax3.set_ylabel('Tg CH$_4$ yr$^{-1}$', fontsize=12)
        handles, labels = ax3.get_legend_handles_labels()
        ax3.legend(handles[::-1], labels[::-1], loc='center left', bbox_to_anchor=(1, 0.5), fontsize=8)
        # ax3.set_title('Emissions distribution by category', fontsize=12)
        ax3.set_xlim([0, 3])
        ax3.grid(True)

    plt.tight_layout()
    output_filename = f"Outputs/plot_{Basin_Index[Basin_Select]}out.jpg"
    plt.savefig(output_filename, dpi=300)
    plt.show()