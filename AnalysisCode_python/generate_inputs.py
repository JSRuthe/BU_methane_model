import pandas as pd
import warnings
import os
warnings.filterwarnings('ignore')
from shapely.geometry import Point
import geopandas as gpd
print(f"os module: {os}")

def generate_ghgrp_dat(year, Basin_N, inputsfolder, GHGRPfolder, activityfolder):
    raw_GHGRPfolder = os.path.join(inputsfolder, 'GHGRP')

    facilities_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_FACILITY_OVERVIEW.CSV')
    equip_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_EQUIP_LEAKS_ONSHORE.CSV')
    pc_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_NGPNEUMATIC_DEV_UNITS.CSV')
    pump_file_path = os.path.join(raw_GHGRPfolder, 'EF_W_NGPNEUMATIC_PMP_UNITS.CSV')
    tanks12_file_path = os.path.join(raw_GHGRPfolder, 'ATM_STG_TANKS_CALC1OR2.CSV')
    tanks3_file_path = os.path.join(raw_GHGRPfolder, 'ATM_STG_TANKS_CALC3.CSV')
    LU_file_path = os.path.join(raw_GHGRPfolder, 'LIQUIDS_UNLOAD_UNITS.CSV')

    # Facility_Basin_correspondence_2020.csv
    facilities_data = pd.read_csv(facilities_file_path)

    facilities_data['basin_id'] = facilities_data['sub_basin_identifier'].str.extract(r'(\d{3})')

    # year
    facilities_year = facilities_data[facilities_data.reporting_year == year]
    facilities_year = facilities_year[~pd.isna(facilities_year.basin_id)]
    facilities_year = facilities_year[['facility_id', 'basin_id']]
    facilities_year = facilities_year.sort_values(by='facility_id')
    facilities_year = facilities_year.drop_duplicates(subset=['facility_id', 'basin_id'])
    facilities_year = facilities_year.rename(columns={'facility_id': 'FACILITY_ID', 'basin_id': 'Basin_ID'})
    facilities_year.to_csv(os.path.join(GHGRPfolder, f'Facility_Basin_correspondence_{year}.csv'), index=False, encoding='utf-8')

    # Facilities_year.csv

    facilities_data['basin_id'] = facilities_data['sub_basin_identifier'].str.extract(r'(\d{3})')

    # year
    facilities_year = facilities_data[facilities_data.reporting_year == year]
    facilities_year = facilities_year[~pd.isna(facilities_year.basin_id)]
    facilities_year = facilities_year[['facility_id', 'basin_id']]
    facilities_year = facilities_year.sort_values(by='facility_id')
    facilities_year = facilities_year.drop_duplicates(subset=['facility_id', 'basin_id'])

    # year
    facilities_year_wch4frac_wellcounts = facilities_data[facilities_data.reporting_year == year]
    facilities_year_wch4frac_wellcounts['basin_id'] = facilities_year_wch4frac_wellcounts[
        'sub_basin_identifier'].str.extract(r'(\d{3})')
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.basin_id)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.ch4_average_mole_fraction)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ~pd.isna(facilities_year_wch4frac_wellcounts.well_producing_end_of_year)]
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts.sort_values(by='facility_id')
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts.drop_duplicates(
        subset=['table_desc', 'sub_basin_identifier', 'facility_id', 'basin_id', 'well_producing_end_of_year',
                'ch4_average_mole_fraction'])
    facilities_year_wch4frac_wellcounts = facilities_year_wch4frac_wellcounts[
        ['facility_id', 'basin_id', 'well_producing_end_of_year', 'ch4_average_mole_fraction']]
    facilities_year_wch4frac_wellcounts = pd.concat([facilities_year, facilities_year_wch4frac_wellcounts])
    facilities_year_wch4frac_wellcounts.to_csv(os.path.join(GHGRPfolder, f'Facilities_{year}.csv'), index=False,
                                               header=False)

    # Equip_year.csv

    equip_data = pd.read_csv(equip_file_path)

    equip_data['equip_count_total'] = equip_data.maj_eq_type_count_east.fillna(
        0) + equip_data.maj_eq_type_count_west.fillna(0)

    # year
    equip_year = equip_data[equip_data.reporting_year == year]
    equip_year = equip_year[~pd.isna(equip_year.equipment_type)]
    equip_year = pd.merge(equip_year, facilities_year[['facility_id', 'basin_id']], on='facility_id', how='left')
    equip_year = equip_year.drop_duplicates(
        subset=['reporting_year', 'facility_id', 'basin_id', 'table_desc', 'equipment_type'])
    equip_year = equip_year[['facility_id', 'equipment_type', 'equip_count_total', 'basin_id', 'table_desc']]
    equip_year = equip_year.groupby(['facility_id', 'equipment_type', 'table_desc', 'basin_id'])[
        'equip_count_total'].sum().reset_index()
    equip_year = equip_year[['equipment_type', 'facility_id', 'equip_count_total', 'basin_id']]
    equip_year['basin_id'] = equip_year['basin_id'].fillna(0)
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
    # equip_data['basin_id'] = equip_data['facility_name'].apply(extract_three_digit_number)

    # PC_year.csv

    pc_data = pd.read_csv(pc_file_path)

    # year
    PC_year = pc_data[pc_data.reporting_year == year]
    PC_year = pd.merge(PC_year, facilities_year[['facility_id', 'basin_id']], on='facility_id', how='left')
    PC_year = PC_year.drop_duplicates(subset=['reporting_year', 'facility_id', 'basin_id', 'table_desc', 'total_count'])
    PC_year = PC_year[['facility_id', 'total_count', 'basin_id']]
    PC_year['basin_id'] = PC_year['basin_id'].fillna(0)
    PC_year = PC_year.sort_values(by='facility_id')
    PC_year.to_csv(os.path.join(GHGRPfolder, f'PC_{year}.csv'), header=None, index=False)

    # Pump_year.csv

    pump_data = pd.read_csv(pump_file_path)

    # year
    Pump_year = pump_data[pump_data.reporting_year == year]
    Pump_year = pd.merge(Pump_year, facilities_year[['facility_id', 'basin_id']], on='facility_id', how='left')
    Pump_year = Pump_year.drop_duplicates(
        subset=['reporting_year', 'facility_id', 'basin_id', 'table_desc', 'total_pneumatic_pump_count'])
    Pump_year = Pump_year[['facility_id', 'total_pneumatic_pump_count', 'basin_id']]
    Pump_year['basin_id'] = Pump_year['basin_id'].fillna(0)
    Pump_year = Pump_year.sort_values(by='facility_id')
    Pump_year.to_csv(os.path.join(GHGRPfolder, f'Pump_{year}.csv'), index=False, header=False)

    # Tanks12_year.csv

    tanks12_data = pd.read_csv(tanks12_file_path)
    tanks12_data['basin_id'] = tanks12_data['sub_basin_identifier'].str.extract(r'(\d{3})')
    tanks12_data = tanks12_data[~pd.isna(tanks12_data.atmospheric_tank_count)]
    tanks12_data = tanks12_data[tanks12_data.atmospheric_tank_count > 0]

    # year
    tanks12_year = tanks12_data[tanks12_data.reporting_year == year]
    tanks12_year['QVRU'] = (tanks12_year['tanks_with_vapor_recovery'] * tanks12_year['total_volume_of_oil'] /
                            tanks12_year['atmospheric_tank_count']) / 1000000
    tanks12_year['QVent'] = (tanks12_year['tanks_venting_to_atm'] * tanks12_year['total_volume_of_oil'] / tanks12_year[
        'atmospheric_tank_count']) / 1000000
    tanks12_year['QFlare'] = (tanks12_year['tanks_with_flaring'] * tanks12_year['total_volume_of_oil'] / tanks12_year[
        'atmospheric_tank_count']) / 1000000
    tanks12_year['basin_id'] = tanks12_year['basin_id'].fillna(0)
    tanks12_year['QVRU'] = tanks12_year['QVRU'].fillna(0)
    tanks12_year['QVent'] = tanks12_year['QVent'].fillna(0)
    tanks12_year['QFlare'] = tanks12_year['QFlare'].fillna(0)
    tanks12_year = tanks12_year.sort_values(by='facility_id')
    tanks12_year = tanks12_year[['facility_id', 'QVRU', 'QVent', 'QFlare', 'atmospheric_tank_count', 'basin_id']]
    tanks12_year.to_csv(os.path.join(GHGRPfolder, f'Tanks12_{year}.csv'), index=False, header=False)

    # Tanks3_year.csv

    tanks3_data = pd.read_csv(tanks3_file_path)
    tanks3_data = tanks3_data.fillna(0)
    tanks3_data_atm_counts = tanks3_data[~pd.isna(tanks3_data.atmospheric_tank_count)]
    tanks3_data_basins = tanks3_data[~pd.isna(tanks3_data.sub_basin_identifier)][
        ['facility_id', 'sub_basin_identifier']]
    tanks3_data_atm_counts = tanks3_data_atm_counts.drop(columns=['sub_basin_identifier'])
    tanks3_data = tanks3_data_atm_counts.merge(tanks3_data_basins, on=['facility_id'])
    tanks3_data['basin_id'] = tanks3_data['sub_basin_identifier'].str.extract(r'(\d{3})')
    tanks3_data = tanks3_data[~pd.isna(tanks3_data.atmospheric_tank_count)]

    subset = ['annual_oil_throughput', 'atmospheric_tank_count',
              'ch4_emissions_from_flare', 'ch4_emissions_not_flared', 'facility_name', 'fract_oil_throughput_flaring',
              'fract_throughput_with_vapor', 'facility_id', 'industry_segment', 'reporting_year', 'table_desc',
              'table_num',
              'basin_id']
    tanks3_data = tanks3_data[subset]
    tanks3_data = tanks3_data.drop_duplicates(subset=subset)

    # year
    tanks3_year = tanks3_data[tanks3_data.reporting_year == year]
    tanks3_year['fract_throughput_with_vapor'] = tanks3_year['fract_throughput_with_vapor'].fillna(0)
    tanks3_year['fract_oil_throughput_flaring'] = tanks3_year['fract_oil_throughput_flaring'].fillna(0)
    tanks3_year['QVRU'] = (tanks3_year['fract_throughput_with_vapor'] * tanks3_year['annual_oil_throughput']) / 1000000
    tanks3_year['QFlare'] = (tanks3_year['fract_oil_throughput_flaring'] * tanks3_year[
        'annual_oil_throughput']) / 1000000
    tanks3_year['QVent'] = (tanks3_year['annual_oil_throughput'] / 1000000) - tanks3_year['QVRU'] - tanks3_year[
        'QFlare']
    tanks3_year['basin_id'] = tanks3_year['basin_id'].fillna(0)
    tanks3_year['QVRU'] = tanks3_year['QVRU'].fillna(0)
    tanks3_year['QVent'] = tanks3_year['QVent'].fillna(0)
    tanks3_year['QFlare'] = tanks3_year['QFlare'].fillna(0)
    tanks3_year = tanks3_year.sort_values(by='facility_id')
    tanks3_year = tanks3_year[['facility_id', 'QVRU', 'QVent', 'QFlare', 'atmospheric_tank_count', 'basin_id']]
    tanks3_year.to_csv(os.path.join(GHGRPfolder, f'Tanks3_{year}.csv'), index=False, header=False)

    # LU_type.csv
    LU_data = pd.read_csv(LU_file_path)

    LU_dict = {}
    for year in LU_data.reporting_year.unique():
        LU_year = LU_data[LU_data.reporting_year == year]
    LU_year['nb_wells_LU'] = LU_year.number_of_wells.fillna(0) + LU_year.number_of_wells_vented.fillna(0)
    LU_year.plunger_lifts_used = LU_year.plunger_lifts_used.replace('Yes', 1)
    LU_year.plunger_lifts_used = LU_year.plunger_lifts_used.replace('No', 0)
    LU_year['nb_wells_LU_plunger'] = LU_year.nb_wells_LU * LU_year.plunger_lifts_used
    LU_year['nb_wells_LU_no_plunger'] = LU_year.nb_wells_LU - LU_year.nb_wells_LU_plunger
    LU_year['basin_id'] = LU_year['sub_basin_identifier'].str.extract(r'(\d{3})')
    facilities_year = facilities_data[facilities_data.reporting_year == year]
    facilities_year['basin_id'] = facilities_year['sub_basin_identifier'].str.extract(r'(\d{3})')
    facilities_year = facilities_year[~pd.isna(facilities_year.basin_id)]
    facilities_year_260 = facilities_year[facilities_year.basin_id == '260']

    facilities_year = facilities_year.drop_duplicates(subset=['facility_id', 'basin_id', 'well_producing_end_of_year'])

    equip_year = equip_data[equip_data.reporting_year == year]
    facilities_year = facilities_data[facilities_data.reporting_year == year]
    equip_year = pd.merge(equip_year, facilities_year[['facility_id', 'basin_id']], on='facility_id', how='left')
    equip_year = equip_year.drop_duplicates(
        subset=['reporting_year', 'facility_id', 'basin_id', 'table_desc', 'equipment_type'])
    equip_wells = equip_year[equip_year.equipment_type == 'Wellhead']
    total_wells_gas_year = equip_wells.groupby(['basin_id'])['equip_count_total'].sum().reset_index()

    LU_year = LU_year.groupby(['basin_id'])['nb_wells_LU_plunger', 'nb_wells_LU_no_plunger'].sum().reset_index()
    LU_year = pd.merge(LU_year, total_wells_gas_year, on='basin_id')

    LU_year['fract_LU_with_plunger'] = LU_year.nb_wells_LU_plunger / LU_year.equip_count_total
    LU_year['fract_LU_without_plunger'] = LU_year.nb_wells_LU_no_plunger / LU_year.equip_count_total
    LU_year['fract_no_LU'] = 1 - LU_year['fract_LU_without_plunger'] - LU_year['fract_LU_with_plunger']

    LU_year['fract_LU_with_plunger_within_LU'] = LU_year.nb_wells_LU_plunger / (
                LU_year.nb_wells_LU_plunger + LU_year.nb_wells_LU_no_plunger)
    LU_year['fract_LU_without_plunger_within_LU'] = LU_year.nb_wells_LU_no_plunger / (
                LU_year.nb_wells_LU_plunger + LU_year.nb_wells_LU_no_plunger)
    LU_year['fract_LU'] = LU_year.fract_LU_with_plunger + LU_year.fract_LU_without_plunger
    LU_dict[year] = LU_year

    Basin_N = [str(basin) for basin in Basin_N]

    # year
    LU_export = LU_dict[year][LU_dict[year].basin_id.isin(Basin_N)].reset_index(drop=True)

    new_row = pd.DataFrame([[0, 0, 1]], columns=['fract_LU_with_plunger', 'fract_LU_without_plunger', 'fract_no_LU'])

    LU_export = LU_export[['fract_LU_with_plunger', 'fract_LU_without_plunger', 'fract_no_LU']]
    LU_export = pd.concat([LU_export.iloc[:-1], new_row, LU_export.iloc[-1:]], ignore_index=True)

    LU_export.to_csv(os.path.join(activityfolder, 'LU_type.csv'), index=False, header=False)
    return None

