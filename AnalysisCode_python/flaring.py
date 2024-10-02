import numpy as np
import warnings
warnings.filterwarnings('ignore')

def flaring(Emissions, Activity, j):
    """
    This function calculates methane emissions from flare stacks based on
    probabilities of unlit flares and flare efficiency.
    """
    # Generate random number for unlit flare probability
    IsUnlit = np.random.rand()

    # Probability of an unlit flare
    a = 0.03
    b = 0.07
    Unlit_Frac = ((b - a) * np.random.rand()) + a

    # Calculate unlit efficiency
    if (Activity['prod_kg'][j] / Activity['wells'][j]) < 10:
        Unlit_Eff = 0.2
    else:
        Unlit_Eff = 0.05

    # Determine flare efficiency based on unlit or lit status
    if IsUnlit < Unlit_Frac:
        Eff = Unlit_Eff
    else:
        RandomIndex = np.ceil(np.random.rand() * 98).astype(int) - 1
        Eff = 1 - Emissions['gvakharia'][RandomIndex]

    # Calculate methane emissions (kg CH4/well/day)
    EF_flare = (Activity['prod_scf'][j] / Activity['wells'][j]) * ((16.041 * 1.20233 * (Activity['frac_C1'][j] / 100)) / 1000) * (1 - Eff)

    return EF_flare
