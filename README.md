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
├── Inputs
│   ├── New_Paper.csv                # CSV with province codes and basin names
│   ├── GHGRP_Dat                   # EPA GHGRP data (2016–2022)
│   ├── CalGEM
│   │   ├── Production              # CalGEM production data
│   │   └── Wells                   # CalGEM well headers
│   └── Enverus_DrillingInfo
│       ├── Production              # Enverus production data
│       └── Wells                   # Enverus well headers
│   └── Basins_shapefiles           # AAPG basin shapefile (with BASIN_CODE, BASIN_NAME)
│   ├── Geo_File                    # Custom shapefile/geojson for user-defined region

├── ActivityData
├── ProductionData
├── EquipmentDistributions
├── AnalysisCode_python
```
---

## How to Use

### Option 1: Run using AAPG Basin

If you want to run the model on a predefined AAPG basin:

```bash
python main.py
  --year 2020
  --shape_id 745
  --n_trial 10
  --production_source CalGEM
  --AAPG_province
```

### Option 2: Run using your own geometry

If you want to run the model on a custom region (shapefile, GeoJSON, GPKG), place exactly **one** file in `Geo_File`, and use:

```bash
python main.py 
  --year 2020 
  --shape_name "My Custom Basin" 
  --n_trial 10 
  --production_source DrillingInfo
```

---

### Arguments

- `--year`: Target year for analysis (e.g., 2020)
- `--shape_id`: AAPG basin code (e.g., 745) — *Required if using `--AAPG_province`*
- `--shape_name`: Region name for custom geometry — *Required if **not** using `--AAPG_province`*
- `--n_trial`: Number of Monte Carlo trials
- `--production_source`: `CalGEM` or `DrillingInfo`
- `--AAPG_province`: Include this flag to use AAPG shapefiles

---

## Data Requirements

- **GHGRP data (2016–2022)**: Download from the [EPA GHG Query Builder](https://enviro.epa.gov/query-builder/ghg) and place in `Inputs/GHGRP_Dat/`.
- **Production data**:
  - `CalGEM`: Place in `Inputs/CalGEM/`
  - `DrillingInfo`: Place in `Inputs/Enverus_DrillingInfo/`
- **Custom shapefile or GeoJSON**: Place a single file in `Inputs/Geo_File/` if not using AAPG

---

## Example

Run using AAPG province:

```bash
python main.py --year 2020 --shape_id 745 --n_trial 10 --production_source CalGEM --AAPG_province
```

Run using custom geometry:

```bash
python main.py --year 2020 --shape_name "My Custom Basin" --n_trial 10 --production_source DrillingInfo
```

