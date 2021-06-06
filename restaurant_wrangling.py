"""
Clean the dataset and select only the industry types that are related to cafe and restaurants
"""

import pandas as pd


# Function to create the description
def get_desc(df):
    description = '<b><ins>' + df['name'] + '</ins></b><br>' + \
                  df['address'] + '<br>'
    # Add number of indoor seating
    if not pd.isnull(df['seat_indoor']):
        description += '<br><b>Indoor seats:</b>' + str(int(df['seat_indoor']))
    # Add number of outdoor seating
    if not pd.isnull(df['seat_outdoor']):
        description += '<br><b>Outdoor seats:</b>' + str(int(df['seat_outdoor']))
    return description


# Read file to pandas df
df = pd.read_csv('Cafes_and_restaurants__with_seating_capacity.csv')

# Select related columns
df = df[['Census year',
         'Street address',
         'CLUE small area',
         'Trading name',
         'Industry (ANZSIC4) description',
         'Seating type',
         'Number of seats',
         'x coordinate',
         'y coordinate']]

# Drop the null row
df.dropna()

# Rename column for easier management
df = df.rename(columns={'Census year':'year',
                        'Street address': 'address',
                        'CLUE small area': 'suburb',
                        'Trading name': 'name',
                        'Industry (ANZSIC4) description': 'res_type',
                        'x coordinate': 'lon',
                        'y coordinate': 'lat',
                        'Number of seats': 'num_of_seats'})

# Select only the industry types that are related to cafe and restaurants
res_related = ['Cafes and Restaurants',
               'Pubs, Taverns and Bars',
               'Takeaway Food Services']
res_df = df[df['res_type'].isin(res_related)]

# Spread seating type into two columns
seat_df = res_df.pivot_table(index=['year',
                                    'address',
                                    'suburb',
                                    'name',
                                    'res_type',
                                    'lon',
                                    'lat'],
                             columns='Seating type',
                             values='num_of_seats').reset_index()

# Rename seating type columns
seat_df = seat_df.rename(columns={
                    'Seats - Indoor': 'seat_indoor',
                    'Seats - Outdoor': 'seat_outdoor'})


# For display the current restaurant in the City of Melbourne (2019)
seat_2019 = seat_df[seat_df['year'] == 2019].copy()

# Get description
seat_2019["description"] = seat_2019.apply(get_desc, axis=1)
seat_2019.reset_index(inplace=True, drop=True)

# Output location data in CSV file
seat_2019.to_csv('clean_restaurants_seats.csv', index=False)