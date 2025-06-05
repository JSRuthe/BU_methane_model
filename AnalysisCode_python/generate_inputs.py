import pandas as pd
import warnings
import os
warnings.filterwarnings('ignore')
from shapely.geometry import Point
import geopandas as gpd
import pickle
import matplotlib.pyplot as plt

def adjust_by_proportion(df, key_cols, value_col, proportion_mapping):
    def get_key(row):
        if len(key_cols) == 1:
            return row[key_cols[0]]
        return tuple(row[col] for col in key_cols)

    def get_adjusted_value(row):
        val = row[value_col] if pd.notna(row[value_col]) else 0
        key = get_key(row)
        prop = proportion_mapping.get(key, 0)
        return val * prop if prop > 0 else None

    df[value_col] = df.apply(get_adjusted_value, axis=1)
    return df.dropna(subset=[value_col])


def generate_ghgrp_dat(year, Shape_ID, inputsfolder, GHGRPfolder, activityfolder, proportions):
    raw_GHGRPfolder = os.path.join(inputsfolder, 'GHGRP')

    facilities_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_FACILITY_OVERVIEW.CSV')
    flare_path =  os.path.join(raw_GHGRPfolder, 'EF_W_FLARE_STACKS_UNITS.xlsb')
    equip_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_EQUIP_LEAKS_ONSHORE.CSV')
    pc_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_NGPNEUMATIC_DEV_UNITS.CSV')
    pump_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_NGPNEUMATIC_PMP_UNITS.CSV')
    tanks12_file_path = os.path.join(raw_GHGRPfolder, 'ATM_STG_TANKS_CALC1OR2.CSV')
    tanks3_file_path = os.path.join(raw_GHGRPfolder, 'ATM_STG_TANKS_CALC3.CSV')
    LU_file_path = os.path.join(raw_GHGRPfolder, 'LIQUIDS_UNLOAD_UNITS.CSV')

    # Facility_Basin_correspondence_2020.csv
    facilities_data = pd.read_csv(facilities_file_path)

    facilities_data['Basin_ID'] = facilities_data['sub_basin_identifier'].str.extract(r'(\d{3})')

    def classify_type(text):
        text = str(text).lower()
        if any(keyword in text for keyword in ['gas', 'tight', 'coal']):
            return 'Gas'
        else:
            return 'Oil'

    facilities_data['Oil_Gas'] = facilities_data['sub_basin_formation_type'].apply(classify_type)

    fac_year = facilities_data[facilities_data.reporting_year == year]
    fac_year = fac_year[['facility_id']].drop_duplicates()
    fac_year = fac_year.rename(columns={'facility_id': 'FACILITY_ID'})

    # Assign Shape_ID if proportion > 0, else 0
    fac_year['Basin_ID'] = fac_year['FACILITY_ID'].map(
        lambda fid: Shape_ID if proportions['facility_to_well_prop'].get(fid, 0) > 0 else 0
    )

    # Save as Facility_Basin_correspondence_<year>.csv
    fac_year.to_csv(
        os.path.join(GHGRPfolder, f'Facility_Basin_correspondence_{year}.csv'),
        index=False,
        encoding='utf-8'
    )

    # Facilities_year.csv

    facilities_data['Basin_ID'] = facilities_data['sub_basin_identifier'].str.extract(r'(\d{3})')

    # year
    facilities_year = facilities_data[facilities_data.reporting_year == year]
    facilities_year = facilities_year[~pd.isna(facilities_year.Basin_ID)]
    facilities_year_flare = facilities_year[['facility_id', 'Basin_ID', 'Oil_Gas']]
    facilities_year_flare = facilities_year_flare.drop_duplicates(subset=['facility_id', 'Basin_ID'])
    facilities_year = facilities_year[['facility_id', 'Basin_ID']]
    facilities_year = facilities_year.sort_values(by='facility_id')
    facilities_year = facilities_year.drop_duplicates(subset=['facility_id', 'Basin_ID'])

    # year
    facilities_year_wch4frac_wellcounts = facilities_data[facilities_data.reporting_year == year]
    facilities_year_wch4frac_wellcounts['Basin_ID'] = facilities_year_wch4frac_wellcounts[
        'sub_basin_identifier'].str.extract(r'(\d{3})')
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.Basin_ID)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.ch4_average_mole_fraction)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.well_producing_end_of_year)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts.sort_values(by='facility_id')
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts.drop_duplicates(
        subset=['table_desc', 'sub_basin_identifier', 'facility_id', 'Basin_ID', 'well_producing_end_of_year',
                'ch4_average_mole_fraction'])

    facilities_year_wch4frac_wellcounts = adjust_by_proportion(
        facilities_year_wch4frac_wellcounts,
        key_cols=['facility_id', 'sub_basin_identifier'],
        value_col='well_producing_end_of_year',
        proportion_mapping=proportions['facility_subbasin_to_well_prop']
    )
    facilities_year_wch4frac_wellcounts['Shape_ID'] = Shape_ID

    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ['facility_id', 'Basin_ID', 'well_producing_end_of_year', 'ch4_average_mole_fraction']]

    facilities_year_wch4frac_wellcounts = pd.concat([facilities_year, facilities_year_wch4frac_wellcounts])
    facilities_year_wch4frac_wellcounts.to_csv(os.path.join(GHGRPfolder, f'Facilities_{year}.csv'), index=False,
                                               header=False)

    # GAS_TO_FLARE.csv

    flare_data = pd.read_excel(flare_path, usecols=['INDUSTRY_SEGMENT', 'FACILITY_ID', 'GAS_SENT_TO_FLARE',
                                                    'FLARE_FEED_GAS_CH4_MOLE_FRACT', 'REPORTING_YEAR'], engine='pyxlsb')

    flare_data = flare_data[
        flare_data.INDUSTRY_SEGMENT == 'Onshore petroleum and natural gas production [98.230(a)(2)]']
    flare_year = flare_data[flare_data.REPORTING_YEAR == year]
    flare_year = flare_year.rename(columns={'FACILITY_ID': 'facility_id'})

    flare_year = pd.merge(flare_year, facilities_year_flare[['facility_id', 'Basin_ID', 'Oil_Gas']], on='facility_id',
                          how='left')
    flare_year = adjust_by_proportion(
        flare_year,
        key_cols=['facility_id'],
        value_col='GAS_SENT_TO_FLARE',
        proportion_mapping=proportions['facility_to_gas_prop']
    )
    flare_year['Basin_ID'] = Shape_ID

    flare_year[['Oil_Gas', 'Basin_ID', 'GAS_SENT_TO_FLARE', 'FLARE_FEED_GAS_CH4_MOLE_FRACT']].to_csv(os.path.join(activityfolder, f'GAS_TO_FLARE.csv'), index=False, header=False)

    # Equip_year.csv

    equip_data = pd.read_csv(equip_file_path)

    equip_data['equip_count_total'] = equip_data.maj_eq_type_count_east.fillna(
        0) + equip_data.maj_eq_type_count_west.fillna(0)

    # year
    equip_year = equip_data[equip_data.reporting_year == year]
    equip_year = equip_year[~pd.isna(equip_year.equipment_type)]
    equip_year = pd.merge(equip_year, facilities_year[['facility_id', 'Basin_ID']], on='facility_id', how='left')
    equip_year = equip_year.drop_duplicates(
        subset=['reporting_year', 'facility_id', 'Basin_ID', 'table_desc', 'equipment_type'])
    equip_year = equip_year[['facility_id', 'equipment_type', 'equip_count_total', 'Basin_ID', 'table_desc']]
    equip_year = equip_year.groupby(['facility_id', 'equipment_type', 'table_desc', 'Basin_ID'])[
        'equip_count_total'].sum().reset_index()
    equip_year = equip_year[['equipment_type', 'facility_id', 'equip_count_total', 'Basin_ID']]
    equip_year['Basin_ID'] = equip_year['Basin_ID'].fillna(0)

    # Adjust using the proportion of wells
    equip_year = adjust_by_proportion(
        equip_year,
        key_cols=['facility_id'],
        value_col='equip_count_total',
        proportion_mapping=proportions['facility_to_well_prop']
    )
    equip_year['Basin_ID'] = Shape_ID

    equip_year = equip_year.sort_values(by='facility_id')

    equip_year.to_csv(os.path.join(GHGRPfolder, f'Equip_{year}.csv'), index=False, header=False)

    # Jeff method

    # def extract_three_digit_number(s):
    #     match = re.search(r'\b\d{3}\b', s)
    #     if match:
    #         return int(match.group())
    #     else:
    #         return np.nan

    # # Apply the function to the DataFrame
    # equip_data['Basin_ID'] = equip_data['facility_name'].apply(extract_three_digit_number)

    # PC_year.csv

    pc_data = pd.read_csv(pc_file_path)

    # year
    PC_year = pc_data[pc_data.reporting_year == year]
    PC_year = pd.merge(PC_year, facilities_year[['facility_id', 'Basin_ID']], on='facility_id', how='left')
    # PC_year = PC_year.drop_duplicates(subset=['reporting_year', 'facility_id', 'Basin_ID', 'table_desc', 'total_count'])
    PC_year = PC_year[['facility_id', 'total_count', 'Basin_ID']]
    PC_year['Basin_ID'] = PC_year['Basin_ID'].fillna(0)

    # Adjust using the proportion of wells
    PC_year = adjust_by_proportion(
        PC_year,
        key_cols=['facility_id'],
        value_col='total_count',
        proportion_mapping=proportions['facility_to_well_prop']
    )
    PC_year['Basin_ID'] = Shape_ID

    PC_year = PC_year.sort_values(by='facility_id')
    PC_year.to_csv(os.path.join(GHGRPfolder, f'PC_{year}.csv'), header=None, index=False)

    # Pump_year.csv

    pump_data = pd.read_csv(pump_file_path)

    # year
    Pump_year = pump_data[pump_data.reporting_year == year]
    Pump_year = pd.merge(Pump_year, facilities_year[['facility_id', 'Basin_ID']], on='facility_id', how='left')
    Pump_year = Pump_year.drop_duplicates(
        subset=['reporting_year', 'facility_id', 'Basin_ID', 'table_desc', 'total_pneumatic_pump_count'])
    Pump_year = Pump_year[['facility_id', 'total_pneumatic_pump_count', 'Basin_ID']]

    # Adjust using the proportion of wells
    Pump_year = adjust_by_proportion(
        Pump_year,
        key_cols=['facility_id'],
        value_col='total_pneumatic_pump_count',
        proportion_mapping=proportions['facility_to_well_prop']
    )

    Pump_year['Basin_ID'] = Shape_ID

    Pump_year = Pump_year.sort_values(by='facility_id')
    Pump_year.to_csv(os.path.join(GHGRPfolder, f'Pump_{year}.csv'), index=False, header=False)

    # Tanks12_year.csv

    tanks12_data = pd.read_csv(tanks12_file_path)
    tanks12_data['Basin_ID'] = tanks12_data['sub_basin_identifier'].str.extract(r'(\d{3})')
    tanks12_data = tanks12_data[~pd.isna(tanks12_data.atmospheric_tank_count)]
    tanks12_data = tanks12_data[tanks12_data.atmospheric_tank_count > 0]

    # year
    tanks12_year = tanks12_data[tanks12_data.reporting_year == year]

    # Adjust using the proportion of oil
    tanks12_year = adjust_by_proportion(
        tanks12_year,
        key_cols=['facility_id', 'sub_basin_identifier'],
        value_col='total_volume_of_oil',
        proportion_mapping=proportions['facility_subbasin_to_oil_prop']
    )

    tanks12_year['QVRU'] = (tanks12_year['tanks_with_vapor_recovery'] * tanks12_year['total_volume_of_oil'] /
                            tanks12_year['atmospheric_tank_count']) / 1000000
    tanks12_year['QVent'] = (tanks12_year['tanks_venting_to_atm'] * tanks12_year['total_volume_of_oil'] / tanks12_year[
        'atmospheric_tank_count']) / 1000000
    tanks12_year['QFlare'] = (tanks12_year['tanks_with_flaring'] * tanks12_year['total_volume_of_oil'] / tanks12_year[
        'atmospheric_tank_count']) / 1000000
    tanks12_year['Basin_ID'] = tanks12_year['Basin_ID'].fillna(0)
    tanks12_year['QVRU'] = tanks12_year['QVRU'].fillna(0)
    tanks12_year['QVent'] = tanks12_year['QVent'].fillna(0)
    tanks12_year['QFlare'] = tanks12_year['QFlare'].fillna(0)

    tanks12_year['Basin_ID'] = Shape_ID

    tanks12_year = tanks12_year.sort_values(by='facility_id')

    tanks12_year = tanks12_year[['facility_id', 'QVRU', 'QVent', 'QFlare', 'atmospheric_tank_count', 'Basin_ID']]
    tanks12_year.to_csv(os.path.join(GHGRPfolder, f'Tanks12_{year}.csv'), index=False, header=False)

    # Tanks3_year.csv

    tanks3_data = pd.read_csv(tanks3_file_path)
    print('len(tanks3_data)', len(tanks3_data))
    tanks3_data = tanks3_data.fillna(0)
    tanks3_data_atm_counts = tanks3_data[~pd.isna(tanks3_data.atmospheric_tank_count)]
    tanks3_data_basins = tanks3_data[~pd.isna(tanks3_data.sub_basin_identifier)][
        ['facility_id', 'sub_basin_identifier']]
    tanks3_data_atm_counts = tanks3_data_atm_counts.drop(columns=['sub_basin_identifier'])
    tanks3_data = tanks3_data_atm_counts.merge(tanks3_data_basins, on=['facility_id'])
    tanks3_data['Basin_ID'] = tanks3_data['sub_basin_identifier'].str.extract(r'(\d{3})')
    tanks3_data = tanks3_data[~pd.isna(tanks3_data.atmospheric_tank_count)]

    # subset = ['annual_oil_throughput', 'atmospheric_tank_count',
    #           'ch4_emissions_from_flare', 'ch4_emissions_not_flared', 'facility_name', 'fract_oil_throughput_flaring',
    #           'fract_throughput_with_vapor', 'facility_id', 'industry_segment', 'reporting_year',
    #           'Basin_ID']
    # tanks3_data = tanks3_data[subset]
    # tanks3_data = tanks3_data.drop_duplicates(subset=subset)

    # year
    tanks3_year = tanks3_data[tanks3_data.reporting_year == year]
    tanks3_year = tanks3_year[tanks3_year.table_desc == 'Wells and separators with oil throughput <10 barrels/day using Calculation Methodology 3']
    subset = ['annual_oil_throughput', 'atmospheric_tank_count',
              'ch4_emissions_from_flare', 'ch4_emissions_not_flared', 'facility_name', 'fract_oil_throughput_flaring',
              'fract_throughput_with_vapor', 'facility_id', 'industry_segment', 'reporting_year',
              'Basin_ID']
    tanks3_year = tanks3_year.drop_duplicates(subset=subset)
    # Adjust using the proportion of oil
    tanks3_year = adjust_by_proportion(
        tanks3_year,
        key_cols=['facility_id', 'sub_basin_identifier'],
        value_col='annual_oil_throughput',
        proportion_mapping=proportions['facility_subbasin_to_oil_prop']
    )
    print(tanks3_year)

    tanks3_year['fract_throughput_with_vapor'] = tanks3_year['fract_throughput_with_vapor'].fillna(0)
    tanks3_year['fract_oil_throughput_flaring'] = tanks3_year['fract_oil_throughput_flaring'].fillna(0)
    tanks3_year['QVRU'] = (tanks3_year['fract_throughput_with_vapor'] * tanks3_year['annual_oil_throughput']) / 1000000
    tanks3_year['QFlare'] = (tanks3_year['fract_oil_throughput_flaring'] * tanks3_year[
        'annual_oil_throughput']) / 1000000
    tanks3_year['QVent'] = (tanks3_year['annual_oil_throughput'] / 1000000) - tanks3_year['QVRU'] - tanks3_year[
        'QFlare']
    tanks3_year['Basin_ID'] = tanks3_year['Basin_ID'].fillna(0)
    tanks3_year['QVRU'] = tanks3_year['QVRU'].fillna(0)
    tanks3_year['QVent'] = tanks3_year['QVent'].fillna(0)
    tanks3_year['QFlare'] = tanks3_year['QFlare'].fillna(0)

    tanks3_year['Basin_ID'] = Shape_ID

    tanks3_year = tanks3_year.sort_values(by='facility_id')

    tanks3_year = tanks3_year[['facility_id', 'QVRU', 'QVent', 'QFlare', 'atmospheric_tank_count', 'Basin_ID']]
    tanks3_year.to_csv(os.path.join(GHGRPfolder, f'Tanks3_{year}.csv'), index=False, header=False)

    # LU_type.csv
    # Load LU dataset for the given year
    LU_data = pd.read_csv(LU_file_path)
    LU_year = LU_data[LU_data.reporting_year == year].copy()

    # Compute total LU wells
    LU_year['nb_wells_LU'] = LU_year.number_of_wells.fillna(0) + LU_year.number_of_wells_vented.fillna(0)

    # Adjust LU wells using shape-based well proportions
    LU_year = adjust_by_proportion(
        LU_year,
        key_cols=['facility_id', 'sub_basin_identifier'],
        value_col='nb_wells_LU',
        proportion_mapping=proportions['facility_subbasin_to_well_prop']
    )

    if LU_year.empty:
        # No LU activity in shape → write fallback row only
        LU_export = pd.DataFrame([[0, 0, 1]], columns=['fract_LU_with_plunger', 'fract_LU_without_plunger', 'fract_no_LU'])
    else:
        # Process plunger lift info
        LU_year['plunger_lifts_used'] = LU_year['plunger_lifts_used'].replace({'Yes': 1, 'No': 0}).fillna(0)
        LU_year['nb_wells_LU_plunger'] = LU_year.nb_wells_LU * LU_year.plunger_lifts_used
        LU_year['nb_wells_LU_no_plunger'] = LU_year.nb_wells_LU - LU_year.nb_wells_LU_plunger

        # Total LU wells
        LU_with_plunger = LU_year['nb_wells_LU_plunger'].sum()
        LU_without_plunger = LU_year['nb_wells_LU_no_plunger'].sum()
        total_LU = LU_with_plunger + LU_without_plunger

        # Adjust equip counts (Wellheads) using facility-based shape proportions
        equip_year = equip_data[equip_data.reporting_year == year].copy()
        facilities_year = facilities_data[facilities_data.reporting_year == year][['facility_id', 'sub_basin_identifier']]
        equip_year = pd.merge(equip_year, facilities_year, on='facility_id', how='left')
        equip_year = equip_year[equip_year.equipment_type == 'Wellhead']

        equip_year = adjust_by_proportion(
            equip_year,
            key_cols=['facility_id'],
            value_col='equip_count_total',
            proportion_mapping=proportions['facility_to_well_prop']
        )

        total_wellheads = equip_year['equip_count_total'].sum()

        # Compute LU fractions
        fract_LU_with = LU_with_plunger / total_wellheads if total_wellheads > 0 else 0
        fract_LU_without = LU_without_plunger / total_wellheads if total_wellheads > 0 else 0
        fract_no_LU = 1 - fract_LU_with - fract_LU_without

        LU_export = pd.DataFrame([[fract_LU_with, fract_LU_without, fract_no_LU]],
                                 columns=['fract_LU_with_plunger', 'fract_LU_without_plunger', 'fract_no_LU'])

    # Save to LU_type.csv
    LU_export.to_csv(os.path.join(activityfolder, 'LU_type.csv'), index=False, header=False)