def generate_drillinginfo_dat(year, inputsfolder, drillinginfofolder):
    # annualDF_2020_SpatialJoin_2258

    raw_enverus_drillinginfo_foldername = os.path.join(inputsfolder, 'Enverus_DrillingInfo')

    basins_gdf = gpd.read_file(os.path.join(inputsfolder, 'Basins_shapefiles'))

    basin_to_province = {
        'Appalachia Basin': 160,
        'Appalachian Basin (Eastern Overthrust Area)': '160A',
        'Permian Basin': 430,
        'Mid Gulf Coast Basin': 210,
        'Gulf Coast Basin': 220,
        'Anadarko Basin': 360,
        'Fort Worth Syncline': 420,
        'Arkoma Basin': 345,
        'Denver Basin': 540,
        'San Juan Basin': 580,
        'Uinta Basin': 575,
        'Piceasnce Basin': 595,
        'Green River Basin': 535,
        'Williston Basin': 395,
        'San Joaquin Basin': 745,
        'Powder River Basin': 515,
        'Michigan Basin': 305,
        'Florida Basin': 140,
        'Arkla Basin': 230,
        'East Texas Basin': 260,
        'Strawn Basin': 415,
        'Bend Arch': 425,
        'Palo Duro Basin': 435,
        'Las Animas Arch': 450,
        'Central Western Overthrust': 507,
        'Wind River Basin': 530,
        'Paradox Basin': 585,
        'Sacramento Basin': 730,
        'AK Cook Inlet Basin': 820}

    # Wells production info (API number, Gas prod, Oil prod)

    wellsproduction_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Production')
    wellsproduction_csv_files = [f for f in os.listdir(wellsproduction_folderpath) if f.lower().endswith('.csv')]

    wellsproduction_df = pd.concat([pd.read_csv(os.path.join(wellsproduction_folderpath, file),
                                          usecols=['API/UWI', 'Monthly Oil', 'Monthly Gas', 'Monthly Production Date']) for file in wellsproduction_csv_files],
                             ignore_index=True)

    wellsproduction_df['Year'] = pd.to_datetime(wellsproduction_df['Monthly Production Date']).dt.year
    wellsproduction_df = wellsproduction_df.groupby(['Year', 'API/UWI'])[
        ['Monthly Gas', 'Monthly Oil']].sum().reset_index()
    wellsproduction_df = wellsproduction_df[wellsproduction_df.Year == year]

    # Wells infos (API number, lat, lon)

    wellsinfo_folderpath = os.path.join(raw_enverus_drillinginfo_foldername, 'Wells')
    wellsinfo_csv_files = [f for f in os.listdir(wellsinfo_folderpath) if f.lower().endswith('.csv')]
    wellsinfo_df = pd.concat([pd.read_csv(os.path.join(wellsinfo_folderpath, file),
                                          usecols=['API14', 'Surface Hole Latitude (WGS84)',
                                                   'Surface Hole Longitude (WGS84)']) for file in wellsinfo_csv_files],
                             ignore_index=True)
    wellsinfo_df = wellsinfo_df.rename(
        columns={'Surface Hole Latitude (WGS84)': 'lat', 'Surface Hole Longitude (WGS84)': 'lon'})

    geometry = [Point(lon, lat) for lat, lon in zip(wellsinfo_df.lat, wellsinfo_df.lon)]
    wellsinfo_gdf = gpd.GeoDataFrame(wellsinfo_df, geometry=geometry, crs='EPSG:4326')
    wellsinfo_gdf = gpd.sjoin(wellsinfo_gdf.to_crs(26914), basins_gdf.to_crs(26914), op='within')
    wellsproduction_df = wellsproduction_df[wellsproduction_df.Year == year]

    wellsinfo_gdf = wellsinfo_gdf.drop_duplicates(subset=['API14', 'lat', 'lon', 'BASIN_NAME'])
    wellsproduction_df = wellsproduction_df.rename(columns={'API/UWI': 'API14'})

    spatial_join = wellsproduction_df.merge(wellsinfo_gdf, on=['API14'])

    spatial_join['Prov_Cod_1'] = spatial_join['BASIN_NAME'].map(basin_to_province)
    spatial_join = spatial_join.dropna(subset=['Prov_Cod_1'])

    spatial_join = spatial_join.rename(columns={'Monthly Gas': 'Monthly_Ga',
                                                'Monthly Oil': 'Monthly_Oi',
                                                'lat': 'Surface_Ho',
                                                'lon': 'Surface__1'})

    spatial_join['OBJECTID'] = None
    spatial_join['Join_Count'] = None
    spatial_join['TARGET_FID'] = None
    spatial_join['Field1'] = None

    spatial_join = spatial_join[['OBJECTID', 'Join_Count', 'TARGET_FID', 'Field1',
                                 'Monthly_Oi', 'Monthly_Ga', 'API14', 'Surface_Ho', 'Surface__1', 'Prov_Cod_1']]

    spatial_join_filename = f'annualDF_{year}_SpatialJoin_2258.csv'

    spatial_join.to_csv(os.path.join(drillinginfofolder, spatial_join_filename), index=False)
    return None


