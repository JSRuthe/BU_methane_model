# BASE Model

**Bottom-up Analyzer for Source Emissions (BASE)**  
A Python-based model to estimate methane emissions from oil and gas production across U.S. basins.

---

## Overview

This model uses publicly available datasets (e.g., EPA GHGRP, CalGEM) to generate basin-level emissions estimates based on production activity, well data, and equipment distributions.

---

## Setup Instructions
### 1. Get the code

You can either clone the repository (recommended) or download it as a ZIP:

**Option A — Clone the repository:**

```bash
git clone https://github.com/your-username/BASE.git
cd BASE
```

**Option B — Download ZIP:**

Go to the GitHub page, click the green “Code” button, and select “Download ZIP.” Then unzip and open the folder.


### 2. Install dependencies

```bash
pip install -r requirements.txt
```

---

## Directory Structure

```
BASE/
├── run_model.py                      # Main script with command-line interface
├── requirements.txt
├── Inputs/
│   ├── New_Paper.csv                # CSV with province codes and basin names
│   ├── GHGRP_Dat/                   # EPA GHGRP data (2016–2022)
│   ├── CalGEM/
│   │   ├── Production/              # CalGEM production data
│   │   └── Wells/                   # CalGEM well headers
│   └── Enverus_DrillingInfo/
│       ├── Production/              # Enverus production data
│       └── Wells/                   # Enverus well headers
├── ActivityData/
├── BasinMaps/
├── ProductionData/
├── EquipmentDistributions/
├── GHGRP_read_v3.py
├── tranche_gen_func.py
├── autorun_func.py
├── data_proc_master_func.py
├── plotting_func.py
└── generate_inputs.py
```

You can use `.gitkeep` files inside empty folders to ensure Git tracks them.

---

## How to Use

### 1. Prepare the basin input file

Edit `Inputs/New_Paper.csv` to list the AAPG province codes and basin names you want to analyze. Example:

```csv
745,San Joaquin Basin
430,Permian Basin
```

### 2. Add input data

- Download **GHGRP data** (2016–2022) from [EPA GHG Query Builder](https://enviro.epa.gov/query-builder/ghg)  
  and place it in `Inputs/GHGRP_Dat/`.

- Place production data (corresponding to the basins in the input file) in the appropriate subdirectory:
  - For **CalGEM**: `Inputs/CalGEM/`
  - For **Enverus**: `Inputs/Enverus_DrillingInfo/Production/` for production headers and `Inputs/Enverus_DrillingInfo/Wells/` for well headers

### 3. Run the model

Run the model with your chosen configuration:

```bash
python run_model.py \
  --year 2020 \
  --input_filename New_Paper.csv \
  --n_trial 10 \
  --production_source CalGEM
```

#### Argument Descriptions

- `--year`: Year to analyze (e.g., `2020`)
- `--input_filename`: CSV file with basin codes and names
- `--n_trial`: Number of Monte Carlo trials
- `--production_source`: Either `CalGEM` or `DrillingInfo`

---

## Example

```bash
python run_model.py --year 2020 --input_filename New_Paper.csv --n_trial 10 --production_source DrillingInfo
```
