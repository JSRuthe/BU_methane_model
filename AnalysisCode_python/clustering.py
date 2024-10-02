import numpy as np
import random


def clustering(startrow, endrow, site_iteration, reset, tranche_set, well_iteration, totalrows, C1_frac):
    """
    Clusters well-level data into site-level data.
    Output is 'site_iteration' where columns are:
    (1) tranche iteration (1-74)
    (2) summed site-level emissions [kg/day]
    (3) well draw
    """

    # Randomly select a well draw index from tranche_set
    RandomIndex = random.randint(0, tranche_set.shape[0] - 1)

    # Select well draw and process it
    welldraw = int(round(tranche_set[RandomIndex, 2]))
    endrow = startrow + welldraw - 1
    proddraw = tranche_set[RandomIndex, 1]
    proddraw_bbl = tranche_set[RandomIndex, 0]

    # Ensure endrow doesn't exceed total rows
    if endrow > totalrows:
        endrow = totalrows

    cluster = well_iteration[startrow:endrow + 1, :]

    # Create the matadd array with relevant calculations
    matadd = np.zeros((1, 7))
    matadd[0, 1] = np.sum(cluster[:, 1])  # Summed site-level emissions [kg/day]

    matadd[0, 0] = cluster[0, 0]  # Tranche iteration
    matadd[0, 2] = welldraw  # Well draw
    matadd[0, 3] = proddraw  # Production draw
    matadd[0, 4] = proddraw * 1000 * ((16.6 * 1.202 * C1_frac) / 1000)  # CH4 production
    matadd[0, 6] = proddraw_bbl  # Production draw in barrels
    matadd[0, 5] = matadd[0, 1] / matadd[0, 4]  # Emissions/CH4 production ratio

    # Update the start row for the next iteration
    startrow = endrow + 1

    # Check if this is the first iteration or a reset is required
    if reset:
        site_iteration = matadd
        reset = False
    else:
        site_iteration = np.vstack([site_iteration, matadd])

    return startrow, endrow, site_iteration, reset