def generate_production_data_calgem(year, inputsfolder, Shape_ID, Shape_Name, shape_gdf):
    calgem_path = os.path.join(inputsfolder, 'CalGEM')

    # Load well headers with lat/lon (always use AllWells_20250220.csv)
    well_headers_path = os.path.join(calgem_path, "AllWells_20250220.csv")
    CalGEM_well_headers = pd.read_csv(well_headers_path)
    CalGEM_well_headers['API14'] = (CalGEM_well_headers['API'].astype(str) + '0000').str.zfill(14)
    CalGEM_well_headers['Surface Hole Latitude (WGS84)'] = pd.to_numeric(CalGEM_well_headers['Latitude'],
                                                                         errors='coerce')
    CalGEM_well_headers['Surface Hole Longitude (WGS84)'] = pd.to_numeric(CalGEM_well_headers['Longitude'],
                                                                          errors='coerce')
    CalGEM_well_headers['geometry'] = CalGEM_well_headers.apply(
        lambda row: Point(row['Surface Hole Longitude (WGS84)'], row['Surface Hole Latitude (WGS84)']), axis=1
    )
    CalGEM_well_headers = gpd.GeoDataFrame(CalGEM_well_headers, geometry='geometry', crs='EPSG:4326')

    # Load production data
    prod_path = os.path.join(calgem_path, f"{year}CaliforniaOilAndGasWellMonthlyProduction.csv")
    CalGEM_prod = pd.read_csv(prod_path)

    if year < 2020:
        # Pre-2020: join using PWT__ID and year-specific header
        year_headers_path = os.path.join(calgem_path, f"{year}CaliforniaOilandGasWells.csv")
        year_headers = pd.read_csv(year_headers_path, encoding='latin1')
        CalGEM_prod = CalGEM_prod.merge(year_headers[['PWT__ID', 'APINumber']], on='PWT__ID', how='left')
        CalGEM_prod['APINumber'] = CalGEM_prod['APINumber'].astype(str).str.zfill(8)
        CalGEM_prod['API14'] = '04' + CalGEM_prod['APINumber'] + '0000'
        CalGEM_prod['Monthly Gas'] = CalGEM_prod['GasProduced(MCF)']
        CalGEM_prod['Monthly Production Date'] = pd.to_datetime(CalGEM_prod['ProductionDate'], errors='coerce')
    else:
        CalGEM_prod['API14'] = (CalGEM_prod['APINumber'].astype(str) + '00').str.zfill(14)
        CalGEM_prod['Monthly Gas'] = CalGEM_prod['GasProduced']
        CalGEM_prod['Monthly Production Date'] = pd.to_datetime(CalGEM_prod['ProductionReportDate'], errors='coerce')

    CalGEM_prod['Monthly Oil'] = CalGEM_prod['OilorCondensateProduced']
    CalGEM_prod['API14'] = CalGEM_prod['API14'].astype(str)
    CalGEM_well_headers['API14'] = CalGEM_well_headers['API14'].astype(str)

    merged_cols = ['API14', 'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)', 'geometry']

    CalGEM_prod = CalGEM_prod.merge(CalGEM_well_headers[merged_cols], on='API14', how='left')
    CalGEM_prod = gpd.GeoDataFrame(CalGEM_prod, geometry='geometry', crs='EPSG:4326')

    # Determine whether each well is inside the shape
    Shape_Geometry = gpd.GeoSeries([shape_gdf.iloc[0].geometry], crs=shape_gdf.crs).to_crs(26914).iloc[0]

    inside_mask = CalGEM_prod.to_crs(26914).within(Shape_Geometry)
    CalGEM_prod['Prov_Cod_1'] = 0
    CalGEM_prod.loc[inside_mask, 'Prov_Cod_1'] = Shape_ID
    spatial_join = CalGEM_prod

    keep_cols = [
        'API14', 'Monthly Gas', 'Monthly Oil',
        'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)',
        'geometry', 'Prov_Cod_1'
    ]
    spatial_join = spatial_join[keep_cols]

    grouped = (
        spatial_join.groupby('API14')
        .agg({
            'Monthly Oil': 'sum',
            'Monthly Gas': 'sum',
            'Surface Hole Latitude (WGS84)': 'first',
            'Surface Hole Longitude (WGS84)': 'first',
            'geometry': 'first',
            'Prov_Cod_1': 'first'

        })
        .reset_index()
    )
    spatial_join = gpd.GeoDataFrame(grouped, geometry='geometry', crs='EPSG:26914')
    print(spatial_join.API14.nunique())
    return spatial_join
