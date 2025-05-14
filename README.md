# BASE Model

Bottom-up Analyzer for Source Emissions (BASE)  
A Python-based model to estimate methane emissions from oil and gas production across U.S. basins.

## Overview

This model uses publicly available datasets (e.g., EPA GHGRP, Enverus DrillingInfo, CalGEM) to generate basin-level emissions estimates based on production activity, well data, and equipment distributions.

## Setup Instructions

1. Clone the Repository

    git clone https://github.com/your-username/BASE.git
    cd BASE

2. Install Dependencies

    pip install -r requirements.txt

## Directory Structure

BASE/
├── run_model.py                    # Main script with command-line arguments
├── Inputs/
│   ├── New_Paper.csv              # CSV with province codes and basin names
│   ├── GHGRP_Dat/                 # US EPA GHGRP data (2016–2022)
│   ├── CalGEM/
│   │   ├── Production/            # CalGEM production data
│   │   └── Wells/                 # CalGEM well headers
│   └── Enverus_DrillingInfo/
│       ├── Production/            # Enverus production data
│       └── Wells/                 # Enverus well headers
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

You can use .gitkeep files inside empty folders to ensure Git tracks them.

## How to Use

1. Prepare Input Basins

Edit Inputs/New_Paper.csv with the list of AAPG province codes and basin names:

Example:
2258,San Joaquin Basin
2239,Los Angeles Basin

2. Place Input Data

- Download GHGRP data (2016–2022) from https://enviro.epa.gov/query-builder/ghg  
  and place it in Inputs/GHGRP_Dat/

- Add production and well header data under:
  - Inputs/CalGEM/ (if using CalGEM)
  - Inputs/Enverus_DrillingInfo/ (if using Enverus)

Each should contain a Production/ and Wells/ subdirectory.

3. Run the Model

Use the following command to run the model:

    python run_model.py --year 2020 --input_filename New_Paper.csv --n_trial 10 --productionsource CalGEM

Arguments:
--year: Year to analyze (e.g., 2020)
--input_filename: Input CSV with basin codes and names
--n_trial: Number of Monte Carlo trials
--productionsource: Either CalGEM or DrillingInfo

## Example

    python run_model.py --year 2020 --input_filename New_Paper.csv --n_trial 10 --productionsource DrillingInfo
