import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os


def EmissionsPlots_UStot():
    # Define colors for plots
    StanfordRed = np.array([140, 21, 21]) / 255
    StanfordOrange = np.array([233, 131, 0]) / 255
    StanfordYellow = np.array([234, 171, 0]) / 255
    StanfordLGreen = np.array([0, 155, 118]) / 255
    StanfordDGreen = np.array([23, 94, 84]) / 255
    StanfordBlue = np.array([0, 152, 219]) / 255
    Sandstone = np.array([210, 194, 149]) / 255
    LightGrey = np.array([0.66, 0.66, 0.66])

    # Load sitedata
    sitedata_US = pd.read_csv('Outputs/sitedata_out.csv').values

    # Load emissions data
    emissions_data = pd.read_csv('Outputs/Emissionsdata_out_100.csv').values
    Study_US = emissions_data[:, 0] + emissions_data[:, 1]

    # Load EPA data
    data = pd.read_csv('EPA_import.csv').values
    EPA = {
        "Gas": data[:, 0] / 1000,
        "Oil": data[:, 1] / 1000
    }
    EPA["All"] = np.sum([EPA["Gas"], EPA["Oil"]], axis=0)

    # Process data for plot
    GatherData = [
        Study_US[5] + Study_US[6] + Study_US[15],
        np.sum(Study_US[0:4]) + np.sum(Study_US[7:8]),
        np.sum(Study_US[9:10]),
        Study_US[11],
        Study_US[16],
        np.sum(Study_US[12:13]),
        Study_US[14]
    ]

    EPAData = [
        EPA["All"][2],
        EPA["All"][0],
        EPA["All"][1],
        EPA["All"][4],
        EPA["All"][6],
        np.sum(EPA["All"][3]),
        EPA["All"][5]
    ]

    GatherData_Ave = np.mean(GatherData)

    # Plot 1: Bar Plot
    plt.figure(figsize=(8, 5.5))

    plt.subplot(2, 2, [1, 3])
    bars = plt.bar(
        [1, 2, 3],
        [np.sum(GatherData_Ave), 7.22, 3.57],
        color=[StanfordRed, StanfordBlue, Sandstone]
    )

    plt.xticks([1, 2, 3], ['Study', 'Alvarez', 'GHGI'], rotation=25)
    plt.ylabel('US 2015 CH₄ from production-segment [Tg CH₄ yr⁻¹]')
    plt.ylim(0, 10)
    plt.gca().tick_params(axis='both', direction='out')
    plt.box(True)

    # Plot 2: CDF Plot
    plt.subplot(2, 2, 2)
    omara_data = pd.read_csv('Omara_data_kgh_allsites.csv').dropna().values

    plt.loglog(sitedata_US[:, 1] / 24, np.linspace(0, 1, len(sitedata_US)), label="This study", color=StanfordRed)
    plt.loglog(omara_data[:, 1], np.linspace(0, 1, len(omara_data)), '--', label="Omara", color=StanfordBlue,
               linewidth=3)

    plt.xscale('log')
    plt.xlim(0.0005, 100)
    plt.ylim(0, 1.1)
    plt.xlabel('CH₄ per site [kg h⁻¹, log scale]')
    plt.ylabel('Cumulative density')
    plt.gca().tick_params(axis='both', direction='out')
    plt.legend(loc='NorthWest', fontsize=8)

    # Plot 3: PDF Plot
    plt.subplot(2, 2, 4)

    plt.hist(omara_data[:, 1], bins=np.logspace(-3, 2, 20), histtype='step', color=StanfordBlue, label="Omara",
             linewidth=3)
    plt.hist(sitedata_US[:, 1] / 24, bins=np.logspace(-3, 2, 20), histtype='step', color=StanfordRed, label="Study",
             linewidth=0.4)

    plt.xscale('log')
    plt.xlim(0.0005, 100)
    plt.ylim(0, 0.05)
    plt.xlabel('CH₄ per site [kg h⁻¹, log scale]')
    plt.ylabel('Probability density')
    plt.gca().tick_params(axis='both', direction='out')

    plt.tight_layout()
    plt.savefig('Fig_main1_flash_adjust.png', dpi=300, bbox_inches='tight')
    plt.show()

    # Additional plots can be added similarly using the same structure