def return_wells_to_facility(year, inputsfolder, drillinginfofolder, GHGRPfolder):

    wells_data_filename = os.path.join(inputsfolder, 'EF_W_ONSHORE_WELLS', f'EF_W_ONSHORE_WELLS_{year}.xlsb')
    wells_data = pd.read_excel(wells_data_filename, usecols=['FACILITY_ID', 'WELL_ID_NUMBER'], engine='pyxlsb')

    # Drop rows with NA values in the WELL_ID_NUMBER column and remove non-numeric characters
    wells_data = wells_data.dropna(subset=['WELL_ID_NUMBER'])
    wells_data.WELL_ID_NUMBER = wells_data.WELL_ID_NUMBER.astype(str)

    wells_data.WELL_ID_NUMBER = wells_data.WELL_ID_NUMBER.str.replace(r'\D+', '')

    # Drop rows where WELL_ID_NUMBER is an empty string
    wells_data = wells_data[wells_data.WELL_ID_NUMBER != '']

    # Pad the WELL_ID_NUMBER to ensure proper lengths
    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].str.lstrip('0')  # remove leading zeros
    wells_data['WELL_ID_NUMBER'] = wells_data['WELL_ID_NUMBER'].apply(lambda x: x.ljust(14, '0') if len(x) == 12 else
    x.ljust(13, '0') if len(x) == 11 else
    x.ljust(14, '0') if len(x) == 10 else
    x.ljust(13, '0') if len(x) == 9 else x)

    Enverus_path = os.path.join(drillinginfofolder, f'annualDF_{year}_SpatialJoin_2258.csv')
    Enverus_data = pd.read_csv(Enverus_path, skiprows=1, usecols=[4, 5, 6, 9],
                               names=['Annual Oil [bbl/year]', 'Annual Gas [mscf/year]', 'API/UWI', 'Prov_Cod_1'],
                               index_col=None,
                               encoding_errors='ignore')

    Enverus_data['API/UWI'] = Enverus_data['API/UWI'].astype('string')

    api_facility_correspondance_df = Enverus_data.merge(wells_data, left_on='API/UWI', right_on='WELL_ID_NUMBER')

    api_facility_correspondance_filename = f'API_Facility_correspondence_{year}.csv'

    api_facility_correspondance_df.to_csv(os.path.join(drillinginfofolder, api_facility_correspondance_filename), index=False)
    api_facility_correspondance_df.to_csv(os.path.join(GHGRPfolder, api_facility_correspondance_filename), index=False)

    return None