#
# def generate_production_data_di(year, inputsfolder, Shape_ID, Shape_Name, Shape_Geometry):
#     raw_enverus_drillinginfo_foldername = os.path.join(inputsfolder, 'Enverus_DrillingInfo')
#
#     # Load production data
#     wellsproduction_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Production')
#     wellsproduction_csv_files = [f for f in os.listdir(wellsproduction_folderpath) if f.lower().endswith('.csv')]
#     wellsproduction_df = pd.concat([
#         pd.read_csv(os.path.join(wellsproduction_folderpath, file),
#                     usecols=['API/UWI', 'Monthly Oil', 'Monthly Gas', 'Monthly Production Date'])
#         for file in wellsproduction_csv_files
#     ], ignore_index=True)
#
#     wellsproduction_df['Year'] = pd.to_datetime(wellsproduction_df['Monthly Production Date']).dt.year
#     wellsproduction_df = wellsproduction_df[wellsproduction_df['Year'] == year]
#     wellsproduction_df = wellsproduction_df.groupby(['API/UWI'])[['Monthly Gas', 'Monthly Oil']].sum().reset_index()
#
#     # Load well header info
#     wellsinfo_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Wells')
#     wellsinfo_csv_files = [f for f in os.listdir(wellsinfo_folderpath) if f.lower().endswith('.csv')]
#     wellsinfo_df = pd.concat([
#         pd.read_csv(os.path.join(wellsinfo_folderpath, file),
#                     usecols=['API14', 'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)'])
#         for file in wellsinfo_csv_files
#     ], ignore_index=True)
#
#     wellsinfo_df = wellsinfo_df.rename(
#         columns={'Surface Hole Latitude (WGS84)': 'lat', 'Surface Hole Longitude (WGS84)': 'lon'}
#     )
#     wellsinfo_df = wellsinfo_df.dropna(subset=['lat', 'lon'])
#
#     # Create GeoDataFrame for wells
#     geometry = [Point(lon, lat) for lat, lon in zip(wellsinfo_df.lat, wellsinfo_df.lon)]
#     wellsinfo_gdf = gpd.GeoDataFrame(wellsinfo_df, geometry=geometry, crs='EPSG:4326')
#
#     # Determine whether each well is inside the shape
#     Shape_Geometry = gpd.GeoSeries([Shape_Geometry], crs='EPSG:4326').to_crs(26914).iloc[0]
#
#     inside_mask = wellsinfo_gdf.to_crs(26914).within(Shape_Geometry)
#     wellsinfo_gdf['Prov_Cod_1'] = 0
#     wellsinfo_gdf.loc[inside_mask, 'Prov_Cod_1'] = Shape_ID
#
#     # Merge production and well data
#     wellsproduction_df = wellsproduction_df.rename(columns={'API/UWI': 'API14'})
#     spatial_join = wellsproduction_df.merge(wellsinfo_gdf, on='API14', how='inner')
#
#     return spatial_join


