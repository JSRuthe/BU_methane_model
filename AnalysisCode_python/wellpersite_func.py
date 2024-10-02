import numpy as np
from clustering import *

def wellpersite_func(welldata, tranche, k, AF_basin):
    # Preprocessing
    C1_frac = AF_basin[0, 11]

    # DRY GAS processing
    if welldata['drygas'].ndim == 2:
        welldata['drygas'] = welldata['drygas'][:,:, None]
    if welldata['gaswoil'].ndim == 2:
        welldata['gaswoil'] = welldata['gaswoil'][:,:, None]
    if welldata['assoc'].ndim == 2:
        welldata['assoc']= welldata['assoc'][:,:, None]
    if welldata['oil'].ndim == 2:
        welldata['oil'] = welldata['oil'][:,:, None]


    well_iteration = welldata['drygas'][:, :, k]

    site_iteration = np.zeros((1, 1))

    totalrows = well_iteration.shape[0] - 1
    startrow = 0
    endrow = 0
    reset = True

    while endrow < totalrows:
        index = well_iteration[startrow, 0] + 1
        if index in [1, 2, 3]:
            tranche_set = tranche['i1']
        elif index in [4, 5, 6]:
            tranche_set = tranche['i2']
        elif index in [7, 8, 9]:
            tranche_set = tranche['i3']
        elif index in [10, 11, 12]:
            tranche_set = tranche['i4']
        elif index in [13, 14, 15]:
            tranche_set = tranche['i5']
        elif index in [16, 17, 18]:
            tranche_set = tranche['i6']
        elif index in [19, 20, 21]:
            tranche_set = tranche['i7']
        elif index in [22, 23, 24]:
            tranche_set = tranche['i8']
        elif index in [25, 26, 27]:
            tranche_set = tranche['i9']
        elif index in [28, 29, 30]:
            tranche_set = tranche['i10']
        else:
            tranche_set = None

        if tranche_set is not None:
            startrow, endrow, site_iteration, reset = clustering(
                startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac
            )
        else:
            break

    sitedata = {}
    sitedata['drygas'] = site_iteration

    # GAS WITH OIL processing
    well_iteration = welldata['gaswoil'][:, :, k]
    site_iteration = np.zeros((1, 1))

    totalrows = well_iteration.shape[0] - 1
    startrow = 0
    endrow = 0
    reset = True

    while endrow < totalrows:
        index = well_iteration[startrow, 0] + 1

        if index in [31, 32, 33]:
            tranche_set = tranche['i11']
        elif index in [34, 35, 36]:
            tranche_set = tranche['i12']
        elif index in [37, 38, 39]:
            tranche_set = tranche['i13']
        elif index in [40, 41, 42]:
            tranche_set = tranche['i14']
        elif index in [43, 44, 45]:
            tranche_set = tranche['i15']
        elif index in [46, 47, 48]:
            tranche_set = tranche['i16']
        elif index in [49, 50, 51]:
            tranche_set = tranche['i17']
        elif index in [52, 53, 54]:
            tranche_set = tranche['i18']
        elif index in [55, 56, 57]:
            tranche_set = tranche['i19']
        elif index in [58, 59, 60]:
            tranche_set = tranche['i20']
        else:
            tranche_set = None

        if tranche_set is not None:
            startrow, endrow, site_iteration, reset = clustering(
                startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac
            )
        else:

            break

    sitedata['gaswoil'] = site_iteration

    # OIL WITH GAS processing
    well_iteration = welldata['assoc'][:, :, k]
    site_iteration = np.zeros((1, 1))

    totalrows = well_iteration.shape[0] - 1
    startrow = 0
    endrow = 0
    reset = True

    while endrow < totalrows:
        index = well_iteration[startrow, 0] + 1

        if index == 61:
            tranche_set = tranche['i21']
        elif index == 62:
            tranche_set = tranche['i22']
        elif index == 63:
            tranche_set = tranche['i23']
        elif index == 64:
            tranche_set = tranche['i24']
        elif index == 65:
            tranche_set = tranche['i25']
        elif index == 66:
            tranche_set = tranche['i26']
        elif index == 67:
            tranche_set = tranche['i27']
        elif index == 68:
            tranche_set = tranche['i28']
        elif index == 69:
            tranche_set = tranche['i29']
        elif index == 70:
            tranche_set = tranche['i30']
        else:
            tranche_set = None

        if tranche_set is not None:
            startrow, endrow, site_iteration, reset = clustering(
                startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac
            )

    sitedata['assoc'] = site_iteration

    # OIL ONLY processing
    well_iteration = welldata['oil'][:, :, k]
    site_iteration = np.zeros((1, 1))

    totalrows = well_iteration.shape[0] - 1
    startrow = 0
    endrow = 0
    reset = True

    while endrow < totalrows:
        index = well_iteration[startrow, 0] + 1
        if index in [71, 72, 73, 74]:
            tranche_set = tranche['i31']
        else:
            tranche_set = None

        if tranche_set is not None:
            startrow, endrow, site_iteration, reset = clustering(
                startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac
            )

    sitedata['oil'] = site_iteration

    return sitedata
