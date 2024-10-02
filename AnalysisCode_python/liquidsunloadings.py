import numpy as np
import warnings
warnings.filterwarnings('ignore')

def liquidsunloadings(Emissions, Activity, j):
    """
    Liquids unloading data based on Allen et al. (2015).
    Emission factor distributions are corrected for the average number of unloading events
    per year per well.

    Parameters:
    - Emissions: Dictionary or DataFrame that contains the emissions data.
    - Activity: Dictionary or DataFrame that contains activity data for wells, including LU types.
    - j: Index of the current well to be processed.

    Returns:
    - EF_LU: The emission factor (kg CH4/well/day) for liquids unloading for the current well.
    """

    # Draw random number (indexing starts at 0 in Python)
    RandomIndex = np.ceil(np.random.rand() * 1000).astype(int) - 1

    # Draw emission factor based on indicated LU Type
    if Activity['LU'][j] == 1:
        # kg CH4/well/day
        EF_LU = Emissions['LU'][0][RandomIndex]
    elif Activity['LU'][j] == 2:
        # kg CH4/well/day
        EF_LU = Emissions['LU'][1][RandomIndex]
    else:
        # No liquids unloading
        EF_LU = 0

    return EF_LU