def generate_production_data_di(year, inputsfolder, Shape_ID, Shape_Name, shape_gdf):
    import os
    import pandas as pd
    import geopandas as gpd
    from shapely.geometry import Point

    raw_enverus_drillinginfo_foldername = os.path.join(inputsfolder, 'Enverus_DrillingInfo')
    wellsproduction_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Production')
    wellsinfo_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Wells')

    wellsproduction_csv_files = [f for f in os.listdir(wellsproduction_folderpath) if f.lower().endswith('.csv')]
    wellsinfo_csv_files = [f for f in os.listdir(wellsinfo_folderpath) if f.lower().endswith('.csv')]

    # Split by Kansas vs. other
    ks_prod_files = [f for f in wellsproduction_csv_files if 'ks' in f.lower()]
    nonks_prod_files = [f for f in wellsproduction_csv_files if 'ks' not in f.lower()]
    ks_well_files = [f for f in wellsinfo_csv_files if 'ks' in f.lower()]
    nonks_well_files = [f for f in wellsinfo_csv_files if 'ks' not in f.lower()]

    all_wells_dfs = []

    # === Kansas processing ===
    if ks_prod_files and ks_well_files:
        producing_entity_monthly_prod_ks = pd.concat([
            pd.read_csv(os.path.join(wellsproduction_folderpath, file),
                        usecols=['Entity ID','API/UWI', 'API/UWI List', 'Well Count',
                                 'Monthly Oil', 'Monthly Gas', 'Well/Lease Name', 'Entity Type', 'Monthly Production Date'])
            for file in ks_prod_files
        ], ignore_index=True)

        producing_entity_monthly_prod_ks['Year'] = pd.to_datetime(producing_entity_monthly_prod_ks['Monthly Production Date']).dt.year
        producing_entity_monthly_prod_ks = producing_entity_monthly_prod_ks[producing_entity_monthly_prod_ks['Year'] == year]
        producing_entity_monthly_prod_ks = producing_entity_monthly_prod_ks.groupby(['API/UWI', 'API/UWI List'])[['Monthly Gas', 'Monthly Oil']].sum().reset_index()

        well_headers_ks = pd.concat([
            pd.read_csv(os.path.join(wellsinfo_folderpath, f))
            for f in ks_well_files
        ], ignore_index=True)[['API14', 'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)']]

        well_headers_ks['API14'] = well_headers_ks['API14'].astype(str).str.strip().str.ljust(14, '0')

        df1 = producing_entity_monthly_prod_ks.rename(columns={'API/UWI List': 'API14_list_df1'})
        df1['API14_list_df1'] = df1['API14_list_df1'].str.split(',').apply(
            lambda x: [str(i).strip().ljust(14, '0') for i in x if i.strip()] if isinstance(x, list) else [str(x).strip().ljust(14, '0')]
        )
        df1['entity_index'] = df1.index
        df1_exploded = df1.explode('API14_list_df1').copy()
        df1_exploded['API14'] = df1_exploded['API14_list_df1']

        merged_ks = well_headers_ks.merge(df1_exploded, on='API14', how='inner')
        merged_ks['n_wells'] = merged_ks.groupby('entity_index')['API14'].transform('nunique')
        for col in ['Monthly Oil', 'Monthly Gas']:
            if col in merged_ks.columns:
                merged_ks[col] = merged_ks[col] / merged_ks['n_wells']
        merged_ks = merged_ks.drop(columns=['API14_list_df1', 'entity_index', 'n_wells']).drop_duplicates()

        merged_ks = merged_ks.rename(columns={
            'Surface Hole Latitude (WGS84)': 'lat',
            'Surface Hole Longitude (WGS84)': 'lon'
        }).dropna(subset=['lat', 'lon'])

        all_wells_dfs.append(merged_ks)

    # === Default (non-Kansas) processing ===
    if nonks_prod_files and nonks_well_files:
        wellsproduction_df = pd.concat([
            pd.read_csv(os.path.join(wellsproduction_folderpath, file),
                        usecols=['API/UWI', 'Monthly Oil', 'Monthly Gas', 'Monthly Production Date'])
            for file in nonks_prod_files
        ], ignore_index=True)

        wellsproduction_df['Year'] = pd.to_datetime(wellsproduction_df['Monthly Production Date']).dt.year
        wellsproduction_df = wellsproduction_df[wellsproduction_df['Year'] == year]
        wellsproduction_df = wellsproduction_df.groupby(['API/UWI'])[['Monthly Gas', 'Monthly Oil']].sum().reset_index()
        wellsproduction_df = wellsproduction_df.rename(columns={'API/UWI': 'API14'})

        wellsinfo_df = pd.concat([
            pd.read_csv(os.path.join(wellsinfo_folderpath, file),
                        usecols=['API14', 'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)'])
            for file in nonks_well_files
        ], ignore_index=True)

        wellsinfo_df = wellsinfo_df.rename(columns={
            'Surface Hole Latitude (WGS84)': 'lat',
            'Surface Hole Longitude (WGS84)': 'lon'
        }).dropna(subset=['lat', 'lon'])

        merged_nonks = wellsproduction_df.merge(wellsinfo_df, on='API14', how='inner').dropna(subset=['lat', 'lon'])

        all_wells_dfs.append(merged_nonks)

    # === Concatenate ===
    if not all_wells_dfs:
        raise RuntimeError("No valid wells found for this year.")

    wells_df = pd.concat(all_wells_dfs, ignore_index=True)

    # === Spatial filtering ===
    geometry = [Point(lon, lat) for lat, lon in zip(wells_df['lat'], wells_df['lon'])]
    wells_gdf = gpd.GeoDataFrame(wells_df, geometry=geometry, crs='EPSG:4326')

    Shape_Geometry = gpd.GeoSeries([shape_gdf.iloc[0].geometry], crs=shape_gdf.crs).to_crs(26914).iloc[0]
    inside_mask = wells_gdf.to_crs(26914).within(Shape_Geometry)
    wells_gdf['Prov_Cod_1'] = 0
    wells_gdf.loc[inside_mask, 'Prov_Cod_1'] = Shape_ID

    # Create GeoDataFrame for wells
    geometry = [Point(lon, lat) for lat, lon in zip(wells_df['lat'], wells_df['lon'])]
    wells_gdf_plot = gpd.GeoDataFrame(wells_df, geometry=geometry, crs='EPSG:4326')

    # Plot and export before spatial join
    fig, ax = plt.subplots(figsize=(10, 10))
    wells_gdf_plot.to_crs(26914).plot(ax=ax, markersize=5, color='blue', alpha=0.5, label='Wells')

    # Plot shape outline
    shape_gdf.to_crs(26914).boundary.plot(ax=ax, color='red', linewidth=2, label='Shape')

    ax.legend()
    ax.set_title('Wells and Target Shape')
    plt.savefig('wells_vs_shape.png', dpi=300)
    plt.close()

    return wells_gdf




