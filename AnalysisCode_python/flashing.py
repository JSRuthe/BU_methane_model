import numpy as np
import warnings
warnings.filterwarnings('ignore')

def flashing(Emissions, Activity, j, frac_control):
    """
    Estimate tank flashing emissions based on Zavala Araiza et al (2017).

    Parameters:
    Emissions (dict): Emissions data, including 'HARC' emissions vector.
    Activity (dict): Activity data for production, wells, etc.
    j (int): Index for the current data point.
    frac_control (float): Fraction of tanks controlled (between 0 and 1).

    Returns:
    float: Flash emissions factor for a single well (kg CH4/well/day).
    """

    IsFlash = np.random.rand()  # Random number to determine if the tank is controlled
    RandomIndex = np.ceil(np.random.rand() * 1000).astype(int) - 1

    # If the tank is controlled, the emission factor is zero
    if IsFlash < frac_control:
        EF_FF = 0
    else:
        # Threshold for continuous vs intermittent dumping (140 bbl/sep/day)
        dump_threshold = 140 / 1.64

        # Check if the throughput is less than the dump threshold
        if (Activity['prod_bbl'][j] / Activity['wells'][j]) < dump_threshold:
            IsIntDump = np.random.rand()  # Determine if intermittent dumping occurs

            # Dumping is more frequent when well productivity is closer to the dump threshold
            if IsIntDump < ((Activity['prod_bbl'][j] / Activity['wells'][j]) / dump_threshold):
                # Intermittent dumping: Calculate emission factor

                Emissions['HARC'] = Emissions['HARC'].flatten()
                EF_FF = Emissions['HARC'][RandomIndex] * dump_threshold
            else:
                EF_FF = 0
        else:
            # Continuous dumping: Calculate emission factor
            EF_FF = Emissions['HARC'][RandomIndex] * (Activity['prod_bbl'][j] / Activity['wells'][j])

    return EF_FF
