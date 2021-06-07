library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# Manage the data to display in the first tab
# Read data
seat_data <- read.csv("clean_restaurants_seats.csv", header = TRUE)

# Separate each type of restaurant
res_data <- filter(seat_data, res_type == "Cafes and Restaurants")
pub_data <- filter(seat_data, res_type == "Pubs, Taverns and Bars")
take_data <- filter(seat_data, res_type == "Takeaway Food Services")

# Manage the data to display in the second tab
# Read data
stat_data <- read.csv("restaurants_seats_stat.csv", header = TRUE)


# SERVER
function(input, output, session){
  
  # FIRST TAB
  # Responsive checkboxes
  # When click deselect all of the checkbox
  # Reference: https://stackoverflow.com/a/24269691
  observe({
    if (input$clear > 0){
      updateCheckboxInput(session = session, inputId = "caf_res_c", value = FALSE)
      updateCheckboxInput(session = session, inputId = "pub_c", value = FALSE)
      updateCheckboxInput(session = session, inputId = "takeaway_c", value = FALSE)
    }
  })
  
  # When click Show all
  observe({
    if (input$show_all > 0){
      updateCheckboxInput(session = session, inputId = "caf_res_c", value = TRUE)
      updateCheckboxInput(session = session, inputId = "pub_c", value = TRUE)
      updateCheckboxInput(session = session, inputId = "takeaway_c", value = TRUE)
    }
  })
  
  # Create the map marker styles
  # For cafes and restaurants
  caf_icons <- awesomeIcons(
    icon = "fa-cutlery",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "lightred"
  )
  
  # For pubs, taverns and bars
  pub_icons <- awesomeIcons(
    icon = "fa-glass",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "cadetblue"
  )
  
  # For takeaway food services
  take_icons <- awesomeIcons(
    icon = "fa-shopping-bag",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "lightgreen"
  )
  
  
  # Map output
  output$res_map<- renderLeaflet({
    map <- leaflet(options = leafletOptions(minZoom = 11)) %>% 
      setView(lng = 144.9615, lat = -37.8156, zoom = 13) %>%
      addTiles()%>%
      
      # Set map boundery
      setMaxBounds(lng1 = 144.8615
                   ,lat1 = -37.9156
                   ,lng2 = 145.0615
                   ,lat2 = -37.7156) %>%
      # Legend
      addLegend("bottomright", 
                colors =c("#eb7d7f", "#436978",  "#bbf970"),
                labels= c("Cafes and Restaurants",
                          "Pubs, Taverns and Bars", 
                          "Takeaway Food Services"), opacity = 1)
  })
  
  # Display cafes and restaurants locations
  # References: https://stackoverflow.com/a/37435428
  # https://stackoverflow.com/a/43596736
  # https://stackoverflow.com/a/41961038
  observe({if(input$caf_res_c){
    leafletProxy("res_map", data = res_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "rest_gr", 
                        icon = caf_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "rest_gr")
  }
  })
  
  # Display pubs, taverns and bars locations
  observe({if(input$pub_c){
    leafletProxy("res_map", data = pub_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "pub_gr", 
                        icon = pub_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "pub_gr")
  }
  })
  
  # Display takeaway food services locations
  # Display pubs, taverns and bars locations
  observe({if(input$takeaway_c){
    leafletProxy("res_map", data = take_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "take_gr", 
                        icon = take_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "take_gr")
  }
  })
  
  # SECOND TAB
  output$seat_change <- renderPlot({
    stat_year <- filter(stat_data, year == input$year)
    
    # When all type of restaurants is selected
    if(input$res_type == "all_r1"){
      if(input$seat_type == "all_r2"){
        stat_sum <- aggregate(stat_year$all_seat, 
                              by=list(stat_year$suburb), FUN=sum)
      }else if(input$seat_type == "indoor_r2"){
        stat_sum <- aggregate(stat_year$seat_indoor, 
                              by = list(stat_year$suburb), FUN=sum)
      }else if(input$seat_type == "outdoor_r2"){
        stat_sum <- aggregate(stat_year$seat_outdoor, 
                              by = list(stat_year$suburb), FUN=sum)
      }
      # Rename columns
      stat_sum <- setNames(stat_sum, c("x", "y"))
      
      # When specific type of restaurant is selected
    }else{
      # Restaurant type
      if(input$res_type == "caf_res_r1"){
        stat_sum <- filter(stat_year, res_type == "Cafes and Restaurants")
      }else if(input$res_type == "pub_r1"){
        stat_sum <- filter(stat_year, res_type == "Pubs, Taverns and Bars")
      }else if(input$res_type == "takeaway_r1"){
        stat_sum <- filter(stat_year, res_type == "Takeaway Food Services")
      }
      
      # Seating type
      if(input$seat_type == "all_r2"){
        stat_sum <- stat_sum %>% select(suburb, all_seat)
      }else if(input$seat_type == "indoor_r2"){
        stat_sum <- stat_sum %>% select(suburb, seat_indoor)
      }else if(input$seat_type == "outdoor_r2"){
        stat_sum <- stat_sum %>% select(suburb, seat_outdoor)
      }  
      # Rename columns
      stat_sum <- setNames(stat_sum, c("x", "y"))
    }
    
    # Reorder the axis
    # Reference: https://stackoverflow.com/a/5210833
    stat_sum <- within(stat_sum, 
                       x <- factor(x, levels = c("West Melbourne",
                                                 "Southbank",
                                                 "South Yarra",
                                                 "Port Melbourne",
                                                 "Parkville",
                                                 "North Melbourne",
                                                 "Melbourne (Remainder)",
                                                 "Melbourne (CBD)",
                                                 "Kensington",
                                                 "East Melbourne",
                                                 "Docklands",
                                                 "Carlton")))
    
    # Plot graph
    res_plot <- ggplot(data = stat_sum, aes(y, x)) + 
                  geom_bar(stat="identity", fill = "#e1701a") +
                  labs(x="Number of seats", y = "") +
                  scale_y_discrete(drop = FALSE) +
                  theme_minimal() 
    
    # Fixed the scale
    if(input$fixed_axis == "fixed"){
      res_plot <- res_plot + xlim(0, 100000)
    }
    
    # Display the plot
    res_plot
  })
  
}