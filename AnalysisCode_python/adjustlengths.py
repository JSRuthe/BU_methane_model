import numpy as np

def adjust_lengths(sitedata, sitedatainit, i):
    # Adjust drygas
    if i > 1:
        sizemat1 = sitedatainit['drygas'].shape[0]
        sizemat2 = sitedata['drygas'].shape[0]
        if sizemat1 < sizemat2:
            sitedata['drygas'] = sitedata['drygas'][:sizemat1, :]
        else:
            sitedata['drygas'] = np.vstack([sitedata['drygas'], np.zeros((sizemat1 - sizemat2, 6))])
    else:
        sitedatainit['drygas'] = sitedata['drygas']

    # Adjust gaswoil
    if i > 1:
        sizemat1 = sitedatainit['gaswoil'].shape[0]
        sizemat2 = sitedata['gaswoil'].shape[0]
        if sizemat1 < sizemat2:
            sitedata['gaswoil'] = sitedata['gaswoil'][:sizemat1, :]
        else:
            sitedata['gaswoil'] = np.vstack([sitedata['gaswoil'], np.zeros((sizemat1 - sizemat2, 6))])
    else:
        sitedatainit['gaswoil'] = sitedata['gaswoil']

    # Adjust assoc
    if i > 1:
        sizemat1 = sitedatainit['assoc'].shape[0]
        sizemat2 = sitedata['assoc'].shape[0]
        if sizemat1 < sizemat2:
            sitedata['assoc'] = sitedata['assoc'][:sizemat1, :]
        else:
            sitedata['assoc'] = np.vstack([sitedata['assoc'], np.zeros((sizemat1 - sizemat2, 6))])
    else:
        sitedatainit['assoc'] = sitedata['assoc']

    # Adjust oil
    if i > 1:
        sizemat1 = sitedatainit['oil'].shape[0]
        sizemat2 = sitedata['oil'].shape[0]
        if sizemat1 < sizemat2:
            sitedata['oil'] = sitedata['oil'][:sizemat1, :]
        else:
            sitedata['oil'] = np.vstack([sitedata['oil'], np.zeros((sizemat1 - sizemat2, 6))])
    else:
        sitedatainit['oil'] = sitedata['oil']

    return sitedata, sitedatainit