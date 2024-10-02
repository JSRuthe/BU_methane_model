import numpy as np
import os
import scipy.io as sio
import warnings
warnings.filterwarnings('ignore')

def data_class(M_in, cutoff, activityfolder):
    # Replace values <= 0 with a small value
    M_in[M_in <= 0] = 99E-8
    size_mat = M_in.shape[0]

    # Create empty dictionaries to store results
    count = {
        'drygas': 0,
        'gaswoil': 0,
        'oil': 0,
        'oilwgas': 0,
        'gasall': 0
    }

    totalprod = {
        'drygas': np.zeros(2),
        'gaswoil': np.zeros(2),
        'oil': np.zeros(2),
        'oilwgas': np.zeros(2),
        'gasall': np.zeros(2)
    }

    averageprod = {
        'drygas': np.zeros(2),
        'gaswoil': np.zeros(2),
        'oil': np.zeros(2),
        'oilwgas': np.zeros(2),
        'gasall': np.zeros(2)
    }

    # Add a test GOR for oil with gas
    GORoil = np.zeros(size_mat)

    # DATA CLASSIFICATION
    # Calculate GOR (Gas-to-Oil Ratio)
    M_in = np.hstack((M_in, np.zeros((M_in.shape[0], 1))))

    M_in[:, 2] = M_in[:, 1] / M_in[:, 0]

    logind = np.zeros((size_mat, 7), dtype=bool)
    logind[:, 6] = (M_in[:, 1] == 99E-8) & (M_in[:, 0] == 99E-8)
    logind[:, 0] = (M_in[:, 2] > cutoff) & (M_in[:, 0] == 99E-8) & (~logind[:, 6])  # Gas only
    logind[:, 1] = (M_in[:, 2] < cutoff) & (M_in[:, 1] == 99E-8) & (~logind[:, 6])  # Oil only
    logind[:, 2] = (M_in[:, 2] > cutoff) & (M_in[:, 0] != 99E-8) & (~logind[:, 6])  # Gas with oil
    logind[:, 3] = (M_in[:, 2] < cutoff) & (M_in[:, 1] != 99E-8) & (~logind[:, 6])  # Oil with gas

    M_out = {}

    # Dry gas from gas wells
    ind_drygas = logind[:, 0]
    count['drygas'] = np.sum(ind_drygas)
    M_out['drygas'] = M_in[ind_drygas]
    totalprod['drygas'][1] = np.sum(M_out['drygas'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['drygas'][0] = np.mean(M_out['drygas'][:, 0])
    averageprod['drygas'][1] = np.mean(M_out['drygas'][:, 1])

    # Gas with associated oil
    ind_gaswoil = logind[:, 2]
    count['gaswoil'] = np.sum(ind_gaswoil)
    M_out['gaswoil'] = M_in[ind_gaswoil]
    totalprod['gaswoil'][0] = np.sum(M_out['gaswoil'][:, 0]) * (365.25 / 1e6)  # Convert to MMbbl/year
    totalprod['gaswoil'][1] = np.sum(M_out['gaswoil'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['gaswoil'][0] = np.mean(M_out['gaswoil'][:, 0])
    averageprod['gaswoil'][1] = np.mean(M_out['gaswoil'][:, 1])

    # Oil only
    ind_oil = logind[:, 1]
    count['oil'] = np.sum(ind_oil)
    M_out['oil'] = M_in[ind_oil]
    totalprod['oil'][0] = np.sum(M_out['oil'][:, 0]) * (365.25 / 1e6)  # Convert to MMbbl/year
    averageprod['oil'][0] = np.mean(M_out['oil'][:, 0])


    # Oil with gas
    ind_oilwgas = logind[:, 3]
    count['oilwgas'] = np.sum(ind_oilwgas)
    M_out['oilwgas'] = M_in[ind_oilwgas]
    totalprod['oilwgas'][0] = np.sum(M_out['oilwgas'][:, 0]) * (365.25 / 1e6)  # Convert to MMbbl/year
    totalprod['oilwgas'][1] = np.sum(M_out['oilwgas'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['oilwgas'][0] = np.mean(M_out['oilwgas'][:, 0])
    averageprod['oilwgas'][1] = np.mean(M_out['oilwgas'][:, 1])
    GORoil = (M_out['oilwgas'][:, 1] * 1000) / M_out['oilwgas'][:, 0]

    # Concatenate gas data
    ind_gasall = ind_drygas | ind_gaswoil
    count['gasall'] = np.sum(ind_gasall)
    M_out['gasall'] = M_in[ind_gasall]
    totalprod['gasall'][0] = np.sum(M_out['gasall'][:, 0]) * (365.25 / 1e6)  # Convert to MMbbl/year
    totalprod['gasall'][1] = np.sum(M_out['gasall'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['gasall'][0] = np.mean(M_out['gasall'][:, 0])
    averageprod['gasall'][1] = np.mean(M_out['gasall'][:, 1])

    # Handle co-produced gas from oil wells
    filepath = os.path.join(os.getcwd(), activityfolder, 'GOR_data.mat')
    data = sio.loadmat(filepath)
    GOR_sort = data['GOR_sort']
    size_oil = np.sum(ind_oil)
    coprodgas = np.zeros((size_oil, 3))
    coprodgas[:, 0] = M_out['oil'][:, 0]  # Oil with no gas production

    for i in range(size_oil):
        random_index = np.random.randint(0, GOR_sort.shape[0])
        coprodgas[i, 1] = GOR_sort[random_index]
        coprodgas[i, 2] = coprodgas[i, 0] * coprodgas[i, 1]

    M_out['oil'][:, 1] = coprodgas[:, 2] / 1000
    M_out['oilall'] = np.vstack([M_out['oilwgas'], M_out['oil']])
    totalprod['oil'][1] = np.sum(M_out['oil'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['oil'][1] = np.mean(M_out['oil'][:, 1])

    # Total oil production
    count['oilall'] = count['oilwgas'] + count['oil']
    if 'oilall' not in totalprod:
        totalprod['oilall'] = np.zeros((2,1))
    if 'oilall' not in averageprod:
        averageprod['oilall'] = np.zeros((2,1))

    totalprod['oilall'][0] = np.sum(M_out['oilall'][:, 0]) * (365.25 / 1e6)  # Convert to MMbbl/year
    totalprod['oilall'][1] = np.sum(M_out['oilall'][:, 1]) * (365.25 / 1e6)  # Convert to Bscf/year
    averageprod['oilall'][0] = np.mean(M_out['oilall'][:, 0])
    averageprod['oilall'][1] = np.mean(M_out['oilall'][:, 1])

    return M_out, count, totalprod, averageprod