def generate_production_data(year, inputsfolder, productionfolder, productionsource, Shape_ID, Shape_Name, shape_gdf):

    if productionsource == 'DrillingInfo':
        spatial_join = generate_production_data_di(year, inputsfolder, Shape_ID, Shape_Name, shape_gdf)
    elif productionsource == 'CalGEM':
        spatial_join = generate_production_data_calgem(year, inputsfolder, Shape_ID, Shape_Name, shape_gdf)
    else:
        print('Production source unknown.')
        return

    # Harmonize final output
    spatial_join = spatial_join[pd.to_numeric(spatial_join.API14, errors='coerce').fillna(0).astype(int) != 0]
    spatial_join = spatial_join.dropna(subset=['Prov_Cod_1'])

    spatial_join = spatial_join.rename(columns={
        'Monthly Gas': 'Monthly_Ga',
        'Monthly Oil': 'Monthly_Oi',
        'lat': 'Surface_Ho',
        'lon': 'Surface__1',
        'Surface Hole Latitude (WGS84)': 'Surface_Ho',
        'Surface Hole Longitude (WGS84)': 'Surface__1'
    })

    for col in ['OBJECTID', 'Join_Count', 'TARGET_FID', 'Field1']:
        spatial_join[col] = None

    spatial_join = spatial_join[[
        'OBJECTID', 'Join_Count', 'TARGET_FID', 'Field1',
        'Monthly_Oi', 'Monthly_Ga', 'API14', 'Surface_Ho', 'Surface__1', 'Prov_Cod_1'
    ]]

    outname = f'annualDF_{year}_SpatialJoin_2258.csv'

    spatial_join.to_csv(os.path.join(productionfolder, outname), index=False)
    return None



