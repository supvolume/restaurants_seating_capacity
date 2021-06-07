# Restaurants Seating Capacity
Shiny application to display the seating capacity of restaurants in the City of Melbourne and the restaurants' location.

Click [here](https://supida.shinyapps.io/restaurant_seating/) to view the demo.


#### Files in this repository
- `Cafes_and_restaurants__with_seating_capacity.csv`: raw data from the City of Melbourne open data
- `restaurant_wrangling.py`: the code for wrangling café and restaurant seating capacity data
- `clean_restaurants_seats.csv`: the location and seating capacity detail of restaurants in 2019 (output from `restaurant_wrangling.py`)
- `restaurants_seats_stat.csv`: overall statistic of restaurant seating capacity from 2002 to 2019 (output from `restaurant_wrangling.py`)
- `server.R`: Server file for R Shiny
- `ui.R`: UI file for R Shiny


The data used in this project was from the City of Melbourne (2021). Cafes and restaurants, with seating capacity. Retrieved 2 June 2021, from https://data.melbourne.vic.gov.au/Business/Cafes-and-restaurants-with-seating-capacity/xt2y-tnn9
