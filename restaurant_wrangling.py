"""
Clean the dataset and select only the industry types that are related to cafe and restaurants
"""

import pandas as pd


# Function to create the description
def get_desc(df):
    description = '<b><ins>' + df['Trading name'] + '</ins></b><br>' + \
                  df['Street address']
    # Add number of indoor seating
    if not pd.isnull(df['Seats - Indoor']):
        description += '<br><br><b>Indoor seats:</b>' + str(df['Seats - Indoor'])
    # Add number of outdoor seating
    if not pd.isnull(df['Seats - Outdoor']):
        description += '<br><br><b>Outdoor seats:</b>' + str(df['Seats - Outdoor'])
    return description


# Read file to pandas df
df = pd.read_csv('Cafes_and_restaurants__with_seating_capacity.csv')

# Select related columns
df = df[['Census year',
          'Block ID',
          'Property ID',
          'Base property ID',
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

# Select only the industry types that are related to cafe and restaurants
res_related = ['Cafes and Restaurants',
               'Pubs, Taverns and Bars',
               'Takeaway Food Services']
res_df = df[df['Industry (ANZSIC4) description'].isin(res_related)]

# Spread seating type into two columns
seat_df = res_df.pivot_table(index=['Census year',
                                    'Block ID',
                                    'Property ID',
                                    'Base property ID',
                                    'Street address',
                                    'CLUE small area',
                                    'Trading name',
                                    'Industry (ANZSIC4) description',
                                    'x coordinate',
                                    'y coordinate'],
                             columns='Seating type',
                             values='Number of seats').reset_index()

# Get description
seat_df["Description"] = seat_df.apply(get_desc, axis=1)

# Rename column for easier management in R
seat_df = seat_df.rename(columns={'Census year':'year',
                        'CLUE small area': 'suburb',
                        'Trading name': 'name',
                        'Industry (ANZSIC4) description': 'res_type',
                        'x coordinate': 'lon',
                        'y coordinate': 'lat',
                        'Seats - Indoor': 'seat_indoor',
                        'Seats - Outdoor': 'sear_outdoor',
                        'Number of seats': 'num_of_seats'})

# TODO: If R error, replace Null with 0
seat_df.to_csv('clean_restaurants_seats.csv')