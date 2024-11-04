# BU_methane_model
A repo for the methane model Matlab code

1. To run the model for a specific list of basins, go to 'Inputs' and fill file 'New_Paper.csv' with AAPG province codes and names of the basins.

2. For the python version:
- To run the model for a specific year, add Enverus DrillingInfo production data for this year in folder 'Inputs/Enverus_DrillingInfo/Production' and corresponding Well Headers in 'Inputs/Enverus_DrillingInfo/Wells'
- Except Enverus DrillingInfo data, 'Inputs' contains all necessary raw inputs, especially US EPA GHGRP data for all available years, 2016 to 2022, (last accessed August 2024) directly downloaded from https://enviro.epa.gov/query-builder/ghg 

3. Choose year in 'main.py' and run it.