def return_wells_to_facility(year, inputsfolder, productionfolder, GHGRPfolder):

    # Load GHGRP well info
    wells_data_filename = os.path.join(inputsfolder, 'EF_W_ONSHORE_WELLS', f'EF_W_ONSHORE_WELLS_{year}.xlsb')
    wells_data = pd.read_excel(wells_data_filename, usecols=['FACILITY_ID', 'WELL_ID_NUMBER', 'SUB_BASIN'], engine='pyxlsb')

    wells_data = wells_data.dropna(subset=['WELL_ID_NUMBER'])
    wells_data = wells_data[~pd.isna(wells_data.WELL_ID_NUMBER)]
    wells_data = wells_data[wells_data.WELL_ID_NUMBER != 0]
    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].astype(str)

    scientific_notation_wells = wells_data[wells_data['WELL_ID_NUMBER'].str.contains(r'E\+', case=False, na=False)]
    wells_data.loc[scientific_notation_wells.index, 'WELL_ID_NUMBER'] = scientific_notation_wells['WELL_ID_NUMBER'].apply(lambda x: '{:.0f}'.format(float(x)))

    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].str.replace('-', '')
    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].str.replace(r'\D+', '', regex=True)
    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].str.lstrip('0')

    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].apply(
        lambda x: x.ljust(14, '0') if len(x) == 12 else
        x.ljust(13, '0') if len(x) == 11 else
        x.ljust(14, '0') if len(x) == 10 else
        x.ljust(13, '0') if len(x) == 9 else x
    )

    wells_data['API14'] = wells_data['WELL_ID_NUMBER']

    # Load production data with original column names
    production_file = os.path.join(productionfolder, f'annualDF_{year}_SpatialJoin_2258.csv')
    production_df = pd.read_csv(
        production_file,
        skiprows=1,
        usecols=[4, 5, 6, 7, 8, 9],
        names=['Annual Oil [bbl/year]', 'Annual Gas [mscf/year]', 'API/UWI', 'Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)', 'Prov_Cod_1'],
        dtype={'API/UWI': str}, encoding_errors='ignore'
    )
    production_df['API/UWI'] = production_df['API/UWI'].str.lstrip('0')
    production_df = production_df.drop_duplicates(subset=['API/UWI'])

    # Merge
    merged = production_df.merge(wells_data[['API14', 'FACILITY_ID', 'SUB_BASIN']], left_on='API/UWI', right_on='API14', how='inner')

    # Save without SUB_BASIN
    to_save = merged.drop(columns=['SUB_BASIN','Surface Hole Latitude (WGS84)', 'Surface Hole Longitude (WGS84)' ], errors='ignore')
    filename = f'API_Facility_correspondence_{year}.csv'
    print(len(to_save))
    to_save.to_csv(os.path.join(productionfolder, filename), index=False)
    to_save.to_csv(os.path.join(GHGRPfolder, filename), index=False)

    # Compute proportions

    merged['in_shape'] = merged['Prov_Cod_1'] != 0

    facility_to_well_prop = merged.groupby('FACILITY_ID')['in_shape'].mean().to_dict()

    facility_to_oil_prop = (
        merged.groupby('FACILITY_ID').apply(
            lambda df: df.loc[df.in_shape, 'Annual Oil [bbl/year]'].sum() / df['Annual Oil [bbl/year]'].sum()
            if df['Annual Oil [bbl/year]'].sum() > 0 else 1
        ).to_dict()
    )
    facility_to_gas_prop = (
        merged.groupby('FACILITY_ID').apply(
            lambda df: df.loc[df.in_shape, 'Annual Gas [mscf/year]'].sum() / df['Annual Gas [mscf/year]'].sum()
            if df['Annual Gas [mscf/year]'].sum() > 0 else 1
        ).to_dict()
    )

    facility_subbasin_to_well_prop = (
        merged.groupby(['FACILITY_ID', 'SUB_BASIN'])['in_shape'].mean().to_dict()
    )

    facility_subbasin_to_oil_prop = (
        merged.groupby(['FACILITY_ID', 'SUB_BASIN']).apply(
            lambda df: df.loc[df.in_shape, 'Annual Oil [bbl/year]'].sum() / df['Annual Oil [bbl/year]'].sum()
            if df['Annual Oil [bbl/year]'].sum() > 0 else 0
        ).to_dict()
    )

    # Filter facilities with at least one well in shape
    in_shape_facilities = [fid for fid, v in facility_to_well_prop.items() if v > 0]

    # Subsets for oil/gas-producing facilities
    in_shape_facilities_with_oil = [fid for fid in in_shape_facilities if facility_to_oil_prop.get(fid, 0) > 0]
    in_shape_facilities_with_gas = [fid for fid in in_shape_facilities if facility_to_gas_prop.get(fid, 0) > 0]

    # Compute means over relevant subsets
    mean_well_prop = sum(facility_to_well_prop[fid] for fid in in_shape_facilities) / len(
        in_shape_facilities) if in_shape_facilities else 0
    mean_oil_prop = sum(facility_to_oil_prop[fid] for fid in in_shape_facilities_with_oil) / len(
        in_shape_facilities_with_oil) if in_shape_facilities_with_oil else 0
    mean_gas_prop = sum(facility_to_gas_prop[fid] for fid in in_shape_facilities_with_gas) / len(
        in_shape_facilities_with_gas) if in_shape_facilities_with_gas else 0

    # Print
    print(f"Facilities with at least 1 well in shape: {len(in_shape_facilities)}")
    print(f"Facilities with oil production in shape: {len(in_shape_facilities_with_oil)}")
    print(f"Facilities with gas production in shape: {len(in_shape_facilities_with_gas)}")
    print(f"Mean fraction of wells in shape: {mean_well_prop:.3f}")
    print(f"Mean fraction of oil in shape: {mean_oil_prop:.3f}")
    print(f"Mean fraction of gas in shape: {mean_gas_prop:.3f}")
    print("\nDetailed proportions for facilities with ≥1 well in shape:")
    for fid in in_shape_facilities:
        well_prop = facility_to_well_prop.get(fid, 0)
        oil_prop = facility_to_oil_prop.get(fid, 0)
        gas_prop = facility_to_gas_prop.get(fid, 0)
        print(f"  Facility {fid}: wells={well_prop:.3f}, oil={oil_prop:.3f}, gas={gas_prop:.3f}")

    proportions = {
        'facility_to_well_prop': facility_to_well_prop,
        'facility_to_oil_prop': facility_to_oil_prop,
        'facility_to_gas_prop': facility_to_gas_prop,
        'facility_subbasin_to_well_prop': facility_subbasin_to_well_prop,
        'facility_subbasin_to_oil_prop': facility_subbasin_to_oil_prop
    }

    with open(os.path.join(GHGRPfolder, f'Facility_Proportions_{year}.pkl'), 'wb') as f:
        pickle.dump(proportions, f)

    # Plot facilities

    gdf = gpd.GeoDataFrame(
        merged,
        geometry=gpd.points_from_xy(
            merged['Surface Hole Longitude (WGS84)'],
            merged['Surface Hole Latitude (WGS84)']
        ),
        crs="EPSG:4326"
    )

    # Select only facilities that have at least 1 well in shape
    fids_with_wells_in_shape = set(in_shape_facilities)

    # Filter to wells from those facilities
    subset = gdf[gdf['FACILITY_ID'].isin(fids_with_wells_in_shape)]

    # Split into inside and outside
    in_shape_wells = subset[subset['in_shape']]
    out_shape_wells = subset[~subset['in_shape']]

    # Create output directory
    output_dir = "Facility_Maps"
    os.makedirs(output_dir, exist_ok=True)
    # Plot
    fig, ax = plt.subplots(figsize=(10, 8))
    if not in_shape_wells.empty:
        in_shape_wells.plot(ax=ax, color='blue', markersize=10, label='Wells in shape')
    if not out_shape_wells.empty:
        out_shape_wells.plot(ax=ax, color='red', markersize=10, label='Wells outside shape', alpha=0.6)

    plt.title(f"Wells from facilities with at least 1 well in shape")
    plt.legend()
    plt.xlabel("Longitude")
    plt.ylabel("Latitude")
    plt.tight_layout()

    # Save plot
    output_path = os.path.join(output_dir, f'wells_in_out_shape_{year}.png')
    plt.savefig(output_path, dpi=300)
    plt.close()


    for fid in sorted(fids_with_wells_in_shape):
        facility_wells = subset[subset['FACILITY_ID'] == fid]
        in_shape = facility_wells[facility_wells['in_shape']]
        out_shape = facility_wells[~facility_wells['in_shape']]
        print(f"Facility {fid}: {len(in_shape)} in-shape wells, {len(out_shape)} out-of-shape wells")

        fig, ax = plt.subplots(figsize=(8, 6))
        plotted = False

        if not out_shape.empty:
            out_shape.plot(ax=ax, color='red', markersize=10, label='Wells outside shape', alpha=0.6)
            plotted = True

        if not in_shape.empty:
            in_shape.plot(ax=ax, color='blue', markersize=15, edgecolor='black', label='Wells in shape')
            plotted = True

        if plotted:
            ax.set_title(f"Facility {fid} — Wells in vs out of shape")
            ax.set_xlabel("Longitude")
            ax.set_ylabel("Latitude")
            ax.legend()
            ax.set_aspect('equal')
            plt.tight_layout()
            plt.savefig(os.path.join(output_dir, f'facility_{fid}_wells_shape.png'), dpi=300)
            plt.close()

    return {
        'facility_to_well_prop': facility_to_well_prop,
        'facility_to_oil_prop': facility_to_oil_prop,
        'facility_to_gas_prop': facility_to_gas_prop,
        'facility_subbasin_to_well_prop': facility_subbasin_to_well_prop,
        'facility_subbasin_to_oil_prop': facility_subbasin_to_oil_prop
    }

